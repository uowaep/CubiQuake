.int		averagetype;
.int		occupantcount;
.int		worldloaded;
.int		loadingchunks;
.int		loadingbackgroundchunks;
.int		backgroundloadtime;
.int		backgroundunloadtime;
.int		visingchunks;
.vector		lastbackgroundqueuepos;
.vector		lastdistantbackgroundqueuepos;
int			numplayersloadingfiles;
.vector		playerclusterorg;
.int		playerclusterid;
.vector		client_initialized;

.int		tool;
.int		toolsize;

float SendChunk(entity viewer, float sendflags)
{
	int type, cullbits, sentcount;

	if(!self.numvisiblecubics)
		return FALSE;
	
//	vector dist = self.origin - viewer.origin;
//	if(dist*dist > chunk_sharerange*chunk_sharerange)
//		return FALSE;
	
	WriteByte(MSG_ENTITY, ENT_CHUNK);
	WriteLong(MSG_ENTITY, sendflags);
	
	if(!viewer.client_initialized)
	{
		WriteLong(MSG_ENTITY, worldsize);
		viewer.client_initialized = TRUE;
	}
	
	if(sendflags & SFL_ISNEW)
		WriteLong(MSG_ENTITY, GetChunkOriginRef(self.origin));
	
	if(sendflags & SFL_BUILD)
	{
		WriteShort(MSG_ENTITY, self.numvisiblecubics);

		if(self.numvisiblecubics > 0)
		for(int count = 0; sentcount < self.numvisiblecubics; count++)
		{
			type = self.cubic_blocktype[count];
			cullbits = self.cubic_cullbits[count];
			
			if(type)
			if(cullbits != CULLBITS_ALL)
			{
				WriteShort(MSG_ENTITY, count);
				WriteByte(MSG_ENTITY, type);
				WriteByte(MSG_ENTITY, cullbits);
				sentcount++;
			}
		}
	}	
	
	return TRUE;
}

entity GetCubicBBoxForLocation(vector cubicorg)
{
	for(entity bbox = findradius(cubicorg, 0); bbox; bbox = bbox.chain)
		if(bbox.enttype == ENT_CUBICBBOX)
			return bbox;

	return __NULL__;	
}

// int GetIDSlotForChunkInCluster(int i)	{	return i*((pow(chunksize, 3)*numvaluespercubic)+numprecubicvaluesinchunk);		}

void FreeChunkAllocations(entity chunk)
{
	memfree(chunk.cubic_cullbits);
	memfree(chunk.cubic_blocktype);	
}

void InitializeCluster(entity cluster, vector org)
{
	entity nextchunk;
	
	if(!(cluster.flags & FL_FINDABLE_NONSOLID))
	{
		cluster.flags = FL_FINDABLE_NONSOLID;
		cluster.enttype = ENT_CLUSTER;
		setorigin(cluster, org);
	//	setsize(cluster, '-1 -1 -1'*clustersize*chunksize*cubicradius, '1 1 1'*clustersize*chunksize*cubicradius);
	//	ClusterChain_Add(cluster);
	}

	for(entity chunk = cluster.list_chunkchain; chunk; chunk = nextchunk)
	{
		nextchunk = chunk.chunkchain;
		FreeChunkAllocations(chunk);
		Remove(chunk);
	}
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
//	else
//		FreeChunkAllocations(chunk);
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
		nextcluster = cluster.saveclusterqueuechain;
		
		filename = strcat(worldpath, itos(GetClusterRef(cluster.origin)));
		file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
		cluster_data = (int*)fgets(file);
		
		for(chunk = cluster.list_savechunkqueuechain; chunk; chunk = nextchunk)
		{
			nextchunk = chunk.savechunkqueuechain;
			
			clusterchunkid = GetChunkRef(chunk.origin-cluster.origin);
			chunkslot0 = numprechunkvaluesincluster + clusterchunkid*numslotsforchunkincluster;

			cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
			
			for(i = 0; i < pow(chunksize, 3); i++)
			{
				cubicslot0 = chunkslot0+numprecubicvaluesinchunk+i*numvaluespercubic;

				cluster_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
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
	
	int cullbits;
	vector nearcubicorg, cubicchunkorg, ofs;
	entity originalchunk = chunk;
	int	originalcullbits = originalchunk.cubic_cullbits[memslot];
	
	vector cubicorg = chunk.origin + GetCubicOffset(memslot);	
	
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
			cullbits = cullbits | bitshift(1, sidecount);
		else
		if(GetCubicStatus(chunk, nearcubicorg) != -1)
			cullbits = cullbits | bitshift(1, sidecount);
	}

	if(cullbits == CULLBITS_ALL)
	if(originalcullbits != CULLBITS_ALL)		
		originalchunk.numvisiblecubics-=1;
	
	if(cullbits != CULLBITS_ALL)
	if(originalcullbits == CULLBITS_ALL)
		originalchunk.numvisiblecubics+=1;
	
	originalchunk.cubic_cullbits[memslot] = cullbits;
}

void SetChunkAsModified(entity chunk)
{
	if(!chunk.SendEntity)
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
	
	string prefabname = cvar_string("prefabname");
	
	if(strlen(prefabname) < 1)
	{
		print("Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/clusters/", prefabname);
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
					chunk.cubic_cullbits[i] = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];
				}
			}
	
	fclose(file);	
	
	UpdateClusterAreaVisibility_OuterEdge(cluster);

	print(filename, " loaded.\n");
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
	
	string prefabname = cvar_string("prefabname");
	if(strlen(prefabname) < 1)
	{
		print("Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/clusters/", prefabname);
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
					cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];
				}
			}
	
	fclose(file);
	
	print(filename, " saved.\n");
}

void AddCluster(vector clusterorg, int type)
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
					chunk.cubic_cullbits[i] = CULLBITS_ALL;
				}
			}
	
	UpdateClusterAreaVisibility_OuterEdge(cluster);
}

void RemoveCluster(vector clusterorg)
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

	string prefabname = cvar_string("prefabname");
	
	if(strlen(prefabname) < 1)
	{
		print("Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/chunks/", prefabname);
	float file = fopen(filename, FILE_MMAP_READ, sizeof(*chunk_data)*numslotsforchunkincluster);
	chunk_data = (int*)fgets(file);
	
	chunk.chunkbits = chunk_data[CHUNKSLOT_CHUNKBITS];
	chunk.numvisiblecubics = chunk_data[CHUNKSLOT_NUMVISIBLECUBICS];
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+i*numvaluespercubic;

		chunk.cubic_blocktype[i] = chunk_data[cubicslot0+CUBICSLOT_TYPE];
		chunk.cubic_cullbits[i] = chunk_data[cubicslot0+CUBICSLOT_CULLBITS];
	}
	
	fclose(file);
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	SetChunkAsModified(chunk);
	
	print(filename, " loaded.\n");
}

void SavePrefab_Chunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	int cubicslot0;
	int *chunk_data;	
	
	string prefabname = cvar_string("prefabname");
	if(strlen(prefabname) < 1)
	{
		print("Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/chunks/", prefabname);
	float file = fopen(filename, FILE_MMAP_RW, sizeof(*chunk_data)*numslotsforchunkincluster);
	chunk_data = (int*)fgets(file);
	
	chunk_data[CHUNKSLOT_CHUNKBITS] = chunk.chunkbits;
	chunk_data[CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
	
	for(int i = 0; i < pow(chunksize,3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+i*numvaluespercubic;

		chunk_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
		chunk_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];
	}
	
	fclose(file);
	
	print(filename, " saved.\n");
}

void AddChunk(vector chunkorg, int type)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	chunk.numvisiblecubics = 0;
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		chunk.cubic_blocktype[i] = type;
		chunk.cubic_cullbits[i] = CULLBITS_ALL;
	}
	
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	SetChunkAsModified(chunk);
}

void RemoveChunk(vector chunkorg)
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
		chunk.cubic_cullbits[i] = 0;
	}
	
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	
	SetChunkAsModified(chunk);
}

void AddCubic(vector org, int type)
{
	vector cubicchunkorg = GetNearChunkOrg(org);
	entity chunk = GetChunkForLocation(__NULL__, cubicchunkorg);
	
	if(!chunk)
		return;
	
	if(GetCubicStatus(chunk, org) != -1)
	{
		dprint("Error: Trying to create cubic where one already exists.\n");
		return;
	}
	
	chunk.numvisiblecubics+=1;
	int i = GetCubicRef(org-cubicchunkorg);
	chunk.cubic_blocktype[i] = type;
	UpdateChunkAreaVisibility(chunk, org, TRUE);
}

void RemoveCubic(entity chunk, vector cubicorg)
{
	if(!chunk)
		return;

	int memslot = GetCubicStatus(chunk, cubicorg);
	
	if(memslot == -1)
		return;
	
	if(chunk.cubic_cullbits[memslot] == CULLBITS_ALL)
		return;	// If invisible cubics are ever to be removed in this way, must find out why removing a non-visible cubic causes face drawing errors.		
	
	chunk.numvisiblecubics-=1;
	
	entity bbox = GetCubicBBoxForLocation(cubicorg);
	if(bbox)
		Remove(bbox);	// this is just a bbox entity
	
	chunk.cubic_blocktype[memslot] = 0;
	chunk.cubic_cullbits[memslot] = 0;
	
	UpdateChunkAreaVisibility(chunk, cubicorg, TRUE);
}

void RemoveUnoccupiedClusters(int numframesbetweenunloads)
{
	entity cluster, chunk, nextchunk;
	
	if(!list_unoccupiedclusterchain)
		return;
	
	if(time >= self.backgroundunloadtime)	
		self.backgroundunloadtime = time+frametime*numframesbetweenunloads;
	else
		return;	
	
	cluster = list_unoccupiedclusterchain;
	
	if(cluster)
	{
		for(chunk = cluster.list_chunkchain; chunk; chunk = nextchunk)
		{
			nextchunk = chunk.chunkchain;
			FreeChunkAllocations(chunk);
			Remove(chunk);
		}
		
		Remove(cluster);
	}
}

void UnloadWorldForPlayer(vector org)
{
	vector dist, pos, clusterpos;
	entity cluster;
	
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
				
				clusterpos = pos - ('1 1 0'*((maxviewsize - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven));
				clusterpos -= '0 0 1'*((maxviewheight - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven);
				clusterpos = clusterpos*clustersize*chunksize*cubicradius*2;
				clusterpos += org;
				
				if((clusterpos_x < worlddim_x*-0.5) || (clusterpos_x > worlddim_x*0.5)
				|| (clusterpos_y < worlddim_y*-0.5) || (clusterpos_y > worlddim_y*0.5)
				|| (clusterpos_z < worlddim_z*-0.5) || (clusterpos_z > worlddim_z*0.5))
					continue;

				cluster = GetClusterForLocation(__NULL__, clusterpos);

				if(!cluster)
					continue;

				cluster.occupantcount-=1;
				
				if(cluster.occupantcount < 1)
					UnoccupiedClusterChain_Add(cluster);
			}
}

entity LoadCluster(vector pos)
{
	int i, chunkslot0, cubicslot0, type, cullbits, count;

	string filename = strcat(worldpath, itos(GetClusterRef(pos)));
	float file = fopen(filename, FILE_MMAP_READ, sizeof(int)*clusterdataslots);
	
	if(file == -1)
	{
		print("no file found\n");
		return __NULL__;
	}

	int *cluster_data = (int*)fgets(file);	
	
	entity cluster = spawn();
	
	cluster.averagetype = cluster_data[CLUSTERSLOT_AVERAGETYPE];
	cluster.numvisiblecubics = cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS];
	
	InitializeCluster(cluster, pos);
	
	for(i = 0; i < pow(clustersize, 3); i++)
	{
		chunkslot0 = numprechunkvaluesincluster + i*numslotsforchunkincluster;

		entity chunk = spawn();
		chunk.chunkbits = cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS];
		chunk.numvisiblecubics = cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS];
		InitializeChunk(cluster, chunk, GetChunkOffset(i)+pos);

		chunk.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
		chunk.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
		
		for(count = 0; count < pow(chunksize, 3); count++) 
		{
			cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + count*numvaluespercubic;
			
			type = cluster_data[cubicslot0+CUBICSLOT_TYPE];
			cullbits = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];

			chunk.cubic_blocktype[count] = type;
			chunk.cubic_cullbits[count] = cullbits;
		}
	}
	
	fclose(file);
	
	return cluster;
}

void SetClusterOccupancyForPlayer(vector org)
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
					cluster.occupantcount++;
					UnoccupiedClusterChain_Remove(cluster);
				}
			}		
}

int LoadClusterForPlayer(vector pos)
{

	entity cluster = GetClusterForLocation(__NULL__, pos);

	if(cluster)
		return FALSE;

	cluster = LoadCluster(pos);
	
	if(!cluster)
		return FALSE;
	
	cluster.occupantcount++;
	return TRUE;
}

int LoadWorldForPlayer(vector org, int areasize, int areaheight, vector areacenter, int maxclustersloadedperframe, int isbackground, int subsize, int subheight, float numframesbetweenloads)
{
	vector dist, pos, ofs, clusterpos;
	float scaleval, scaleheightval;
	int numloadedclustersthisframe, stop;
	
	float loadareaedge = (areasize-subsize)*0.5;
	float loadheightedge = (areaheight-subheight)*0.5;
	
	if(isbackground)
	if(time >= self.backgroundloadtime)	
		self.backgroundloadtime = time+frametime*numframesbetweenloads;
	else
		return TRUE;
	
	if(!isbackground)
		LoadClusterForPlayer(org);
	
	if(self.loadingbackgroundchunks == 1)
		pos = self.lastbackgroundqueuepos;
	else
	if(self.loadingbackgroundchunks == 2)
		pos = self.lastdistantbackgroundqueuepos;
	
	for(pos_x = 0; pos_x < areasize && !stop; pos_x++)
	{
		for(pos_y = 0; pos_y < areasize && !stop; pos_y++)
		{
			for(pos_z = 0; pos_z < areaheight && !stop; pos_z++)
			{
				if(isbackground)
				if(pos_x >= loadareaedge && pos_x < loadareaedge+subsize
				&& pos_y >= loadareaedge && pos_y < loadareaedge+subsize
				&& pos_z == loadheightedge)
					pos_z += subheight;				
				
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

				if(LoadClusterForPlayer(clusterpos))
				{
					numloadedclustersthisframe++;
					if(numloadedclustersthisframe >= maxclustersloadedperframe)
						stop = TRUE;
				}
			}	
		}
		
		if(isbackground)
		if(pos == '1 1 0'*(areasize-1) + '1 1 0'*(areaheight-1))
			pos = '0 0 0';
	}
			
	if(self.loadingbackgroundchunks == 1)
		self.lastbackgroundqueuepos = pos;
	else
	if(self.loadingbackgroundchunks == 2)
		self.lastdistantbackgroundqueuepos = pos;
			
	return stop;
}

.int		button0_down;
void Player_WorldInterface()
{
	if(world_initialized < 3)
		return;

	// CHECK WORLD BOUNDS
	if(self.origin_x >= worlddim_x*0.5 || self.origin_x <= worlddim_x*-0.5
	|| self.origin_y >= worlddim_y*0.5 || self.origin_y <= worlddim_y*-0.5
	|| self.origin_z >= worlddim_z*0.5 || self.origin_z <= worlddim_z*-0.5)
		return;		
	
	float loadwidth = clustersize*chunksize*cubicradius*1.2;
	float loadheight = clustersize*chunksize*cubicradius*1.2;
	
	if(self.origin_x > self.playerclusterorg_x + loadwidth || self.origin_x < self.playerclusterorg_x - loadwidth
	|| self.origin_y > self.playerclusterorg_y + loadwidth || self.origin_y < self.playerclusterorg_y - loadwidth
	|| self.origin_z > self.playerclusterorg_z + loadheight || self.origin_z < self.playerclusterorg_z - loadheight
	|| !self.worldloaded)
	{
		if(!(self.loadingchunks || self.loadingbackgroundchunks))
			numplayersloadingfiles++;
		
		self.loadingchunks = TRUE;
		self.loadingbackgroundchunks = TRUE;
		
		if(self.worldloaded)
			UnloadWorldForPlayer(self.playerclusterorg);
		
		vector newclusterorg = GetNearClusterOrg(self.origin);
		SetClusterOccupancyForPlayer(newclusterorg);
		self.playerclusterorg = newclusterorg;
		self.playerclusterid = GetClusterRef(self.playerclusterorg);
	}

	RemoveUnoccupiedClusters(1);
	
	if(self.loadingchunks)
	{
		self.loadingchunks = LoadWorldForPlayer(self.playerclusterorg, loadsize, loadsize, loadcenter, pow(loadsize, 3), FALSE, 0, 0, 0);
		self.worldloaded = TRUE;
	}
	else
	if(self.loadingbackgroundchunks == 1)
	{
		if(!LoadWorldForPlayer(self.playerclusterorg, viewsize, viewheight, viewcenter, 1, TRUE, loadsize, loadsize, 3))
			self.loadingbackgroundchunks = 2;
	}
	else
	if(self.loadingbackgroundchunks == 2)
	{
		if(!LoadWorldForPlayer(self.playerclusterorg, viewsize_distant, viewheight_distant, viewcenter_distant, 1, TRUE, viewsize, viewheight, 4))
		{
			self.loadingbackgroundchunks = FALSE;
			numplayersloadingfiles -= 1;
		}
	}

	LeaveSolidCubics(self, self.lastsolidcubicorigin);
	SetSolidCubics(self, self.origin);
	self.lastsolidcubicorigin = self.origin;
	RemoveUnusedCubicBBoxes();
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
	if(self.impulse)
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
	if(!self.loadingchunks)
	if(!self.loadingbackgroundchunks)
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
				case TOOLSIZE_EDITOR_CUBIC:		AddCubic(GetNearestCubicOrigin(tracepos, chunksize_iseven), BLOCKTYPE_BRICK);	break;
				case TOOLSIZE_EDITOR_CHUNK:		AddChunk(GetNearChunkOrg(tracepos), BLOCKTYPE_BRICK);							break;
				case TOOLSIZE_EDITOR_CLUSTER:	AddCluster(GetNearClusterOrg(tracepos), BLOCKTYPE_BRICK);						break;
			}
		}
		else
		if(self.tool == TOOL_EDITOR_REMOVE)
		{
			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(tracepos));
												vector cubicorg = GetNearestCubicOrigin(tracepos, chunksize_iseven);
												RemoveCubic(chunk, cubicorg);												break;
				case TOOLSIZE_EDITOR_CHUNK:		RemoveChunk(GetNearChunkOrg(tracepos));											break;
				case TOOLSIZE_EDITOR_CLUSTER:	RemoveCluster(GetNearClusterOrg(tracepos));										break;
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

void InitServerCubics()
{
//	testbox = spawn();
//	setmodel(testbox, "models/editor/cubeselector.mdl");
	
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
	
	InitGameVariables();	
	SharedPrecaches();

	clientstat(STAT_TOOL, EV_INTEGER, tool);
	clientstat(STAT_TOOLSIZE, EV_INTEGER, toolsize);
	clientstat(STAT_PLAYERCLUSTERID, EV_INTEGER, playerclusterid);
}

void StartFrame_Cubics()
{
	if(world_initialized < 3)
		GenerateWorld();
	else
	{	
		ProjectileUpdate();	// see sv_attacks.qc for examples
		SaveModifiedClusterFiles();
	}
}