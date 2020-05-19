int	PlayerIsInClusterList(entity player, entity cluster, entity chunk)
{
	entity e;
	float sendtime;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		if(e == player)
		{
			sendtime = chunk.chunk_playerdelay[i];
			if(time >= sendtime)
			{
				chunk.chunk_playerdelay[i] = 0;
				return TRUE;
			}
			
			return FALSE;
		}
		
		if(!e)
			return FALSE;
	}
	
	return FALSE;
}

void SendInitializeData(float sendflags)
{
	if(sendflags & SFL_INITIALIZE)
	{
		WriteByte(MSG_ENTITY, worldsize);
		WriteByte(MSG_ENTITY, clustersize);
		WriteByte(MSG_ENTITY, chunksize);
		WriteByte(MSG_ENTITY, cubicradius*2);	// *2 because we sent 2x the radius as an integer instead of radius as a float when trying to support single quake unit sized cubics
		WriteByte(MSG_ENTITY, viewsize);
		WriteByte(MSG_ENTITY, viewheight);
		WriteByte(MSG_ENTITY, viewsize_distant);
		WriteByte(MSG_ENTITY, viewheight_distant);
		WriteCoord(MSG_ENTITY, ambientlight_x);
		WriteCoord(MSG_ENTITY, ambientlight_y);
		WriteCoord(MSG_ENTITY, ambientlight_z);
		WriteByte(MSG_ENTITY, maxcubicupdates);
	}	
}

float InitializeHackSendFlags(entity viewer, float sendflags)
{
	// never send these flags unless told to here
	sendflags = sendflags - (sendflags & SFL_INITIALIZE);

	// this is a hack to ensure worldsize is sent prior to chunks needing to reference it. this continues to send until the client responds "cmd cq_initialized" to stop it.
	// (should use serverkeys instead or something)
	if(!viewer.client_initialized)
		sendflags = (sendflags | SFL_INITIALIZE);
	
	return sendflags;
}

void SendCubics(entity chunk, int bloatstage)
{
	int type, cullbits, sentcount;//, bloatcount;	
	int maxblocks = pow(chunksize, 3);
	int wouldsend = 0;
	
	WriteShort(MSG_ENTITY, chunk.numvisiblecubics);
	
	for(int count = 0; sentcount < min(maxcubicupdates, chunk.numvisiblecubics-(maxcubicupdates*bloatstage)) && count < pow(chunksize, 3); count++)
	{
		type = chunk.cubic_blocktype[count];
		cullbits = chunk.cubic_cullbits[count];
		
		if(type)
		if((cullbits & CULLBITS_ALL) != CULLBITS_ALL)
		{
			if(wouldsend >= bloatstage*maxcubicupdates)
			if(wouldsend < (bloatstage+1)*maxcubicupdates)
			{
				WriteShort(MSG_ENTITY, count);
				
//				for(bloatcount = 0; bloatcount < maxblocks/255; bloatcount++)
//					WriteByte(MSG_ENTITY, min(255, max(0, count-255*bloatcount)));

		//		WriteByte(MSG_ENTITY, min(255, count));
		//		WriteByte(MSG_ENTITY, min(255, max(0, count-255)));		// if you use bigger chunks you might need to add some lines to this
		//		WriteByte(MSG_ENTITY, min(255, max(0, count-255*2)));

				WriteByte(MSG_ENTITY, type);
				if(!NonSolidType(type))
				{
					WriteByte(MSG_ENTITY, chunk.cubic_blockshape[count]);
					WriteByte(MSG_ENTITY, chunk.cubic_blockrotation[count]);
					WriteByte(MSG_ENTITY, cullbits & CULLBITS_ALL);
				}
				
				sentcount++;
			}
			
			wouldsend++;
		}
	}		
}

float SendChunk(entity viewer, float sendflags)
{
	int i = GetChunkOriginRef(self.origin, __FUNC__);
	
	if(!self.numvisiblecubics)
		return FALSE; 

	entity cluster = cluster_ent[GetClusterRef(GetNearClusterOrg(self.origin))];

	#ifdef DEBUG
	if(wasfreed(cluster))
		print("SendChunk A wasfreed.\n");
	#endif
	
	if(!PlayerIsInClusterList(viewer, cluster, self))
		return FALSE;

	sendflags = InitializeHackSendFlags(viewer, sendflags);
	
	WriteByte(MSG_ENTITY, ENT_CHUNK);	
	WriteLong(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, self.updateref);
	
	SendInitializeData(sendflags);
	
	if(sendflags & SFL_ISNEW)
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin, __FUNC__));
	
	if(sendflags & SFL_BUILD)
		SendCubics(self, 0);
	
	return TRUE;
}

float SendChunkBloat(entity viewer, float sendflags)
{
	if(!self.parentchunk.numvisiblecubics)
		return FALSE;
	
	entity cluster = cluster_ent[GetClusterRef(GetNearClusterOrg(self.origin))];
	if(!PlayerIsInClusterList(viewer, cluster, self.parentchunk))
		return FALSE;	
	
	sendflags = InitializeHackSendFlags(viewer, sendflags);
	
	WriteByte(MSG_ENTITY, ENT_CHUNKBLOAT);	
	WriteLong(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, self.updateref);
	
	SendInitializeData(sendflags);	
	
	if(sendflags & SFL_ISNEW)
	{
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin, __FUNC__));
		WriteByte(MSG_ENTITY, self.bloatlevel);
	}
	
	if(sendflags & SFL_BUILD)
		SendCubics(self.parentchunk, self.bloatlevel);

	return TRUE;
}

void SetChunkSendFlags(entity chunk, float sendflags, string funcname)
{
	chunk.updateref++;
	if(chunk.updateref > 255)
		chunk.updateref = 1;
	
	chunk.SendFlags = chunk.SendFlags | sendflags;

	if(chunk.networkbloat_allocated)
	{
		int numbloatents = ceil((float)chunk.numvisiblecubics/maxcubicupdates)-1;
		for(int count = 0; count < numbloatents; count++)
		{
			chunk.networkbloat[count].updateref = chunk.updateref;		
			chunk.networkbloat[count].SendFlags = chunk.networkbloat[count].SendFlags | sendflags;
		}
	}	
}

void SaveModifiedClusterFiles()
{
	if(numplayersloadingfiles > 0)
		return;
	
	entity cluster, nextcluster, chunk, nextchunk;
	string filename;
	int *cluster_data = __NULL__;
	int clusterchunkid, i, chunkslot0, cubicslot0;
	float file;
	
	for(cluster = list_saveclusterqueuechain; cluster; cluster = nextcluster)
	{
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("SaveModifiedClusterFiles A wasfreed.\n");	
		#endif
		
		nextcluster = cluster.saveclusterqueuechain;
		
		filename = strcat(worldpath, itos(GetClusterRef(cluster.origin)));
		file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
		cluster_data = (int*)fgets(file);
		
		for(chunk = cluster.list_savechunkqueuechain; chunk; chunk = nextchunk)
		{
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("SaveModifiedClusterFiles B wasfreed.\n");	
			#endif
			
			nextchunk = chunk.savechunkqueuechain;
			
			clusterchunkid = GetChunkRef(chunk.origin-cluster.origin);
			chunkslot0 = numprechunkvaluesincluster + clusterchunkid*numslotsforchunkincluster;

			cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
			
			for(i = 0; i < pow(chunksize, 3); i++)
			{
				cubicslot0 = chunkslot0+numprecubicvaluesinchunk+i*numvaluespercubic;

				cluster_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
				cluster_data[cubicslot0+CUBICSLOT_SHAPE] = chunk.cubic_blockshape[i];
				cluster_data[cubicslot0+CUBICSLOT_ROTATION] = GetFixedRotation(chunk.cubic_blockrotation[i], chunk.cubic_blockshape[i]);
				cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];				
			}

			SaveChunkQueueChain_Remove(cluster, chunk);
		}
		
		fclose(file);
		SaveClusterQueueChain_Remove(cluster);
	}
}

void SetChunkAsModified(entity chunk)
{
	entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(chunk.origin));	
	
	if(chunk.savechunkqueuechain || chunk.savechunkqueuechain_prev || cluster.list_savechunkqueuechain == chunk)
		return;
	
	if(!chunk.SendEntity) // if chunk was previously empty, set it up for networking
	{
		chunk.SendEntity = SendChunk;
		chunk.SendFlags = chunk.SendFlags | SFL_ISNEW;
	}
	
//	SetChunkSendFlags(chunk, SFL_BUILD);
	SetChunkSendFlags_BUILD_Chain_Add(chunk);
	SaveClusterQueueChain_Add(cluster);
	SaveChunkQueueChain_Add(cluster, chunk);	
}