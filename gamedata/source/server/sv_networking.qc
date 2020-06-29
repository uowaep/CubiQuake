int	PlayerIsInClusterList(entity player, entity cluster, entity chunk)
{
	entity e = __NULL__;
	float sendtime = 0;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		if(e == player)
		{
			sendtime = chunk.chunk_playerdelay[i];	// FIXME: this isn't used
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

void UpdateCubicHealth(entity chunk, vector org, float cubichealth)
{
	//	msg_entity = e;	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_CUBICHEALTH);
	WriteLong(MSG_MULTICAST, GetChunkOriginRef(chunk.origin));
	WriteLong(MSG_MULTICAST, GetCubicRef(org-chunk.origin));
	WriteByte(MSG_MULTICAST, ceil(cubichealth));
	multicast(__NULL__, MULTICAST_ALL);	// not a big deal if the damage isn't represented 100% correctly because if it's destroyed it will be removed on the normal chunk update
}

void SendCubics(entity chunk, int bloatstage)
{
	int type = 0, cullbits = 0, sentcount = 0, wouldsend = 0, sendrotation =0;//, bloatcount;	
	int maxblocks = pow(chunksize, 3);
	
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
				WriteLong(MSG_ENTITY, count);
				
//				for(bloatcount = 0; bloatcount < maxblocks/255; bloatcount++)
//					WriteByte(MSG_ENTITY, min(255, max(0, count-255*bloatcount)));

		//		WriteByte(MSG_ENTITY, min(255, count));
		//		WriteByte(MSG_ENTITY, min(255, max(0, count-255)));		// if you use bigger chunks you might need to add some lines to this
		//		WriteByte(MSG_ENTITY, min(255, max(0, count-255*2)));

				WriteByte(MSG_ENTITY, type);

				if(!NonSolidType(type))
				{
					WriteByte(MSG_ENTITY, chunk.cubic_blockshape[count]);
					WriteByte(MSG_ENTITY, cullbits & CULLBITS_ALL);
					if(chunk.cubic_blockshape[count] != BLOCKSHAPE_CUBE)
						sendrotation = TRUE;
					WriteByte(MSG_ENTITY, chunk.cubic_health[count]);
				}
				else
					sendrotation = TRUE;
				
				if(sendrotation)
					WriteByte(MSG_ENTITY, chunk.cubic_blockrotation[count]);
				
				sendrotation = FALSE;
				
				sentcount++;
			}
			
			wouldsend++;
		}
	}		
}

float SendChunk(entity viewer, float sendflags)
{
	int i = GetChunkOriginRef(self.origin);
	
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
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin));
	
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
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin));
		WriteByte(MSG_ENTITY, self.bloatlevel);
	}
	
	if(sendflags & SFL_BUILD)
		SendCubics(self.parentchunk, self.bloatlevel);

	return TRUE;
}

void UpdateNetworkBloat(entity chunk)
{
	int numbloatents = ceil((float)chunk.numvisiblecubics/maxcubicupdates)-1;
	for(int count = 0; count < numbloatents; count++)
	{
		chunk.networkbloat[count].updateref = chunk.updateref;		
		chunk.networkbloat[count].SendFlags = chunk.networkbloat[count].SendFlags | chunk.bloatSendFlags;
	}	
}

void UpdateChunkNetworkEntities()
{
	entity nexte = __NULL__;
	
	for(entity e = list_networkbloatupdatechain; e; e = nexte)
	{
		nexte = e.networkbloatupdatechain;
		
		UpdateNetworkBloat(e);
		NetworkBloatUpdateChain_Remove(e);
		e.bloatSendFlags = 0;
	}
}

void SetChunkSendFlags(entity chunk, float sendflags)
{
	chunk.updateref++;
	if(chunk.updateref > 255)
		chunk.updateref = 1;
	
	if(chunk.damaged)
	{
		sendflags = sendflags | SFL_DAMAGED;
		chunk.damaged = FALSE;
	}
	
	chunk.SendFlags = chunk.SendFlags | sendflags;
	chunk.bloatSendFlags = chunk.bloatSendFlags | sendflags;

	if(chunk.networkbloat_allocated)	// don't bother if no bloats ents have ever been added
		NetworkBloatUpdateChain_Add(chunk);	// do this after the queuesetvisiblecubicschain resolves because new bloat ents haven't spawned yet
}

void SetChunkAsModified(entity chunk, int fastredraw, int tell_csqc)
{
	entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(chunk.origin));	
	
//	if(chunk.savechunkqueuechain || chunk.savechunkqueuechain_prev || cluster.list_savechunkqueuechain == chunk)
//		return;

	if(tell_csqc)
	{
		if(!chunk.SendEntity) // if chunk was previously empty, set it up for networking
		{
			chunk.SendEntity = SendChunk;
			chunk.SendFlags = chunk.SendFlags | SFL_ISNEW;
		}
		
	//	SetChunkSendFlags(chunk, SFL_BUILD);

		chunk.damaged = fastredraw;	// forces instant redraw on client
		SetChunkSendFlags_BUILD_Chain_Add(chunk);
	}
	
	SaveClusterQueueChain_Add(cluster);
	SaveChunkQueueChain_Add(cluster, chunk);	
}

void NetworkEntity(entity e, void(entity e) stopfunc, void(entity e) pushfunc)
{
	float maxvel = autocvar_sv_maxvelocity;
	vector oldrealvelocity = e.realvelocity;

	if(!e.origin_previous_set || !frametime)
		e.realvelocity = e.velocity;
	else
		e.realvelocity = (e.origin-e.origin_previous)/frametime;
	
	if(e.realvelocity*e.realvelocity > maxvel*maxvel)		// i should probably ask spike, but this SEEMS to work ... i've never gotten csqc prediction to be perfect :P
		e.realvelocity = normalize(e.realvelocity)*maxvel;
	
	if(e.realvelocity != oldrealvelocity || e.movetype == MOVETYPE_NONE)		
	if(e.realvelocity == '0 0 0')	// not moving
	{
		if(e.pushvelocity != '0 0 0')
			pushfunc(e);
		else
			stopfunc(e);
		e.SendFlags = e.SendFlags | SFL_STOP;
	}
	else
	if(e.movetype == MOVETYPE_WALK || e.movetype == MOVETYPE_BOUNCE || e.movetype == MOVETYPE_TOSS || e.movetype == MOVETYPE_BOUNCESLIDE)
		e.SendFlags = e.SendFlags | SFL_MOVE;
	
	e.origin_previous = e.origin;
	e.origin_previous_set = TRUE; // probably don't need to set these on entities as they spawn if it's set here.. test this
}