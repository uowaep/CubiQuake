int	PlayerIsInClusterList(entity player, entity cluster)
{
	entity e;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		if(e == player)
			return TRUE;
		
		if(!e)
			return FALSE;
	}
	
	return FALSE;
}

float SendChunk(entity viewer, float sendflags)
{
	int type, cullbits, sentcount;

	int i = GetChunkOriginRef(self.origin);
	
	if(!self.numvisiblecubics)
		return FALSE; 

	entity cluster = cluster_ent[GetClusterRef(GetNearClusterOrg(self.origin))];

	#ifdef DEBUG
	if(wasfreed(cluster))
		print("SendChunk A wasfreed.\n");
	#endif
	
	if(!PlayerIsInClusterList(viewer, cluster))
		return FALSE;

	// never send these flags unless told to here
	sendflags = sendflags - (sendflags & SFL_INITIALIZE);

	// this is a hack to ensure worldsize is sent prior to chunks needing to reference it. this continues to send until the client responds "cmd initialized" to stop it.
	// (should use serverkeys instead or something)
	if(!viewer.client_initialized)
		sendflags = (sendflags | SFL_INITIALIZE);
	
	WriteByte(MSG_ENTITY, ENT_CHUNK);	
	WriteLong(MSG_ENTITY, sendflags);
	
	if(sendflags & SFL_INITIALIZE)
	{
		WriteLong(MSG_ENTITY, worldsize);
		WriteLong(MSG_ENTITY, viewsize);
		WriteLong(MSG_ENTITY, viewheight);
		WriteLong(MSG_ENTITY, viewsize_distant);
		WriteLong(MSG_ENTITY, viewheight_distant);
		WriteCoord(MSG_ENTITY, ambientlight_x);
		WriteCoord(MSG_ENTITY, ambientlight_y);
		WriteCoord(MSG_ENTITY, ambientlight_z);
	}
	
	if(sendflags & SFL_ISNEW)
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin));
	
	if(sendflags & SFL_BUILD)
	{
		WriteShort(MSG_ENTITY, self.numvisiblecubics);

		for(int count = 0; sentcount < self.numvisiblecubics; count++)
		{
			type = self.cubic_blocktype[count];
			cullbits = self.cubic_cullbits[count];
			
			if(type)
			if((cullbits & CULLBITS_ALL) != CULLBITS_ALL)
			{
				WriteShort(MSG_ENTITY, count);
				WriteByte(MSG_ENTITY, type);
				if(!NonSolidType(type))
				{
					WriteByte(MSG_ENTITY, self.cubic_blockshape[count]);
					WriteByte(MSG_ENTITY, self.cubic_blockrotation[count]);
					WriteByte(MSG_ENTITY, cullbits & CULLBITS_ALL);
				}
				sentcount++;
			}
		}
	}	
	
	
//	sprint(viewer, "sent: ", ftos(GetChunkOriginRef(self.origin)), "\n");
	
	return TRUE;
}

entity GetCubicBBoxForLocation(vector cubicorg)
{
	for(entity bbox = findradius(cubicorg, 0); bbox; bbox = bbox.chain)
		if(bbox.enttype == ENT_CUBICBBOX)
			return bbox;

	return __NULL__;	
}

int SwapCullBits(int cullbits, int cb_u, int cb_w, int cb_s, int cb_e, int cb_n, int cb_d)
{
	return	(((cullbits & cb_u)>0)*CULLBITS_PARTIAL_U) |
			(((cullbits & cb_w)>0)*CULLBITS_PARTIAL_W) |
			(((cullbits & cb_s)>0)*CULLBITS_PARTIAL_S) |
			(((cullbits & cb_e)>0)*CULLBITS_PARTIAL_E) |
			(((cullbits & cb_n)>0)*CULLBITS_PARTIAL_N) |
			(((cullbits & cb_d)>0)*CULLBITS_PARTIAL_D);
}

int RotateCullBits(int cullbits, int rotation)
{
	switch(rotation)
	{
		case BLOCKROTATION_E:		break;	// default
		case BLOCKROTATION_N:		cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_D);	break;
		case BLOCKROTATION_W:		cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_D);	break;
		case BLOCKROTATION_S:		cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_D);	break;
		
		case BLOCKROTATION_CW_E:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_S);	break;
		case BLOCKROTATION_CW_N:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_S);	break;
		case BLOCKROTATION_CW_W:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_S);	break;
		case BLOCKROTATION_CW_S:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_S);	break;
		
		case BLOCKROTATION_UD_E:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_U);	break;
		case BLOCKROTATION_UD_N:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_U);	break;
		case BLOCKROTATION_UD_W:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_U);	break;
		case BLOCKROTATION_UD_S:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_U);	break;

		case BLOCKROTATION_CCW_E:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_N);	break;
		case BLOCKROTATION_CCW_N:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_N);	break;
		case BLOCKROTATION_CCW_W:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_N);	break;
		case BLOCKROTATION_CCW_S:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_N);	break;

		case BLOCKROTATION_FW_E:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_E);	break;
		case BLOCKROTATION_FW_N:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_E);	break;
		case BLOCKROTATION_FW_W:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_E);	break;
		case BLOCKROTATION_FW_S:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_W, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_E);	break;

		case BLOCKROTATION_BW_E:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_W);	break;
		case BLOCKROTATION_BW_N:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_W);	break;
		case BLOCKROTATION_BW_W:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_W);	break;
		case BLOCKROTATION_BW_S:	cullbits = SwapCullBits(cullbits, CULLBITS_PARTIAL_E, CULLBITS_PARTIAL_S, CULLBITS_PARTIAL_D, CULLBITS_PARTIAL_N, CULLBITS_PARTIAL_U, CULLBITS_PARTIAL_W);	break;
	}
	
	return cullbits;
}

int	GetPartialSideCullBitsForShape(int shape, int rotation)
{
	int partialsidebits;
	
	if(shape == BLOCKSHAPE_CUBE)
		return 0;
	
	switch(shape)
	{
		case BLOCKSHAPE_RAMP:		partialsidebits = CULLBITS_PARTIAL_U | CULLBITS_PARTIAL_N | CULLBITS_PARTIAL_S | CULLBITS_PARTIAL_W;	break;
		case BLOCKSHAPE_WEDGETIP:	partialsidebits = CULLBITS_PARTIAL_U | CULLBITS_PARTIAL_N | CULLBITS_PARTIAL_S | CULLBITS_PARTIAL_E | CULLBITS_PARTIAL_W;	break;
		case BLOCKSHAPE_WEDGE:		partialsidebits = CULLBITS_PARTIAL_U | CULLBITS_PARTIAL_N | CULLBITS_PARTIAL_S | CULLBITS_PARTIAL_W;	break;
	}
	
	partialsidebits = RotateCullBits(partialsidebits, rotation);
	
	return partialsidebits;
}

void GhostChunk(entity cluster, entity chunk)
{
	cluster.chunk_ent[GetChunkRef(chunk.origin-cluster.origin)] = __NULL__;
	
	while(chunk.list_cubicbboxchain)
	{
		#ifdef DEBUG
		if(wasfreed(chunk.list_cubicbboxchain))
			print("GhostChunk A wasfreed.\n");	
		#endif
		
		Remove(chunk.list_cubicbboxchain);
	}
	
	chunk.chunkbits = __NULL__;
	chunk.numvisiblecubics = 0;
	chunk.flags = 0;
	chunk.enttype = 0;	
	setorigin(chunk, '0 0 0');
	chunk.SendEntity = __NULL__;	// this is most likely the reason ghosting chunks doesn't work
	chunk.SendFlags = 0;
	
	memfill8(chunk.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
	
	ChunkChain_Remove(cluster, chunk);
	GhostChunkChain_Add(chunk);
}

void GhostCluster(entity cluster)
{
	cluster_ent[GetClusterRef(cluster.origin)] = __NULL__;	
	
	cluster.averagetype = 0;
	cluster.numvisiblecubics = 0;
	cluster.flags = 0;
	cluster.enttype = 0;
	setorigin(cluster, '0 0 0');
	
	memfill8(cluster.chunk_ent, __NULL__, sizeof(entity)*pow(clustersize, 3));
	memfill8(cluster.cluster_playerlist, __NULL__, sizeof(entity)*maxplayers);	// this line shouldn't be necessary.
	
	UnoccupiedClusterChain_Remove(cluster);
	RemoveClusterForAllClientsChain_Remove(cluster);
	GhostClusterChain_Add(cluster);
}

float InitializeCluster(entity cluster, vector org, int forceload)
{
//	entity chunk, nextchunk;
//	int numchunksghosted;
//	int	maxchunksghostedperframe = 9;
	if(!(cluster.flags & FL_FINDABLE_NONSOLID))	// cluster is new
	{
		cluster.flags = FL_FINDABLE_NONSOLID;
		cluster.enttype = ENT_CLUSTER;
		setorigin(cluster, org);
	}

/*	if(!forceload && self.stagger_initializecluster_ghostchunk)
		chunk = self.stagger_initializecluster_ghostchunk;
	else
		chunk = cluster.list_chunkchain;
	
	for(; chunk; chunk = nextchunk)	// FIXME STAGGER could stagger this?
	{
		nextchunk = chunk.chunkchain;
		GhostChunk(cluster, chunk);
	//	FreeChunkAllocations(chunk);
	//	Remove(chunk);
	
		numchunksghosted++;
	
		if(!forceload)
		if(numchunksghosted == maxchunksghostedperframe)
		if(nextchunk)
		{
			self.stagger_initializecluster_ghostchunk = nextchunk;
			return FALSE;
		}
	}
	
	if(!forceload)
		self.stagger_initializecluster_ghostchunk = __NULL__;*/
	
	return TRUE;
}

void InitializeChunk(entity cluster, entity chunk, vector org)
{
	if(!(chunk.flags & FL_FINDABLE_NONSOLID))
	{
		chunk.flags = FL_FINDABLE_NONSOLID;
		chunk.enttype = ENT_CHUNK;
		setorigin(chunk, org);
	
		if(chunk.numvisiblecubics)
		{
			chunk.SendEntity = SendChunk;
			chunk.SendFlags = chunk.SendFlags | SFL_ISNEW | SFL_BUILD;
		}
		
		ChunkChain_Add(cluster, chunk);
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
				cluster_data[cubicslot0+CUBICSLOT_ROTATION] = chunk.cubic_blockrotation[i];
				cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];				
			}

			SaveChunkQueueChain_Remove(cluster, chunk);
		}
		
		fclose(file);
		SaveClusterQueueChain_Remove(cluster);
	}
}

void SetCubicVisibility(entity chunk, int memslot)
{
	if(chunk.cubic_blocktype[memslot] == 0)
		return;	
	
	int cullbits, nearcullbits, partialside;
	vector nearcubicorg, cubicchunkorg, ofs;
	entity originalchunk = chunk;
	int	originalcullbits = originalchunk.cubic_cullbits[memslot];

	vector cubicorg = chunk.origin + GetCubicOffset(memslot);	
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	partialside = CULLBITS_PARTIAL_D;	break;
			case 1:	ofs = VECOFS_W;	partialside = CULLBITS_PARTIAL_E;	break;
			case 2:	ofs = VECOFS_S;	partialside = CULLBITS_PARTIAL_N;	break;
			case 3:	ofs = VECOFS_E;	partialside = CULLBITS_PARTIAL_W;	break;
			case 4:	ofs = VECOFS_N;	partialside = CULLBITS_PARTIAL_S;	break;
			case 5:	ofs = VECOFS_D;	partialside = CULLBITS_PARTIAL_U;	break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		cubicchunkorg = GetNearChunkOrg(nearcubicorg);
		chunk = GetChunkForLocation(chunk, cubicchunkorg);
		
		
		if(!chunk)	// this needs to be split up or not?
			cullbits = cullbits | bitshift(1, sidecount);
		else
		if(GetCubicStatus(chunk, nearcubicorg, TRUE) != -1)
		{
			nearcullbits = chunk.cubic_cullbits[GetCubicRef(nearcubicorg-chunk.origin)];			
			if(!(nearcullbits & partialside))
				cullbits = cullbits | bitshift(1, sidecount);
		}
	}

	if((cullbits & CULLBITS_ALL) == CULLBITS_ALL)
	if((originalcullbits & CULLBITS_ALL) != CULLBITS_ALL)		
		originalchunk.numvisiblecubics-=1;
	
	if((cullbits & CULLBITS_ALL) != CULLBITS_ALL)
	if((originalcullbits & CULLBITS_ALL) == CULLBITS_ALL)
		originalchunk.numvisiblecubics+=1;

	originalchunk.cubic_cullbits[memslot] = cullbits + (originalcullbits & CULLBITS_PARTIAL_ALL);
}

void SetChunkAsModified(entity chunk)
{
	if(!chunk.SendEntity) // if chunk was previously empty, set it up for networking
	{
		chunk.SendEntity = SendChunk;
		chunk.SendFlags = chunk.SendFlags | SFL_ISNEW;
	}
	
	chunk.SendFlags = chunk.SendFlags | SFL_BUILD;
	entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(chunk.origin));

	SaveClusterQueueChain_Add(cluster);
	SaveChunkQueueChain_Add(cluster, chunk);	
}

void UpdateChunkAreaVisibility(entity chunk, vector cubicorg, int markmodified)
{
	vector ofs, nearcubicorg, cubicchunkorg;
	
	int cubicid = GetCubicRef(cubicorg-chunk.origin);
	SetCubicVisibility(chunk, cubicid);
	if(markmodified)
		SetChunkAsModified(chunk);
	
	entity originalchunk = chunk;
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	break;
			case 1:	ofs = VECOFS_W;	break;
			case 2:	ofs = VECOFS_S;	break;
			case 3:	ofs = VECOFS_E;	break;
			case 4:	ofs = VECOFS_N;	break;
			case 5:	ofs = VECOFS_D;	break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		cubicchunkorg = GetNearChunkOrg(nearcubicorg);
		chunk = GetChunkForLocation(chunk, cubicchunkorg);
		
		if(!chunk)
			continue;
		
		cubicid = GetCubicRef(nearcubicorg - chunk.origin);
		SetCubicVisibility(chunk, cubicid);
		if(chunk != originalchunk)
			SetChunkAsModified(chunk);
	}
}

void UpdateChunkAreaVisibility_OuterEdge(entity chunk)
{
	vector pos, cubicpos;
		
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
			{
				if(pos_x > 0 && pos_x < chunksize-1)
				if(pos_y > 0 && pos_y < chunksize-1)
				if(pos_z > 0 && pos_z < chunksize-1)
					continue;	
					
				cubicpos = pos - ('1 1 1'*((chunksize - !chunksize_iseven)*0.5 - 0.5*chunksize_iseven));
				cubicpos = cubicpos*cubicradius*2;
				cubicpos += chunk.origin;
				
				UpdateChunkAreaVisibility(chunk, cubicpos, FALSE);
			}	
}

vector GetCubicOffsetFromGrid(vector pos)
{
	vector cubicpos = pos - ('1 1 1'*((chunksize - !chunksize_iseven)*0.5 - 0.5*chunksize_iseven));
	cubicpos = cubicpos*cubicradius*2;
	return cubicpos;
}

vector GetChunkOffsetFromGrid(vector pos)
{
	vector org = pos - 0.5*'1 1 1'*(clustersize-1);
	org *= chunksize*cubicradius*2;
	return org;
}

void UpdateClusterAreaVisibility_OuterEdge(entity cluster)
{
	vector pos, cpos, checked, chunkorg;
	entity chunk;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{
				chunkorg = GetChunkOffsetFromGrid(pos)+cluster.origin;	
				chunk = GetChunkForLocation(__NULL__, chunkorg);	
				
				if(!chunk)
					continue;
						
				checked = '0 0 0';
				
				if(pos_x == 0)
				{
					cpos_x = 0;
					checked_x = 1;
					
					for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
				}
				else
				if(pos_x == clustersize-1)
				{
					cpos_x = chunksize-1;
					checked_x = chunksize;
					
					for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
				}
				
				if(pos_y == 0)
				{
					cpos_y = 0;
					checked_y = 1;
					
					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
					}
				}				
				else
				if(pos_y == clustersize-1)
				{
					cpos_y = chunksize-1;
					checked_y = chunksize;
					
					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
					}
				}				

				if(pos_z == 0)
				{
					cpos_z = 0;

					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						{
							if(cpos_y == checked_y-1)
								continue;
							
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
						}
					}
				}				
				else
				if(pos_z == clustersize-1)
				{
					cpos_z = chunksize-1;

					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						{
							if(cpos_y == checked_y-1)
								continue;
							
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
						}
					}
				}
				
				SetChunkAsModified(chunk);
			}	
}

void LoadPrefab_Cluster(vector clusterorg)
{
	entity cluster = GetChunkForLocation(__NULL__, clusterorg);
	if(!cluster)
		return;

	entity chunk;
	int chunkslot0, cubicslot0, i;
	int *cluster_data;
	vector org, pos;
	
	string prefabname = self.prefabfilename;//cvar_string("prefabname");
	
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/", self.netname, "/clusters/", prefabname);
	float file = fopen(filename, FILE_MMAP_READ, sizeof(*cluster_data)*clusterdataslots);
	cluster_data = (int*)fgets(file);
	
	//	cluster_data[CLUSTERSLOT_AVERAGETYPE];
	cluster.numvisiblecubics = cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS];
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{
				org = pos - 0.5*'1 1 1'*(clustersize-1);
				org *= chunksize*cubicradius*2;
				org += clusterorg;
				
				chunk = GetChunkForLocation(__NULL__, org);
	
				chunkslot0 = numprechunkvaluesincluster + GetChunkRef(chunk.origin - clusterorg)*numslotsforchunkincluster;
	
				chunk.chunkbits = cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS];
				chunk.numvisiblecubics = cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS];
	
				for(i = 0; i < pow(chunksize,3); i++)
				{
					cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + i*numvaluespercubic;

					chunk.cubic_blocktype[i] = cluster_data[cubicslot0+CUBICSLOT_TYPE];
					chunk.cubic_blockshape[i] = cluster_data[cubicslot0+CUBICSLOT_SHAPE];
					chunk.cubic_blockrotation[i] = cluster_data[cubicslot0+CUBICSLOT_ROTATION];
					chunk.cubic_cullbits[i] = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];
				}
			}
	
	fclose(file);	
	
	UpdateClusterAreaVisibility_OuterEdge(cluster);

	sprint(self, filename, " loaded.\n");
}

void SavePrefab_Cluster(vector clusterorg)
{
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;

	entity chunk;	
	int chunkslot0, cubicslot0, i;
	int *cluster_data;	
	vector org, pos;
	
	string prefabname = self.prefabfilename;//cvar_string("prefabname");
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/", self.netname, "/clusters/", prefabname);
	float file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
	cluster_data = (int*)fgets(file);
	
	cluster_data[CLUSTERSLOT_AVERAGETYPE] = 0;
	cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS] = cluster.numvisiblecubics;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{
				org = pos - 0.5*'1 1 1'*(clustersize-1);
				org *= chunksize*cubicradius*2;
				org += clusterorg;
				
				chunk = GetChunkForLocation(__NULL__, org);
	
				chunkslot0 = numprechunkvaluesincluster + GetChunkRef(chunk.origin - clusterorg)*numslotsforchunkincluster;
	
				cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS] = chunk.chunkbits;
				cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
	
				for(i = 0; i < pow(chunksize,3); i++)
				{
					cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + i*numvaluespercubic;

					cluster_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
					cluster_data[cubicslot0+CUBICSLOT_SHAPE] = chunk.cubic_blockshape[i];
					cluster_data[cubicslot0+CUBICSLOT_ROTATION] = chunk.cubic_blockrotation[i];
					cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];
				}
			}
	
	fclose(file);
	
	sprint(self, filename, " saved.\n");
}

void AddCluster(vector clusterorg, int type, int shape, int rotation)
{
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;
	
	vector pos, org;
	entity chunk;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{
				org = pos - 0.5*'1 1 1'*(clustersize-1);
				org *= chunksize*cubicradius*2;
				org += clusterorg;
				
				chunk = GetChunkForLocation(__NULL__, org);
				
				if(!chunk)
					continue;
				
				chunk.numvisiblecubics = 0;
				
				for(int i = 0; i < pow(chunksize, 3); i++)
				{
					chunk.cubic_blocktype[i] = type;
					chunk.cubic_blockshape[i] = shape;
					chunk.cubic_blockrotation[i] = rotation;						
					chunk.cubic_cullbits[i] = CULLBITS_ALL;
				}
			}
	
	UpdateClusterAreaVisibility_OuterEdge(cluster);
}

void ClearCluster(vector clusterorg)
{
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;
	
	vector pos;
	entity chunk;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{	
				chunk = GetChunkForLocation(__NULL__, GetChunkOffsetFromGrid(pos)+clusterorg);
				
				if(!chunk)
					return;
				
				chunk.numvisiblecubics = 0;
				
				for(int i = 0; i < pow(chunksize, 3); i++)
				{
					if(chunk.cubic_blocktype[i] > 0)
					{
						entity bbox = GetCubicBBoxForLocation(chunk.origin + GetCubicOffset(i));
						if(bbox)
							Remove(bbox);	// this is just a bbox entity
					}					
					
					chunk.cubic_blocktype[i] = 0;
					chunk.cubic_blockshape[i] = 0;
					chunk.cubic_blockrotation[i] = 0;
					chunk.cubic_cullbits[i] = 0;
				}
			}
			
	UpdateClusterAreaVisibility_OuterEdge(cluster);
}

void LoadPrefab_Chunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	if(!chunk)
		return;

	int cubicslot0;

	int *chunk_data;

	string prefabname = self.prefabfilename;//cvar_string("prefabname");
	
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/", self.netname, "/chunks/", prefabname);
	float file = fopen(filename, FILE_MMAP_READ, sizeof(*chunk_data)*numslotsforchunkincluster);
	chunk_data = (int*)fgets(file);
	
	chunk.chunkbits = chunk_data[CHUNKSLOT_CHUNKBITS];
	chunk.numvisiblecubics = chunk_data[CHUNKSLOT_NUMVISIBLECUBICS];
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+i*numvaluespercubic;

		chunk.cubic_blocktype[i] = chunk_data[cubicslot0+CUBICSLOT_TYPE];
		chunk.cubic_blockshape[i] = chunk_data[cubicslot0+CUBICSLOT_SHAPE];
		chunk.cubic_blockrotation[i] = chunk_data[cubicslot0+CUBICSLOT_ROTATION];		
		chunk.cubic_cullbits[i] = chunk_data[cubicslot0+CUBICSLOT_CULLBITS];
	}
	
	fclose(file);
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	SetChunkAsModified(chunk);
	
	sprint(self, filename, " loaded.\n");
}

void SavePrefab_Chunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	int cubicslot0;
	int *chunk_data;	
	
	string prefabname = self.prefabfilename;//cvar_string("prefabname");
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/", self.netname, "/chunks/", prefabname);
	float file = fopen(filename, FILE_MMAP_RW, sizeof(*chunk_data)*numslotsforchunkincluster);
	chunk_data = (int*)fgets(file);
	
	chunk_data[CHUNKSLOT_CHUNKBITS] = chunk.chunkbits;
	chunk_data[CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
	
	for(int i = 0; i < pow(chunksize,3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+i*numvaluespercubic;

		chunk_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
		chunk_data[cubicslot0+CUBICSLOT_SHAPE] = chunk.cubic_blockshape[i];
		chunk_data[cubicslot0+CUBICSLOT_ROTATION] = chunk.cubic_blockrotation[i];		
		chunk_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];
	}
	
	fclose(file);
	
	sprint(self, filename, " saved.\n");
}

void AddChunk(vector chunkorg, int type, int shape, int rotation)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	chunk.numvisiblecubics = 0;
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		chunk.cubic_blocktype[i] = type;
		chunk.cubic_blockshape[i] = shape;
		chunk.cubic_blockrotation[i] = rotation;		
		chunk.cubic_cullbits[i] = CULLBITS_ALL;
	}
	
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	SetChunkAsModified(chunk);
}

void ClearChunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	chunk.numvisiblecubics = 0;
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		if(chunk.cubic_blocktype[i] > 0)
		{
			entity bbox = GetCubicBBoxForLocation(chunk.origin + GetCubicOffset(i));
			if(bbox)
				Remove(bbox);	// this is just a bbox entity
		}
		
		chunk.cubic_blocktype[i] = 0;
		chunk.cubic_blockshape[i] = 0;
		chunk.cubic_blockrotation[i] = 0;
		chunk.cubic_cullbits[i] = 0;
	}
	
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	
	SetChunkAsModified(chunk);
}

void AddCubic(vector org, int type, int shape, int rotation)
{
	vector cubicchunkorg = GetNearChunkOrg(org);
	entity chunk = GetChunkForLocation(__NULL__, cubicchunkorg);
	
	if(!chunk)
		return;
	
	if(GetCubicStatus(chunk, org, FALSE) != -1)
	{
		dprint("Error: Trying to create cubic where one already exists.\n");
		return;
	}
	
	chunk.numvisiblecubics+=1;
	int i = GetCubicRef(org-cubicchunkorg);
	chunk.cubic_blocktype[i] = type;
	chunk.cubic_blockshape[i] = shape;
	chunk.cubic_blockrotation[i] = rotation;
	chunk.cubic_cullbits[i] = GetPartialSideCullBitsForShape(shape, rotation);
	UpdateChunkAreaVisibility(chunk, org, TRUE);
}

void ClearCubic(entity chunk, vector cubicorg)
{
	if(!chunk)
		return;

	int memslot = GetCubicStatus(chunk, cubicorg, FALSE);
	
	if(memslot == -1)
		return;
	
	int cullbits = chunk.cubic_cullbits[memslot];
	if((cullbits & CULLBITS_ALL) == CULLBITS_ALL)
		return;	// If invisible cubics are ever to be removed in this way, must find out why removing a non-visible cubic causes face drawing errors.		
	
	chunk.numvisiblecubics-=1;
	
	entity bbox = GetCubicBBoxForLocation(cubicorg);
	if(bbox)
		Remove(bbox);	// this is just a bbox entity
	
	chunk.cubic_blocktype[memslot] = 0;
	chunk.cubic_cullbits[memslot] = 0;
	
	UpdateChunkAreaVisibility(chunk, cubicorg, TRUE);
}

// this uses so many seemingly unnecessary chains so that it can be put in last priority for removal.
// this allows clusters to be removed or ghosted first so less clusters need to be triggered for networking removal
void RemoveClustersForPlayerClients()
{
	entity chunk, cluster;//, nextcluster;
//	for(cluster = list_removeclusterforallclientschain; cluster; cluster = nextcluster)
//	{
		cluster = list_removeclusterforallclientschain;
		
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("RemoveClustersForPlayerClients A wasfreed.\n");	
		#endif
		
//		nextcluster = cluster.removeclusterforallclientschain;
		if(cluster)
		{
			for(chunk = cluster.list_chunkchain; chunk; chunk = chunk.chunkchain)
			{
				#ifdef DEBUG
				if(wasfreed(chunk))
					print("RemoveClustersForPlayerClients B wasfreed.\n");		
				#endif
				
				chunk.SendFlags = chunk.SendFlags | SFL_UPDATE; // this triggers a hide
			}
			
			RemoveClusterForAllClientsChain_Remove(cluster);
		}
//	}
}

void RemoveChunkEnt(entity chunk, entity cluster)
{
	FreeChunkAllocations(chunk);
	cluster.chunk_ent[GetChunkRef(chunk.origin-cluster.origin)] = __NULL__;
	
	while(chunk.list_cubicbboxchain)
	{
		#ifdef DEBUG
		if(wasfreed(chunk.list_cubicbboxchain))
			print("RemoveChunkEnt A wasfreed.\n");
		#endif
		
		Remove(chunk.list_cubicbboxchain);
	}
	ChunkChain_Remove(cluster, chunk);
	Remove(chunk);	
}


void RemoveUnoccupiedClusters(int numframesbetweenunloads)
{
	entity cluster, chunk, nextchunk;
//	int	numchunksghosted;
	
	if(!list_unoccupiedclusterchain)
	if(!list_removeclusterforallclientschain)
		return;
	
	if(time >= backgroundunloadtime)	
		backgroundunloadtime = time+frametime*numframesbetweenunloads;
	else
		return;	
	
	if(!list_unoccupiedclusterchain)
	{
		RemoveClustersForPlayerClients();	// triggers chunks SendFlags and SendEntity to stop networking
		return;
	}
	
	cluster = list_unoccupiedclusterchain;
	
	#ifdef DEBUG
	if(wasfreed(cluster))
		print("RemoveUnoccupiedClusters A wasfreed.\n");	
	#endif
	
	if(cluster)
	{
		if(stagger_removeunoccupiedclusters_ghostchunk) // this is disabled
		{
			chunk = stagger_removeunoccupiedclusters_ghostchunk;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("RemoveUnoccupiedClusters B wasfreed.\n");
			#endif
			
			stagger_removeunoccupiedclusters_ghostchunk = __NULL__;
		}
		else
		{
			RemoveClusterForAllClientsChain_Remove(cluster);
			chunk = cluster.list_chunkchain;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("RemoveUnoccupiedClusters C wasfreed.\n");
			#endif
		}			
		
		for(; chunk; chunk = nextchunk) // ghost/remove the whole cluster now
		{
			nextchunk = chunk.chunkchain;
			
//			GhostChunk(cluster, chunk);
			RemoveChunkEnt(chunk, cluster);

//			numchunksghosted++;

/*			if(numchunksghosted == maxchunksghostedperframe)
			if(nextchunk)
			{
				stagger_removeunoccupiedclusters_ghostchunk = nextchunk;
				return;
			}*/
		}
		GhostCluster(cluster);
//		Remove(cluster);
	}
}

void AddPlayerToCluster(entity player, entity cluster)
{
	entity e, chunk;
	
	if(player.viewreset)
		for(chunk = cluster.list_chunkchain; chunk; chunk = chunk.chunkchain)
			chunk.SendFlags = chunk.SendFlags | SFL_BUILD;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("AddPlayerToCluster A wasfreed.\n");
		#endif
		
		if(!e)
		{
			cluster.cluster_playerlist[i] = player;
			return;
		}
		
		if(e == player)
			return;		
	}
}

int RemovePlayerFromCluster(entity player, entity cluster)
{
	entity e;
	int shiftslots = FALSE;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("RemovePlayerFromCluster A wasfreed.\n");
		#endif
		
		if(!e)
			break;
		
		if(!shiftslots)
		if(e == player)
			shiftslots = TRUE;

		if(!shiftslots)
			continue;
			
		if(i+1 == maxplayers)
			e = __NULL__;
		else
			e = cluster.cluster_playerlist[i+1];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("RemovePlayerFromCluster B wasfreed.\n");
		#endif
		
		cluster.cluster_playerlist[i] = e;
		
		if(!e)
			break;
	}
	
	return shiftslots;
}

void UnloadWorldForPlayer(entity player, vector org, int disconnect)
{
	vector dist, pos, clusterpos;
	entity cluster;

	int _maxviewsize = maxviewsize;
	int _maxviewheight = maxviewheight;
	vector _maxviewcenter = maxviewcenter;
	
	if(player.maxviewsize_prev)
	{
		_maxviewsize = player.maxviewsize_prev;
		_maxviewheight = player.maxviewheight_prev;
		_maxviewcenter = player.maxviewcenter_prev;
	}
	
	player.maxviewsize_prev = maxviewsize;
	player.maxviewheight_prev = maxviewheight;
	player.maxviewcenter_prev = maxviewcenter;
	
	for(pos_x = 0; pos_x < _maxviewsize; pos_x++)
		for(pos_y = 0; pos_y < _maxviewsize; pos_y++)
			for(pos_z = 0; pos_z < _maxviewheight; pos_z++)
			{
				if(loadradiusarea)
				{
					dist = pos - _maxviewcenter;
					if(dist*dist > (_maxviewsize*0.5)*(_maxviewsize*0.5))
						continue;
				}
				
				clusterpos = pos - ('1 1 0'*((_maxviewsize - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven));
				clusterpos -= '0 0 1'*((_maxviewheight - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven);
				clusterpos = clusterpos*clustersize*chunksize*cubicradius*2;
				clusterpos += org;
				
				if((clusterpos_x < worlddim_x*-0.5) || (clusterpos_x > worlddim_x*0.5)
				|| (clusterpos_y < worlddim_y*-0.5) || (clusterpos_y > worlddim_y*0.5)
				|| (clusterpos_z < worlddim_z*-0.5) || (clusterpos_z > worlddim_z*0.5))
					continue;

				cluster = GetClusterForLocation(__NULL__, clusterpos);

				if(!cluster)
					continue;

				if(!RemovePlayerFromCluster(player, cluster))
					continue;
				
				if(!disconnect)
					RemoveClusterForClientChain_Add(cluster);	// makes sure chunks update over time if they need to be removed on the client still
				
				cluster.occupantcount-=1;
				
				if(cluster.occupantcount < 1)
					UnoccupiedClusterChain_Add(cluster);
			}
}

entity LoadCluster(entity player, vector pos, int forceload)
{
	int chunkslot0, cubicslot0, count, numchunksloaded;
	entity cluster;
	int *cluster_data;
	float file;
	int i = 0;

	if(!forceload && player.stagger_loadcluster_chunkid)
	{
		i = player.stagger_loadcluster_chunkid;
		player.stagger_loadcluster_chunkid =  0;
		
		cluster = cluster_ent[GetClusterRef(pos)];
		
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("LoadCluster A wasfreed.\n");
		#endif
		
		if(!cluster)
		{
			print("Warning: no cluster\n");
			return __NULL__;
		}
		
		file = player.loadcluster_file;
		cluster_data = player.loadcluster_cluster_data;
	}
	else
	{
	/*	if(!forceload && player.stagger_initializecluster_ghostchunk)
		{
			cluster = cluster_ent[GetClusterRef(pos)];
			file = player.loadcluster_file;
			cluster_data = player.loadcluster_cluster_data;
		}
		else
		{*/
			string filename = strcat(worldpath, itos(GetClusterRef(pos)));
			file = fopen(filename, FILE_MMAP_READ, sizeof(int)*clusterdataslots);
			
			if(file == -1)
			{
				print("Warning: no file found\n");
				return __NULL__;
			}

			cluster_data = (int*)fgets(file);	

			if(!forceload)
			{
				player.loadcluster_file = file;
				player.loadcluster_cluster_data = cluster_data;	
			}
			
			
			if(list_ghostclusterchain)
			{
				cluster = list_ghostclusterchain;
				
				#ifdef DEBUG
				if(wasfreed(cluster))
					print("LoadCluster B wasfreed.\n");	
				#endif
				
				GhostClusterChain_Remove(cluster);
			}
			else
			{
				cluster = spawn();
				cluster.chunk_ent = memalloc(sizeof(entity)*pow(clustersize, 3));
				cluster.cluster_playerlist = memalloc(sizeof(entity)*maxplayers);
			}
			
			if(!clusters_allocated)
			{
				clusters_allocated = TRUE;
				cluster_ent = memalloc(sizeof(entity)*maxclusters);

			}
			
			cluster_ent[GetClusterRef(pos)] = cluster;
			
			cluster.averagetype = cluster_data[CLUSTERSLOT_AVERAGETYPE];	// not used
			cluster.numvisiblecubics = cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS];
	//	}
		
		if(!InitializeCluster(cluster, pos, forceload))	// staggering cluster ghosting here
			return cluster;
	}
	
	for(; i < pow(clustersize, 3); i++)
	{
		chunkslot0 = numprechunkvaluesincluster + i*numslotsforchunkincluster;

		entity chunk;

		if(list_ghostchunkchain)
		{
			chunk = list_ghostchunkchain;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("LoadCluster C wasfreed.\n");	
			#endif
			
			GhostChunkChain_Remove(chunk);
		}
		else
		{
			chunk = spawn();
			chunk.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_blockshape = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_blockrotation = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
		}

		cluster.chunk_ent[i] = chunk;
		
		#ifdef DEBUG
		if(wasfreed(chunk))
			print("Loadcluster D wasfreed.\n");
		#endif
		
		chunk.chunkbits = cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS];
		chunk.numvisiblecubics = cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS];
		InitializeChunk(cluster, chunk, GetChunkOffset(i)+pos);

		for(count = 0; count < pow(chunksize, 3); count++)
		{
			cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + count*numvaluespercubic;
			
			chunk.cubic_blocktype[count] = cluster_data[cubicslot0+CUBICSLOT_TYPE];
			chunk.cubic_blockshape[count] = cluster_data[cubicslot0+CUBICSLOT_SHAPE];
			chunk.cubic_blockrotation[count] = cluster_data[cubicslot0+CUBICSLOT_ROTATION];
			chunk.cubic_cullbits[count] = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];
		}
		
		if(!forceload)
		{
			numchunksloaded++;
			
			if(numchunksloaded == maxchunksloadedperframe)
			if(i+1 < pow(clustersize, 3))
			{
				player.stagger_loadcluster_chunkid = i+1;
				return cluster;
			}
		}
	}
	
/*	if(!forceload)
	{
		player.stagger_loadcluster_chunkid = 0;
	//	lastloadclustercluster = __NULL__;
	}*/
	
	fclose(file);

	return cluster;
}

void SetClusterOccupancyForPlayer(entity player, vector org)
{
	vector dist, pos, clusterpos;
	entity cluster;
	
	float viewedgeA = (maxviewsize-viewsize)*0.5;
	float viewedgeB = maxviewsize-viewedgeA-1;
	float viewedgeC = (maxviewheight-viewheight)*0.5;
	float viewedgeD = maxviewheight-viewedgeC-1;
	float viewedgeE = (maxviewsize-viewsize_distant)*0.5;
	float viewedgeF = maxviewsize-viewedgeE-1;
	float viewedgeG = (maxviewheight-viewheight_distant)*0.5;
	float viewedgeH = maxviewheight-viewedgeG-1;
							
	for(pos_x = 0; pos_x < maxviewsize; pos_x++)
		for(pos_y = 0; pos_y < maxviewsize; pos_y++)
			for(pos_z = 0; pos_z < maxviewheight; pos_z++)
			{
				if(loadradiusarea)
				{
					dist = pos - maxviewcenter;
					if(dist*dist > (maxviewsize*0.5)*(maxviewsize*0.5))
						continue;
				}
				
				if(pos_x < viewedgeA || pos_x > viewedgeB
				|| pos_y < viewedgeA || pos_y > viewedgeB
				|| pos_z < viewedgeC || pos_z > viewedgeD)
				if(pos_x < viewedgeE || pos_x > viewedgeF
				|| pos_y < viewedgeE || pos_y > viewedgeF
				|| pos_z < viewedgeG || pos_z > viewedgeH)
					continue;
			
				clusterpos = pos - ('1 1 0'*((maxviewsize - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven));
				clusterpos -= '0 0 1'*((maxviewheight - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven);				
				clusterpos = clusterpos*clustersize*chunksize*cubicradius*2;
				clusterpos += org;

				if(clusterpos_x < worlddim_x*-0.5 || clusterpos_x > worlddim_x*0.5
				|| clusterpos_y < worlddim_y*-0.5 || clusterpos_y > worlddim_y*0.5
				|| clusterpos_z < worlddim_z*-0.5 || clusterpos_z > worlddim_z*0.5)
					continue;
								
				cluster = GetClusterForLocation(__NULL__, clusterpos);

				if(cluster)
				{
					AddPlayerToCluster(player, cluster);
					cluster.occupantcount++;
					
					RemoveClusterForClientChain_Remove(cluster);
					UnoccupiedClusterChain_Remove(cluster);
				}
			}		
}

int LoadClusterForPlayer(entity player, vector pos, int forceload)
{
	entity cluster;
	
	if(forceload || !player.stagger_loadcluster_chunkid)
	{
		cluster = GetClusterForLocation(__NULL__, pos);

		if(cluster)
			return FALSE;
	}
	
	cluster = LoadCluster(player, pos, forceload);
	
	if(!cluster)
		return FALSE;

	if(!forceload)
	if(player.stagger_loadcluster_chunkid)
		return TRUE;
	
	AddPlayerToCluster(player, cluster);
	cluster.occupantcount++;
	UnoccupiedClusterChain_Remove(cluster);

	return TRUE;
}

int LoadWorldForPlayer(entity player, vector org, int areasize, int areaheight, vector areacenter, int maxclustersloadedperframe, int isbackground, int subsize, int subheight, float numframesbetweenloads)
{
	vector dist, pos, nextpos, lastpos, ofs, clusterpos;
	float scaleval, scaleheightval;
	int numloadedclustersthisframe, stop, getnextpos;

	float loadareaedge = (areasize-subsize)*0.5;
	float loadheightedge = (areaheight-subheight)*0.5;
	
	if(isbackground)
	if(time >= player.backgroundloadtime)	
		player.backgroundloadtime = time+frametime*numframesbetweenloads;
	else
		return TRUE;
	
	if(!isbackground)
		LoadClusterForPlayer(player, org, TRUE);	// immediately loads a cluster around the player
	
	if(player.loadingbackgroundchunks == 1)
		pos = player.lastbackgroundqueuepos;
	else
	if(player.loadingbackgroundchunks == 2)
		pos = player.lastdistantbackgroundqueuepos;
	else
		pos = '0 0 0';
	
	for(; pos_x < areasize && !stop; pos_x++)
	{
		if(getnextpos)
		{
			nextpos = pos;
			stop = TRUE;
			break;
		}		
		
		for(; pos_y < areasize && !stop; pos_y++)
		{
			if(getnextpos)
			{
				nextpos = pos;
				stop = TRUE;
				break;
			}
			
			for(; pos_z < areaheight && !stop; pos_z++)
			{
				if(isbackground)
				if(pos_x >= loadareaedge && pos_x < loadareaedge+subsize
				&& pos_y >= loadareaedge && pos_y < loadareaedge+subsize
				&& pos_z == loadheightedge)
				{
					pos_z += subheight;
					if(pos_z >= areaheight)
						break;
				}
				
				if(getnextpos)
				{
					nextpos = pos;
					stop = TRUE;
					break;
				}
				
				if(loadradiusarea)
				{
					dist = pos - areacenter;
					if(dist*dist > (areasize*0.5)*(areasize*0.5))
						continue;
				}

				scaleval = (areasize-!loadsize_iseven)*0.5 - 0.5*loadsize_iseven;
				scaleheightval = (areaheight-!loadsize_iseven)*0.5 - 0.5*loadsize_iseven;
				ofs = '1 1 0'*scaleval + '0 0 1'*scaleheightval;
				ofs = pos-ofs;
				scaleval = clustersize*chunksize*cubicradius*2;
				clusterpos = ofs*scaleval;
				clusterpos = clusterpos + org;

				if(clusterpos == org)
					continue;
				
				if(clusterpos_x < worlddim_x*-0.5 || clusterpos_x > worlddim_x*0.5
				|| clusterpos_y < worlddim_y*-0.5 || clusterpos_y > worlddim_y*0.5
				|| clusterpos_z < worlddim_z*-0.5 || clusterpos_z > worlddim_z*0.5)
					continue;

				if(LoadClusterForPlayer(player, clusterpos, !isbackground))
				if(isbackground)
				{
					numloadedclustersthisframe++;
					
					if(player.stagger_loadcluster_chunkid)
					{
						lastpos = pos;
						stop = TRUE;
						break;
					}
					else
					if(numloadedclustersthisframe == maxclustersloadedperframe)
						getnextpos = TRUE;
				}
			}
			
			pos_z = 0;
		}
		
		pos_y = 0;
	}
	
	player.lastbackgroundqueuepos = '0 0 0';
	player.lastdistantbackgroundqueuepos = '0 0 0';

	if(isbackground)
	if(stop)
	{
		if(getnextpos)			
			pos = nextpos;
		else
			pos = lastpos;
		
		if(player.loadingbackgroundchunks == 1)
			player.lastbackgroundqueuepos = pos;
		else
		if(player.loadingbackgroundchunks == 2)
			player.lastdistantbackgroundqueuepos = pos;
	}
	
	return stop;
}

void Player_WorldInterface()
{
	if(world_initialized < 3)
		return;

	entity player, e, nexte;
	int updatecount = 0;
	
	float loadwidth = clustersize*chunksize*cubicradius*1.2;
	float loadheight = clustersize*chunksize*cubicradius*1.2;

	for(player = list_playerchain; player; player = player.playerchain)
	{
		#ifdef DEBUG
		if(wasfreed(player))
			print("Player_WorldInterface A wasfreed.\n");	
		#endif
		
		// CHECK WORLD BOUNDS
		if(player.origin_x >= worlddim_x*0.5 || player.origin_x <= worlddim_x*-0.5
		|| player.origin_y >= worlddim_y*0.5 || player.origin_y <= worlddim_y*-0.5
		|| player.origin_z >= worlddim_z*0.5 || player.origin_z <= worlddim_z*-0.5)
			continue;		
			
		if(player.movetype != MOVETYPE_WALK)
			continue;
		
		if(!player.loadingchunks)
		if(!player.loadingbackgroundchunks)
		if(player.origin_x > player.playerclusterorg_x + loadwidth || player.origin_x < player.playerclusterorg_x - loadwidth
		|| player.origin_y > player.playerclusterorg_y + loadwidth || player.origin_y < player.playerclusterorg_y - loadwidth
		|| player.origin_z > player.playerclusterorg_z + loadheight || player.origin_z < player.playerclusterorg_z - loadheight
		|| !player.worldloaded
		|| player.viewreset)
		{
			numplayersloadingfiles++;
			
			player.loadingchunks = TRUE;
			player.loadingbackgroundchunks = TRUE;
			
			if(player.worldloaded)
				UnloadWorldForPlayer(player, player.playerclusterorg, FALSE);
			
			vector newclusterorg = GetNearClusterOrg(player.origin);
			SetClusterOccupancyForPlayer(player, newclusterorg);
			player.playerclusterorg = newclusterorg;
			player.playerclusterid = GetClusterRef(player.playerclusterorg);
			player.viewreset = FALSE;
			
			for(e = list_removeclusterforclientchain; e; e = nexte)
			{
				#ifdef DEBUG
				if(wasfreed(e))
					print("Player_WorldInterface B wasfreed.\n");		
				#endif
				
				nexte = e.removeclusterforclientchain;
				RemoveClusterForAllClientsChain_Add(e); // adds the clusters to stop networking to this player to the master list
				RemoveClusterForClientChain_Remove(e); // clears the temporary list for the next player to use
			}			
		}
	}

	RemoveUnoccupiedClusters(1);

	for(player = list_playerchain; player; player = player.playerchain)
	{
		#ifdef DEBUG
		if(wasfreed(player))
			print("Player_WorldInterface C wasfreed.\n");			
		#endif
		
		// CHECK WORLD BOUNDS
		if(player.origin_x >= worlddim_x*0.5 || player.origin_x <= worlddim_x*-0.5
		|| player.origin_y >= worlddim_y*0.5 || player.origin_y <= worlddim_y*-0.5
		|| player.origin_z >= worlddim_z*0.5 || player.origin_z <= worlddim_z*-0.5)
			continue;
		
		if(player.loadingchunks)
		{
			player.loadingchunks = LoadWorldForPlayer(player, player.playerclusterorg, loadsize, loadsize, loadcenter, pow(loadsize, 3), FALSE, 0, 0, 0);
			player.worldloaded = TRUE;
		}
		else
		if(player.loadingbackgroundchunks == 1)
		{
			if(!LoadWorldForPlayer(player, player.playerclusterorg, viewsize, viewheight, viewcenter, 1, TRUE, loadsize, loadsize, 1))
			{
				player.loadingbackgroundchunks = 2;
				player.lastbackgroundqueuepos = '0 0 0';
			}
		}
		else
		if(player.loadingbackgroundchunks == 2)
		{
			if(!LoadWorldForPlayer(player, player.playerclusterorg, viewsize_distant, viewheight_distant, viewcenter_distant, 1, TRUE, viewsize, viewheight, 1))
			{
				player.loadingbackgroundchunks = FALSE;
				player.lastdistantbackgroundqueuepos = '0 0 0';
				numplayersloadingfiles -= 1;
			}
		}

		LeaveSolidCubics(player, player.lastsolidcubicorigin);
		SetSolidCubics(player, player.origin);
		player.lastsolidcubicorigin = player.origin;
		RemoveUnusedCubicBBoxes();
	}
}

void ClampEditorRotationForShape()
{
	if(self.editor_blockshape == BLOCKSHAPE_RAMP)
	if(self.editor_blockrotation > BLOCKROTATION_CCW_S)
		self.editor_blockrotation-=4;
}

//entity	testbox;
//float	tracetime;
void Player_CubiQuakeControls()
{
	vector org = '0 0 0';
	vector targetpos = '0 0 0';

	if(self.impulse == TOOLSIZE_EDITOR_CUBIC)
		self.toolsize = TOOLSIZE_EDITOR_CUBIC;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CHUNK)
		self.toolsize = TOOLSIZE_EDITOR_CHUNK;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CLUSTER)
		self.toolsize = TOOLSIZE_EDITOR_CLUSTER;
	else
	if(self.impulse == TOOL_EDITOR_REMOVE)
		self.tool = TOOL_EDITOR_REMOVE;
	else
	if(self.impulse == TOOL_EDITOR_ADD)
		self.tool = TOOL_EDITOR_ADD;
	else		
	if(self.impulse == TOOL_EDITOR_COPY)
		self.tool = TOOL_EDITOR_COPY;
	else
	if(self.impulse == TOOL_EDITOR_PASTE)
		self.tool = TOOL_EDITOR_PASTE;
	else
	if(self.impulse == EDITOR_BLOCKTYPE_INCREASE)
	{
		self.editor_blocktype++;
		if(self.editor_blocktype > numblocktypes)
			self.editor_blocktype = 1;
	}
	else
	if(self.impulse == EDITOR_BLOCKTYPE_DECREASE)
	{
		self.editor_blocktype-=1;
		if(self.editor_blocktype < 1)
			self.editor_blocktype = numblocktypes;
	}
	else
	if(self.impulse == EDITOR_BLOCKSHAPE_INCREASE)
	{
		self.editor_blockshape++;
		if(self.editor_blockshape > numblockshapes)
			self.editor_blockshape = 1;	
		ClampEditorRotationForShape();
	}
	else
	if(self.impulse == EDITOR_BLOCKSHAPE_DECREASE)
	{
		self.editor_blockshape-=1;
		if(self.editor_blockshape < 1)
			self.editor_blockshape = numblockshapes;
		ClampEditorRotationForShape();
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_Y_INCREASE)
	{
		self.editor_blockrotation++;
		
		if(self.editor_blockrotation == BLOCKROTATION_S+1)
			self.editor_blockrotation = BLOCKROTATION_E;
		else
		if(self.editor_blockrotation == BLOCKROTATION_CW_S+1)
			self.editor_blockrotation = BLOCKROTATION_CW_E;
		else
		if(self.editor_blockrotation == BLOCKROTATION_UD_S+1)
			self.editor_blockrotation = BLOCKROTATION_UD_E;
		else
		if(self.editor_blockrotation == BLOCKROTATION_CCW_S+1)
			self.editor_blockrotation = BLOCKROTATION_CCW_E;
		else
		if(self.editor_blockrotation == BLOCKROTATION_FW_S+1)
			self.editor_blockrotation = BLOCKROTATION_FW_E;
		else
		if(self.editor_blockrotation == BLOCKROTATION_BW_S+1)
			self.editor_blockrotation = BLOCKROTATION_BW_E;			
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_Y_DECREASE)
	{
		self.editor_blockrotation-=1;
		if(self.editor_blockrotation == BLOCKROTATION_E-1)
			self.editor_blockrotation = BLOCKROTATION_S;
		else
		if(self.editor_blockrotation == BLOCKROTATION_CW_E-1)
			self.editor_blockrotation = BLOCKROTATION_CW_S;
		else
		if(self.editor_blockrotation == BLOCKROTATION_UD_E-1)
			self.editor_blockrotation = BLOCKROTATION_UD_S;
		else
		if(self.editor_blockrotation == BLOCKROTATION_CCW_E-1)
			self.editor_blockrotation = BLOCKROTATION_CCW_S;
		else
		if(self.editor_blockrotation == BLOCKROTATION_FW_E-1)
			self.editor_blockrotation = BLOCKROTATION_FW_S;
		else
		if(self.editor_blockrotation == BLOCKROTATION_BW_E-1)
			self.editor_blockrotation = BLOCKROTATION_BW_S;		
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_XZ_INCREASE)
	{
		self.editor_blockrotation+=4;
		if(self.editor_blockshape == BLOCKSHAPE_RAMP && self.editor_blockrotation > BLOCKROTATION_CCW_S)
			self.editor_blockrotation = self.editor_blockrotation-(BLOCKROTATION_CCW_S+1);	
		else
		if(self.editor_blockrotation > BLOCKROTATION_BW_S)
			self.editor_blockrotation = self.editor_blockrotation-(BLOCKROTATION_BW_S+1);			
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_XZ_DECREASE)
	{
		self.editor_blockrotation-=4;
		if(self.editor_blockrotation < BLOCKROTATION_E)
		if(self.editor_blockshape == BLOCKSHAPE_RAMP)
			self.editor_blockrotation = (BLOCKROTATION_CCW_S+1) + self.editor_blockrotation;
		else
			self.editor_blockrotation = (BLOCKROTATION_BW_S+1) + self.editor_blockrotation;
	}
	else
	if(self.impulse == CLIENT_TOGGLELIGHT)
		stuffcmd(self, "toggleclientlight\n");
	else	
	if(self.impulse)	// this turns off edit mode if any impulses not related to it are used
		self.tool = 0;

	if(self.button0)
	{
		if(self.button0_down < 2)
			self.button0_down++;
	}
	else
		self.button0_down = FALSE;

/*	if(time > tracetime)
	{
		tracetime = time+0.06;
		makevectors(self.v_angle);
		targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*20;
		vector tracepostest = TraceCubic(self.origin+self.view_ofs, targetpos, TRUE);
		setorigin(testbox, tracepostest);
	}*/
	
	if(self.tool >= TOOL_EDITOR_REMOVE && self.tool <= TOOL_EDITOR_PASTE)	
	if(self.button0_down == 1)
	{
		if(self.loadingchunks || self.loadingbackgroundchunks)
			centerprint(self, "Slow down.\nChunks are loading.\nYou can't use tools yet.");
		else
		{
			int getinside = FALSE;
			
			if(self.tool == TOOL_EDITOR_REMOVE || self.tool == TOOL_EDITOR_COPY)
				getinside = TRUE;
			
			makevectors(self.v_angle);
			targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*20;
			vector tracepos = TraceCubic(self.origin+self.view_ofs, targetpos, getinside);

			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(tracepos, chunksize_iseven);	break;
				case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(tracepos);							break;
				case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(tracepos);							break;
			}

			if(!ToolIsOnEdge(self.playerclusterorg, org))
			if(self.tool == TOOL_EDITOR_ADD)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		AddCubic(GetNearestCubicOrigin(tracepos, chunksize_iseven), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation);	break;
					case TOOLSIZE_EDITOR_CHUNK:		AddChunk(GetNearChunkOrg(tracepos), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation);							break;
					case TOOLSIZE_EDITOR_CLUSTER:	AddCluster(GetNearClusterOrg(tracepos), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation);						break;
				}
			}
			else
			if(self.tool == TOOL_EDITOR_REMOVE)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(tracepos));
													vector cubicorg = GetNearestCubicOrigin(tracepos, chunksize_iseven);
													ClearCubic(chunk, cubicorg);													break;
					case TOOLSIZE_EDITOR_CHUNK:		ClearChunk(GetNearChunkOrg(tracepos));											break;
					case TOOLSIZE_EDITOR_CLUSTER:	ClearCluster(GetNearClusterOrg(tracepos));										break;
				}		
			}
			else
			if(self.tool == TOOL_EDITOR_COPY)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:																						break;
					case TOOLSIZE_EDITOR_CHUNK:		SavePrefab_Chunk(GetNearChunkOrg(tracepos));									break;
					case TOOLSIZE_EDITOR_CLUSTER:	SavePrefab_Cluster(GetNearClusterOrg(tracepos));								break;
				}		
			}
			else
			if(self.tool == TOOL_EDITOR_PASTE)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:																						break;
					case TOOLSIZE_EDITOR_CHUNK:		LoadPrefab_Chunk(GetNearChunkOrg(tracepos));									break;
					case TOOLSIZE_EDITOR_CLUSTER:	LoadPrefab_Cluster(GetNearClusterOrg(tracepos));								break;
				}		
			}
		}
	}	
}

void UninitializePlayers()
{
	for(entity e = list_playerchain; e; e = e.playerchain)
	{
		#ifdef DEBUG
		if(wasfreed(e))
			print("UninitializePlayers A wasfreed.\n");	
		#endif
		
		e.client_initialized = FALSE;
		e.viewreset = TRUE;
	}
}

void SetLoadDistanceValues()
{
	viewsize = max(1, cvar("viewdist1"))*2 + 1;
	viewheight = max(1, cvar("viewheight1"))*2 + 1;
	viewsize_distant = max(1, cvar("viewdist2"))*2 + 1;
	viewheight_distant = max(1, cvar("viewheight2"))*2 + 1;
	SetDependentViewValues();
}

void SetAmbientLight()
{
	ambientlight = stov(cvar_string("ambientlight"));	
}

void InitServerCubics()
{
//	testbox = spawn();
//	setmodel(testbox, "models/editor/cubeselector.mdl");

	maxplayers = 0;
	for(entity p = world; (p=nextent(p)); maxplayers++) {}
	
//	maxplayers = bound(1, cvar("maxclients"), 255);

	clientstat(STAT_TOOL, EV_INTEGER, tool);
	clientstat(STAT_TOOLSIZE, EV_INTEGER, toolsize);
	clientstat(STAT_EDITOR_BLOCKTYPE, EV_INTEGER, editor_blocktype);
	clientstat(STAT_EDITOR_BLOCKSHAPE, EV_INTEGER, editor_blockshape);
	clientstat(STAT_EDITOR_BLOCKROTATION, EV_INTEGER, editor_blockrotation);
	clientstat(STAT_PLAYERCLUSTERID, EV_INTEGER, playerclusterid);	
	
	int *world_data;	
	worldpath = strcat("worlds/", cvar_string("worldname"), "/");
	string filename = strcat(worldpath, "world_data");
	float file = fopen(filename, FILE_MMAP_READ, sizeof(int)*numworldslots);
	
	if(file != -1) // world exists
	{
		world_data = (int*)fgets(file);
		worldsize = world_data[WORLDSLOT_WORLDSIZE];
		fclose(file);
		world_initialized = 3;
	}
	else // create new world
	{
		file = fopen(filename, FILE_MMAP_RW, sizeof(int)*numworldslots);
		world_data = (int*)fgets(file);
		worldsize = floor(cvar("worldsize"));
		print("Reading worldsize: ", itos(worldsize), "\n");
		if(worldsize/2 == floor(worldsize/2))
		{
			worldsize+=1;
			print("Increasing worldsize to ", itos(worldsize), " to make it odd.\n");
		}
		world_data[WORLDSLOT_WORLDSIZE] = worldsize;
		fclose(file);
	}
	
//	forceinfokey(world, "worldsize", itos(worldsize));
	
//	world_ent = spawn();
//	world_ent.cluster_ent = memalloc(sizeof(entity)*worldsize*worldsize*worldheight);
	
	SetLoadDistanceValues();
	SetAmbientLight();
	
	InitGameVariables();
	SharedPrecaches();
}

void StartFrame_Cubics()
{
	if(world_initialized < 3)
		GenerateWorld();
	else
	{	
		ProjectileUpdate();	// see sv_attacks.qc for examples
		SaveModifiedClusterFiles();
		Player_WorldInterface();
	}
}