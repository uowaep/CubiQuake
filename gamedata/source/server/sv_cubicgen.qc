int		world_initialized;
string	worldpath;
string	chunkgenqueue_string;
int		generating_clusterid;
int		totalvised;
int		numchunks;
int		numchunksgeneratedthisframe;
int		maxchunkstogenerateperframe = 1;

int CheckNullChunk(int *cluster_data, int chunkslot0)
{
	int chunkbits = cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS];
	
	if(chunkbits & CHUNKBITS_CORPOREAL)
		return FALSE;
	
	return TRUE;
}

int WriteChunk(vector chunkpos, int *cdata)
{
	float file = 0;
	int count = 0, chunkslot0 = 0, slot = 0, newwrite = 0;
	int *cluster_data;
	
	vector clusterpos = GetNearClusterOrg(chunkpos);	
	int chunkref = GetChunkRef(chunkpos-clusterpos, __FUNC__);

	string filename = strcat(worldpath, itos(GetClusterRef(clusterpos)));
	file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
	cluster_data = (int*)fgets(file);

	cluster_data[CLUSTERSLOT_VERSION] = cq_version;

	chunkslot0 = numprechunkvaluesincluster + chunkref*numslotsforchunkincluster;
	
	if(CheckNullChunk(cluster_data, chunkslot0))
		newwrite = TRUE;
	
	cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS] = CHUNKBITS_CORPOREAL;
	cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = 0;		// numvisiblecubics
	
	for(count = 0; count < pow(chunksize, 3)*numvaluespercubic; count++)
	{
		slot = chunkslot0+numprecubicvaluesinchunk+count;
		cluster_data[slot] = cdata[count];
	}

	fclose(file);

	return newwrite;	
}

//vector GetCubicOffsetForGeneration(vector pos)	{	return (pos+'-1 -1 -1'*chunksize*0.5)*cubicradius*2 + '1 1 1'*cubicradius;	}

int ChunkGen_SetCubic(int *cdata, int type, int cubicslot0)
{
	cdata[cubicslot0+CUBICSLOT_TYPE]		= type;
	cdata[cubicslot0+CUBICSLOT_SHAPE]		= BLOCKSHAPE_CUBE;
	cdata[cubicslot0+CUBICSLOT_ROTATION]	= BLOCKROTATION_E;
	cdata[cubicslot0+CUBICSLOT_CULLBITS]	= 0;
	cdata[cubicslot0+CUBICSLOT_HEALTH]		= 100;
	
	cubicslot0 += numvaluespercubic;
	
	return cubicslot0;
}

// CHUNK TYPES

void GenChunk_Sky(vector chunkpos, int *cdata)
{
	vector pos = '0 0 0';
	int cubicslot0 = 0;
	
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
				cubicslot0 = ChunkGen_SetCubic(cdata, 0, cubicslot0);
}

void GenChunk_Surface(vector chunkpos, int *cdata)
{
	int type = 0, cubicslot0 = 0;
	vector pos = '0 0 0';

	float potholechance = 0.05;
	int zheight = floor(chunksize*0.5);
	float slopevariance = 0;
	float slopechangerate = 0.2;

	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
		{
			slopevariance += slopechangerate - random()*slopechangerate*2;
			zheight = bound(1, zheight+floor(random()*slopevariance), chunksize-1);
		
			for(pos_z = 0; pos_z < chunksize; pos_z++)
			{
				if( (pos_z == zheight && random() < potholechance ) || pos_z > zheight)
					type = 0;
				else
					type = max(1, ceil(random()*numrandomtextureblocktypes));
				
				cubicslot0 = ChunkGen_SetCubic(cdata, type, cubicslot0);
			}
		}
}

void GenChunk_Surface_Old(vector chunkpos, int *cdata)
{
	int type = 0, cubicslot0 = 0;
	vector pos = '0 0 0';

	int zheight = floor(chunksize*0.5);
	float slopevariance = 0;
	float slopechangerate = 0.2;

	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
		{
			slopevariance += slopechangerate - random()*slopechangerate*2;
			zheight = bound(1, zheight+floor(random()*slopevariance), chunksize-1);
		
			for(pos_z = 0; pos_z < chunksize; pos_z++)
			{
				if( (pos_z == zheight && !rint(random()) ) || pos_z > zheight)
					type = 0;
				else
					type = max(1, ceil(random()*numrandomtextureblocktypes));
				
				cubicslot0 = ChunkGen_SetCubic(cdata, type, cubicslot0);
			}
		}
}

void GenChunk_Solid(vector chunkpos, int *cdata)
{
	vector pos = 0;
	int cubicslot0 = 0, blocktype = 0;
	
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
			{
				if(gen_type == GEN_TYPE_FLAT)
					blocktype = 1;
				else
					blocktype = max(1, ceil(random()*numrandomtextureblocktypes));
				
				cubicslot0 = ChunkGen_SetCubic(cdata, blocktype, cubicslot0);
			}
}

int GenSpawnChunk_Wasteland(vector chunkpos)
{
	int surfacelevel = -1*(chunksize*cubicradius*2);
	int *cdata = memalloc(sizeof(int)*pow(chunksize, 3)*numvaluespercubic);
		
	if(chunkpos_z < surfacelevel)
		GenChunk_Solid(chunkpos, cdata);
	else
	if(chunkpos_z == surfacelevel && gen_type != GEN_TYPE_FLAT)
		GenChunk_Surface(chunkpos, cdata);
	else
		GenChunk_Sky(chunkpos, cdata);
	
	int newwrite = WriteChunk(chunkpos, cdata);
	memfree(cdata);
	
	return newwrite;
}

void QueueChunk(vector pos)
{
	// CHECK WORLD BOUNDS
	if(pos_x > worlddim_x*0.5 || pos_x < worlddim_x*-0.5
	|| pos_y > worlddim_y*0.5 || pos_y < worlddim_y*-0.5
	|| pos_z > worlddim_z*0.5 || pos_z < worlddim_z*-0.5)
		return;			
	
	int id = 0;
	int chunkid = GetChunkOriginRef(pos);	

	int numtokens = tokenize(chunkgenqueue_string);
	for(int count = 0; count < numtokens; count++)
	{
		id = stoi(argv(count));
		if(id == chunkid)
			return;
	}	
	
	vector clusterorg = GetNearClusterOrg(pos);
	int clusterid = GetClusterRef(clusterorg);
	int chunkclusterid = GetChunkRef(pos-clusterorg, __FUNC__);

	// CHECK IF CHUNK ALREADY EXISTS ON FILE BEFORE ADDING TO GENERATION QUEUE
	int chunkslot0;

	string filename = strcat(worldpath, itos(clusterid));
	float file = fopen(filename, FILE_MMAP_READ);//, sizeof(int)*clusterdataslots);

	if(file != -1)
	{
		int *cluster_data = (int*)fgets(file);
		chunkslot0 = numprechunkvaluesincluster + chunkclusterid*numslotsforchunkincluster;
			
		if(!CheckNullChunk(cluster_data, chunkslot0))
		{
			fclose(file);
			return;
		}
		
		fclose(file);
	}	

	// ADD TO GEN QUEUE
	chunkgenqueue_string = strcat(chunkgenqueue_string, itos(chunkid), " ");
}

void GenerateChunks_Wasteland(vector chunkpos)
{
	vector ofs = '0 0 0', nearchunkpos = '0 0 0';
	
	// Write chunk to disk here
	if(!GenSpawnChunk_Wasteland(chunkpos))
		return;
	
	numchunksgeneratedthisframe++;
	numchunks++;
		
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
		
		nearchunkpos = chunkpos + ofs*chunksize*cubicradius*2;
		QueueChunk(nearchunkpos);
	}
}

void GenCubicVisibility()
{
	int cullbits = 0, nearcullbits = 0, chunkslot0 = 0, cubicslot0B = 0, i = 0, cubicnum = 0, clusterid = 0, cubicslot0 = 0, chunk_numvisiblecubics = 0, nearclusterid = 0, nearchunkid = 0, nearcubicid = 0, partialside = 0;
	vector nearcubicorg = '0 0 0', nearchunkorg = '0 0 0', nearclusterorg = '0 0 0', clusterorg = '0 0 0', chunkorg = '0 0 0';
	int maxvised = 1;
	float file = 0, fileB = 0;
	entity e = __NULL__;
	vector ofs = '0 0 0';
	vector cubicchunkorg = '0 0 0';
	int numvised = 0, totalvisiblecubicsincluster = 0;
	int *cluster_data = __NULL__;
	int *cluster_dataB = __NULL__;
	
//	for(clusterid = maxclusters-1; clusterid >= 0 && numvised < maxvised; clusterid-=1)	
	for(clusterid = generating_clusterid; clusterid < maxclusters && numvised < maxvised; clusterid++)
	{
		numvised++;
		totalvised++;

		string filename = strcat(worldpath, itos(clusterid));
		file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);

		if(file < 0)
		{
			print("Error: Trying to open file that doesn't exist. A\n");
			continue;
		}
		
		cluster_data = (int*)fgets(file);
		clusterorg = GetClusterOffset(clusterid);
		
		for(i = 0; i < pow(clustersize, 3); i++)
		{
			chunkslot0 = numprechunkvaluesincluster + i*numslotsforchunkincluster;
			
			if(CheckNullChunk(cluster_data, chunkslot0))
			{
				print("found null chunk at ", vtos(clusterorg + GetChunkOffset(i)), "\n");
				continue;
			}

			chunkorg = clusterorg + GetChunkOffset(i);
			chunk_numvisiblecubics = pow(chunksize, 3);
			
			for(cubicnum = 0; cubicnum < pow(chunksize, 3); cubicnum++)
			{
				cubicslot0 = chunkslot0+numprecubicvaluesinchunk+cubicnum*numvaluespercubic;
				vector cubicorg = chunkorg + GetCubicOffset(cubicnum);
				cullbits = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];
			//	cullbits = cullbits - (cullbits & CULLBITS_ALL);	// cleans up prefab dirt (should put this in prefabsetup)

				if(cluster_data[cubicslot0+CUBICSLOT_TYPE] == 0) // no type (empty space)
				{		
					chunk_numvisiblecubics-=1;	
					continue;
				}
				
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
					
					if(nearcubicorg_x > worlddim_x*0.5 || nearcubicorg_x < worlddim_x*-0.5
					|| nearcubicorg_y > worlddim_y*0.5 || nearcubicorg_y < worlddim_y*-0.5
					|| nearcubicorg_z > worlddim_z*0.5 || nearcubicorg_z < worlddim_z*-0.5)
					{
						cullbits = cullbits | bitshift(1, sidecount);
						continue;
					}
					
					nearchunkorg = GetNearChunkOrg(nearcubicorg);
					nearclusterorg = GetNearClusterOrg(nearchunkorg);
					nearclusterid = GetClusterRef(nearclusterorg);					
					nearchunkid = GetChunkRef(nearchunkorg-nearclusterorg, __FUNC__);
					nearcubicid = GetCubicRef(nearcubicorg-nearchunkorg);
					
					fileB = 0;
					
					if(nearclusterid != clusterid)
					{
						string filenameB = strcat(worldpath, itos(nearclusterid));
						fileB = fopen(filenameB, FILE_MMAP_READ, sizeof(*cluster_dataB)*clusterdataslots);

						if(fileB < 0)
						{
							print("Error: Trying to open file that doesn't exist. B\n");
							cullbits = cullbits | bitshift(1, sidecount);
							continue;
						}
						
						cluster_dataB = (int*)fgets(fileB);
					}
					else
						cluster_dataB = cluster_data;
					
					cubicslot0B = numprechunkvaluesincluster + nearchunkid*numslotsforchunkincluster + numprecubicvaluesinchunk + nearcubicid*numvaluespercubic;
					if(cluster_dataB[cubicslot0B+CUBICSLOT_TYPE] != 0) // TYPE is not empty
					{
						nearcullbits = cluster_dataB[cubicslot0B+CUBICSLOT_CULLBITS];			
						if(!(nearcullbits & partialside))
							cullbits = cullbits | bitshift(1, sidecount);
					}
					
					
					if(fileB > 0)
						fclose(fileB);
				}
				
				if((cullbits & CULLBITS_ALL) == CULLBITS_ALL)
					chunk_numvisiblecubics-=1;	
					
				cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = cullbits;
			}
			
			cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = chunk_numvisiblecubics;
			totalvisiblecubicsincluster += chunk_numvisiblecubics;
		}
		
	//	cluster_data[CLUSTERSLOT_AVERAGETYPE] = cluster_averagetype
		cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS] = totalvisiblecubicsincluster;
		
		fclose(file);
	}
	
	if(clusterid == maxclusters)
	{
		generating_clusterid = 0;
		world_initialized = 3;
	}
	else
	{
		generating_clusterid = clusterid;
		for(e = list_playerchain; e; e = e.playerchain)
			centerprint(e, "Culling Faces: ", itos(totalvised*pow(clustersize, 3)*pow(chunksize, 3)*6), "/", itos(maxclusters*pow(clustersize, 3)*pow(chunksize, 3)*6), "\n");
	}
}

void GenerateWorld_Wasteland() // FIXME: the wasteland and flatland generators use a string for the queue still :P
{
	string s = __NULL__, token = __NULL__;
	int id = 0, tokenlen = 0;
	vector pos = '0 0 0';

	numchunksgeneratedthisframe = 0;
	
	if(!world_initialized)
	{
		world_initialized = 1;
		GenerateChunks_Wasteland('0 0 -1'*chunksize*cubicradius*2);
	}
	else
	if(world_initialized == 1)
	{
		while(strlen(chunkgenqueue_string) && numchunksgeneratedthisframe < maxchunkstogenerateperframe)
		{
			s = substring(chunkgenqueue_string, 0, 10); // 10 sets it at almost 10 billion. cutting the string there saves on tokens to generate. we only need the first one.
			tokenize(s);
			token = argv(0);
			id = stoi(token);
			tokenlen = strlen(token);

			chunkgenqueue_string = substring(chunkgenqueue_string, tokenlen+1, strlen(chunkgenqueue_string)-(tokenlen+1));	
			pos = GetChunkOrigin(id);

			GenerateChunks_Wasteland(pos);
			
			if(numchunks >= maxchunks || strlen(chunkgenqueue_string) == 0)
			{
				world_initialized = 2;
				chunkgenqueue_string = __NULL__;
				break;
			}
			
			for(entity e = list_playerchain; e; e = e.playerchain)
				centerprint(e, "Chunks Generated: ", ftos(numchunks), "/", ftos(maxchunks), "\n");
		}
	}
	else
	if(world_initialized == 2)
	{
		GenCubicVisibility();
	}
}



// DIRT CHUNKS


void GenerateChunks_Dirt(vector chunkpos)
{
	vector clusterpos = GetNearClusterOrg(chunkpos);
	int clusterid = GetClusterRef(clusterpos);
	string filename = strcat(worldpath, itos(clusterid));
	float file = fopen(filename, FILE_MMAP_READ);

	if(file != -1)
	{
		int *cluster_data = (int*)fgets(file);
		int chunkslot0 = numprechunkvaluesincluster + GetChunkRef(chunkpos-clusterpos, __FUNC__)*numslotsforchunkincluster;
			
		if(!CheckNullChunk(cluster_data, chunkslot0))
		{
			fclose(file);
			numchunksgeneratedthisframe++; // just to avoid going over on the main loop
			return;
		}
		
		fclose(file);
	}	
	
	int *cdata = memalloc(sizeof(int)*pow(chunksize, 3)*numvaluespercubic);
	GenChunk_Solid(chunkpos, cdata);
	
	if(WriteChunk(chunkpos, cdata)) // not a new chunk for some reason?
		numchunks++;
	numchunksgeneratedthisframe++;	
	memfree(cdata);
}


// DUNGEON GEN START

int RotateBlockRotationYaw(int rotation)
{
	rotation-=1;
	
	if(rotation == BLOCKROTATION_E-1)
		rotation = BLOCKROTATION_S;
	else
	if(rotation == BLOCKROTATION_CW_E-1)
		rotation = BLOCKROTATION_CW_S;
	else
	if(rotation == BLOCKROTATION_UD_E-1)
		rotation = BLOCKROTATION_UD_S;
	else
	if(rotation == BLOCKROTATION_CCW_E-1)
		rotation = BLOCKROTATION_CCW_S;
	else
	if(rotation == BLOCKROTATION_FW_E-1)
		rotation = BLOCKROTATION_FW_S;
	else
	if(rotation == BLOCKROTATION_BW_E-1)
		rotation = BLOCKROTATION_BW_S;		
	
	return rotation;
}

void RotateChunkYaw(int *cdata)
{
	int i = 0, tempi = 0, slot0 = 0, val = 0;
	int *tempcdata = memalloc(sizeof(int)*(numprefabgenvaluesinchunk+numslotsforchunkincluster));
	vector ipos = '0 0 0', tpos = '0 0 0';
	
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0];
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+1] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+2];
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+2] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+3];
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+3] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+4];
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+4] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+1];
	tempcdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+5] = cdata[PREFABCHUNKSLOT_CHUNKSIDETYPE_0+5];

	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+1] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+2];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+2] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+3];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+3] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+4];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+4] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+1];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+5] = cdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+5];
	
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+1] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+2];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+2] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+3];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+3] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+4];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+4] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+1];
	tempcdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+5] = cdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+5];

	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0];
	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0+1] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0+2];
	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0+2] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0+3];
	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0+3] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0+4];
	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0+4] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0+1];
	tempcdata[PREFABCHUNKSLOT_GROUPSIZE_0+5] = cdata[PREFABCHUNKSLOT_GROUPSIZE_0+5];
	
	tempcdata[PREFABCHUNKSLOT_ZONE] = cdata[PREFABCHUNKSLOT_ZONE];
	tempcdata[PREFABCHUNKSLOT_CHANCE] = cdata[PREFABCHUNKSLOT_CHANCE];
	tempcdata[PREFABCHUNKSLOT_CHUNKFLAGS] = cdata[PREFABCHUNKSLOT_CHUNKFLAGS];
	
	tempcdata[numprefabgenvaluesinchunk+CHUNKSLOT_CHUNKBITS] = cdata[numprefabgenvaluesinchunk+CHUNKSLOT_CHUNKBITS];
	tempcdata[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS] = cdata[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS];
	
	for(i = 0; i < pow(chunksize, 3); i++)
	{
		ipos = GetCubicOffset(i);
		
		tpos_x = ipos_y;
		tpos_y = ipos_x*-1;
		tpos_z = ipos_z;

		tempi = numprecubicvaluesinchunk+numprefabgenvaluesinchunk + GetCubicRef(tpos)*numvaluespercubic;

		slot0 = numprecubicvaluesinchunk+numprefabgenvaluesinchunk + i*numvaluespercubic;
		
		tempcdata[tempi+CUBICSLOT_TYPE]		= cdata[slot0+CUBICSLOT_TYPE];
		tempcdata[tempi+CUBICSLOT_SHAPE]	= cdata[slot0+CUBICSLOT_SHAPE];
		tempcdata[tempi+CUBICSLOT_ROTATION]	= RotateBlockRotationYaw(cdata[slot0+CUBICSLOT_ROTATION]);
		tempcdata[tempi+CUBICSLOT_CULLBITS]	= GetPartialSideCullBitsForShape(tempcdata[tempi+CUBICSLOT_TYPE], tempcdata[tempi+CUBICSLOT_SHAPE], tempcdata[tempi+CUBICSLOT_ROTATION]);
		tempcdata[tempi+CUBICSLOT_HEALTH]	= cdata[slot0+CUBICSLOT_HEALTH];
	}
	
	for(i = 0; i < numprefabgenvaluesinchunk+numslotsforchunkincluster; i++)
	{
		val = tempcdata[i];
		cdata[i] = val;
	}
	
	memfree(tempcdata);
}

void FixCullBits(int *cdata)
{
	int i = 0, slot0 = 0;

	for(i = 0; i < pow(chunksize, 3); i++)
	{
		slot0 = numprecubicvaluesinchunk+numprefabgenvaluesinchunk + i*numvaluespercubic;
		cdata[slot0+CUBICSLOT_CULLBITS]	= GetPartialSideCullBitsForShape(cdata[slot0+CUBICSLOT_TYPE], cdata[slot0+CUBICSLOT_SHAPE], cdata[slot0+CUBICSLOT_ROTATION]);
	}

}

void FixPrefabChunkDataForOldVersions(int *cdata)
{
	float f = 0;
	int slot0 = 0, oldver_slot0 = 0, old_datasize = 0;
	int datasize = numprefabgenvaluesinchunk+numslotsforchunkincluster;	

	int version = cdata[PREFABCHUNKSLOT_VERSION];

	if(version <= 161)
	{
		old_datasize = olda_numprefabgenvaluesinchunk+numprecubicvaluesinchunk + pow(chunksize, 3)*olda_numvaluespercubic;
	
		for(int i = 1; i <= pow(chunksize, 3); i++)
		{
			slot0 = datasize - i*numvaluespercubic;
			oldver_slot0 = old_datasize - i*olda_numvaluespercubic;
			
			if(cdata[oldver_slot0+CUBICSLOT_TYPE])
				cdata[slot0+CUBICSLOT_HEALTH] = 100;
			else
				cdata[slot0+CUBICSLOT_HEALTH] = 0;
			cdata[slot0+CUBICSLOT_CULLBITS] = cdata[oldver_slot0+CUBICSLOT_CULLBITS];
			cdata[slot0+CUBICSLOT_ROTATION] = cdata[oldver_slot0+CUBICSLOT_ROTATION];
			cdata[slot0+CUBICSLOT_SHAPE] = cdata[oldver_slot0+CUBICSLOT_SHAPE];
			cdata[slot0+CUBICSLOT_TYPE] = cdata[oldver_slot0+CUBICSLOT_TYPE];
		}

		cdata[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS] = cdata[28];	// r161		(27+1)
		cdata[numprefabgenvaluesinchunk+CHUNKSLOT_CHUNKBITS] = cdata[27];			// r161		(27+0)

		cdata[PREFABCHUNKSLOT_CHUNKFLAGS] = cdata[26];	// PREFABCHUNKSLOT_CHUNKFLAGS = 26;	 r161
		// don't really need to load the version here
	}
}

/*int GetZoneIDForName(string zonename)
{
	for(int i = 0; i < numzones; i++)
		if(zonelist[i] == zonename)
			return i;
		
	return -1;
}*/

/*void SetupZones(int generating)
{
	int zonenum = 0;
	string s;	
	string filename = "data/prefabs/worldgen/zones.txt";
	file = fopen(filename, FILE_READ);

	if(file == -1)
		return;
	
	for(s = fgets(file); s; s = fgets(file))
		numzones++;
	
	fclose(file);
	
	zonelist = memalloc(sizeof(zonelist)*numzones);

	file = fopen(filename, FILE_READ);

	for(s = fgets(file); s; s = fgets(file))
	{
		tokenize(s);
		zonelist[zonenum] = zonecpy(zonelist[zonenum], argv(0));
		print("Adding Zone: ", argv(0), "\n");
		zonenum++;
	}
}*/

/*void RemoveZones()
{
	memfree(zonelist);
	numzones = 0;
}*/

void SetupPrefabs()
{
	string s = __NULL__, filename = __NULL__;
	entity prefab;
	int i = 0, rotation = 0;
	int *chunk_data;
	float file = 0;
	
	float h = search_begin("data/prefabs/worldgen/*", FALSE, FALSE);
	float n = search_getsize(h);

	for(int count = 0; count < n; count++)
	{
		s = search_getfilename(h, count);
		filename = substring(s, 5, strlen(s)-5);
		print(filename, " prefab found.\n");
		
		file = fopen(filename, FILE_MMAP_READ, sizeof(*chunk_data)*(numprefabgenvaluesinchunk+numslotsforchunkincluster));
		chunk_data = (int*)fgets(file);
		
		FixPrefabChunkDataForOldVersions(chunk_data);
		
		if(substring(filename, 0, 22) == "prefabs/worldgen/fill_")
		{
			i = stoi(substring(filename, 22, strlen(filename)-22));

			FixCullBits(chunk_data);
			
			prefab = spawn();
			prefab_zonefill[i] = prefab;
			prefab.prefabdata = memalloc(sizeof(int)*(numprefabgenvaluesinchunk+numslotsforchunkincluster));

			for(i = 0; i < numslotsforchunkincluster+numprefabgenvaluesinchunk; i++)
				prefab.prefabdata[i] = chunk_data[i];
			
			prefab.prefabdata[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS] = 0;
		}
		else
		for(rotation = 0; rotation < 4; rotation++)
		{
			if(rotation)
				RotateChunkYaw(chunk_data);
			else
				FixCullBits(chunk_data);
			
			prefab = spawn();
			PrefabTypeChain_Add(prefab);		
			prefab.prefabdata = memalloc(sizeof(int)*(numprefabgenvaluesinchunk+numslotsforchunkincluster));
			prefab.prefabdata_temp = memalloc(sizeof(int)*6);
			
			if(filename == "prefabs/worldgen/corner1")
				prefab.colormod = '1 0.8 0.8';			
			
			for(i = 0; i < numslotsforchunkincluster+numprefabgenvaluesinchunk; i++)
				prefab.prefabdata[i] = chunk_data[i];

			prefab.prefabdata[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS] = 0;

			prefab.genrotation = rotation;			
			prefab.genzone = prefab.prefabdata[PREFABCHUNKSLOT_ZONE];
			prefab.prefabchunkflags = prefab.prefabdata[PREFABCHUNKSLOT_CHUNKFLAGS];
		}
		
		fclose(file);
	}
	
	search_end(h);
}

/* this comment is purely for my function list to not break (because of the file search string above) :P
*/

void RemovePrefabs()
{
	entity prefab = __NULL__, nexte = __NULL__;
	
	for(prefab = list_prefabtypechain; prefab; prefab = nexte)
	{
		nexte = prefab.prefabtypechain;
		memfree(prefab.prefabdata);
		PrefabTypeChain_Remove(prefab);
		Remove(prefab);
	}
	
	for(int count = 0; count < numzones; count++)
	{
		prefab = prefab_zonefill[count];
		if(prefab)
		{
			prefab_zonefill[count] = __NULL__;
			Remove(prefab);
		}
	}
}

void CopyPrefabData(int *cdata, entity prefab)
{
	for(int count = 0; count < numslotsforchunkincluster; count++)
		cdata[count] = prefab.prefabdata[count+numprefabgenvaluesinchunk+numprecubicvaluesinchunk];
}

int SubtractConnectionFromGenChunk(entity chunk)
{
	chunk.lookingforconnections-=1;
	if(!chunk.lookingforconnections)	// this entity isn't needed anymore
	{
	//	memfree(chunk.infoedit_chunksidedata);
		UnconnectedChunkChain_Remove(chunk);
		Remove(chunk);
		return TRUE;
	}	
	
	return FALSE;
}

int GenerateChunks_Dungeon(entity forechunk, vector chunkpos, int forceopen, int forcesolid, int suppresschance, int vertical)
{
	float file = 0, totalchance = 0;
	vector groupmins = '0 0 0', groupmaxs = '0 0 0', ofs = '0 0 0', nearchunkpos = '0 0 0', nearclusterpos = '0 0 0';
	int count = 0, forechunkside = 0, insidedungeon = 0, groupdoesntfit = 0, foundpassage = 0, foundchunk = 0, expandingpassage = 0, createpassage = 0, newchunksidecount = 0, oppositeside = 0, nearchunkref = 0, chunkslot0 = 0, sidecount = 0, prefabside_type = 0, prefabside_fit = 0, matchside_type = 0, matchside_fit = 0, matchside_flags = 0, matchside_rotation = 0, matchside_zone = 0, matchside_prefabchunkflags = 0, nummatchingprefabs = 0, forcedconnectiontype = 0, nomatch = 0, requireone = 0, connecting_requireone = 0;
	string filename = __NULL__;
	int *cluster_data;
	int side_type[6] = {0};
	int side_fit[6] = {0};
	int side_flags[6] = {0};
	int side_rotation[6] = {0};
	int side_zone[6] = {0};
	int side_prefabchunkflags[6] = {0};
	entity nearchunk = __NULL__, prefab = __NULL__, nexte = __NULL__, chunk = __NULL__, useprefab = __NULL__, e = __NULL__, stepchunk = __NULL__,lastent = __NULL__;
	float grouppadding = 0;//chunksize*cubicradius*2*2;

	// ANALYZING THE SPACE
	
/*	nearclusterpos = GetNearClusterOrg(chunkpos);
	filename = strcat(worldpath, itos(GetClusterRef(nearclusterpos)));
	file = fopen(filename, FILE_MMAP_READ);

	if(file != -1)
	{
		cluster_data = (int*)fgets(file);
		nearchunkref = GetChunkRef(chunkpos-nearclusterpos);
		chunkslot0 = numprechunkvaluesincluster + nearchunkref*numslotsforchunkincluster;
			
		if(!CheckNullChunk(cluster_data, chunkslot0))
			return 2;	// chunk is already here
			
		fclose(file);
	}*/

	int *cdata = memalloc(sizeof(int)*pow(chunksize, 3)*numvaluespercubic);
	
	if(!forcesolid)
	for(sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	oppositeside = 5;	forcedconnectiontype = CHUNKCONNECTION_CLOSED;	break;
			case 1:	ofs = VECOFS_W;	oppositeside = 3;	forcedconnectiontype = CHUNKCONNECTION_CLOSED;	break;
			case 2:	ofs = VECOFS_S;	oppositeside = 4;	forcedconnectiontype = CHUNKCONNECTION_OPENED;	break;
			case 3:	ofs = VECOFS_E;	oppositeside = 1;	forcedconnectiontype = CHUNKCONNECTION_OPENED;	break;
			case 4:	ofs = VECOFS_N;	oppositeside = 2;	forcedconnectiontype = CHUNKCONNECTION_OPENED;	break;
			case 5:	ofs = VECOFS_D;	oppositeside = 0;	forcedconnectiontype = CHUNKCONNECTION_CLOSED;	break;
		}
		
		nearchunkpos = chunkpos + ofs*chunksize*cubicradius*2;
		
		side_type[sidecount] = 0;
		side_fit[sidecount] = 0;
		side_flags[sidecount] = 0;
		side_rotation[sidecount] = 0;
		side_zone[sidecount] = -1;
		side_prefabchunkflags[sidecount] = 0;
		
		if(nearchunkpos_x > dungeondim_x*0.5 || nearchunkpos_x < dungeondim_x*-0.5
		|| nearchunkpos_y > dungeondim_y*0.5 || nearchunkpos_y < dungeondim_y*-0.5
		|| nearchunkpos_z > dungeondim_z*0.5 || nearchunkpos_z < dungeondim_z*-0.5)
		{
			side_type[sidecount] = CHUNKCONNECTION_EDGE;
			continue;
		}
		
		if(forceopen)	// for debugging
		{
			side_type[sidecount] = forcedconnectiontype;
			continue;
		}
		
		for(nearchunk = list_unconnectedchunkchain; nearchunk && nearchunk.genorg != nearchunkpos; nearchunk = nearchunk.unconnectedchunkchain){}
		
		if(nearchunk)
		{
			side_type[sidecount] = nearchunk.infoedit_chunksidedata[oppositeside];
			side_fit[sidecount] = nearchunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+oppositeside];
			side_flags[sidecount] = nearchunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+oppositeside];
			side_rotation[sidecount] = nearchunk.genrotation;
			side_zone[sidecount] = nearchunk.genzone;
			side_prefabchunkflags[sidecount] = nearchunk.prefabchunkflags;
			
			if(nearchunk == forechunk)
			{
				forechunkside = sidecount;
				if(side_type[sidecount] == CHUNKCONNECTION_PASSAGE)
					expandingpassage = TRUE;
			}
			
			if(side_type[sidecount] != CHUNKCONNECTION_GENERATED) // if the near side is closed then don't close it again
			if(nearchunk != forechunk)	// forechunk will handle this after this function is finished so skip if forechunk
			{
				nearchunk.infoedit_chunksidedata[oppositeside] = CHUNKCONNECTION_GENERATED;
				SubtractConnectionFromGenChunk(nearchunk);
			}

			if(side_type[sidecount] == CHUNKCONNECTION_ANY || side_type[sidecount] == CHUNKCONNECTION_RANDOM)
				side_type[sidecount] = CHUNKCONNECTION_OPENED; // keeps the path opened
			
			if(side_type[sidecount] == CHUNKCONNECTION_GENERATED)
				side_type[sidecount] = CHUNKCONNECTION_CLOSED;
		}
		else
		{
			foundchunk = FALSE;
			nearclusterpos = GetNearClusterOrg(nearchunkpos);
			filename = strcat(worldpath, itos(GetClusterRef(nearclusterpos)));
			file = fopen(filename, FILE_MMAP_READ);

			if(file != -1)
			{
				cluster_data = (int*)fgets(file);
				nearchunkref = GetChunkRef(nearchunkpos-nearclusterpos, __FUNC__);
				chunkslot0 = numprechunkvaluesincluster + nearchunkref*numslotsforchunkincluster;
					
				if(CheckNullChunk(cluster_data, chunkslot0))
					side_type[sidecount] = CHUNKCONNECTION_FREE;	// no chunk here yet, so free for connections
				else
				{
					side_type[sidecount] = CHUNKCONNECTION_CLOSED;	//since this chunk wasn't in the unconnected chain, we know it's not looking for a connection here
					foundchunk = TRUE;
				}
				
				fclose(file);
			}
			
			if(!foundchunk)
			{
		/*		for(count = 0; count < 6; count++)
				{				
					if(count == oppositeside)
						continue;
			
					switch(count)
					{
						case 0:	ofs = VECOFS_U;		oppositesideb = 5;	break;
						case 1:	ofs = VECOFS_W;		oppositesideb = 3;	break;
						case 2:	ofs = VECOFS_S;		oppositesideb = 4;	break;
						case 3:	ofs = VECOFS_E;		oppositesideb = 1;	break;
						case 4:	ofs = VECOFS_N;		oppositesideb = 2;	break;
						case 5:	ofs = VECOFS_D;		oppositesideb = 0;	break;
					}
			
					neargenchunkpos = nearchunkpos + ofs*chunksize*cubicradius*2;
				
					for(nearchunk = list_unconnectedchunkchain; nearchunk && nearchunk.genorg != neargenchunkpos; nearchunk = nearchunk.unconnectedchunkchain){}
				
					if(nearchunk)
				//	if(nearchunk.genzone != forechunk.genzone)
				//	{
				//		foundchunk = TRUE;
				//		side_type[sidecount] = CHUNKCONNECTION_CLOSED;
				//		break;
				//	}
				//	else
				//	if(nearchunk.infoedit_chunksidedata[oppositesideb] == CHUNKCONNECTION_OPENED)
					{
						foundchunk = TRUE;
						side_type[sidecount] = CHUNKCONNECTION_OPENED;
						break;
					}
				}
				// FIXME check queue for a different zone generating in this space and set to CLOSED if zones don't match
				*/
				if(!foundchunk)
					side_type[sidecount] = CHUNKCONNECTION_FREE;	// no chunk, which means it's free to connect or stay closed
				
			}
		}
	}
	
	if(!forcesolid)
	if(numchunkssincepassage >= chunksperpassage)
		createpassage = TRUE;

	// FIND A PREFAB TO USE IN THE SPACE
	
	// check every prefab to see what can fit here (there's one for each of 4 rotations, generated prior to world generation)
	if(!forcesolid)
	for(prefab = list_prefabtypechain; prefab; prefab = prefab.prefabtypechain)
	{
		// assume a match on each prefab until something doesn't fit
		nomatch = FALSE;
		requireone = FALSE;
		connecting_requireone = FALSE;
		foundpassage = FALSE;
		groupdoesntfit = FALSE;
		insidedungeon = FALSE;
		
		for(sidecount = 0; sidecount < 6; sidecount++)
		{
			prefab.prefabdata_temp[sidecount] = prefab.prefabdata[sidecount];
			if(prefab.prefabdata_temp[sidecount] == CHUNKCONNECTION_RANDOM)
			{
				if(random() < 0.5)
					prefab.prefabdata_temp[sidecount] = CHUNKCONNECTION_OPENED;
				else
					prefab.prefabdata_temp[sidecount] = CHUNKCONNECTION_CLOSED;
			}
		}
		
		for(sidecount = 0; sidecount < 6; sidecount++)
		{
			if(prefab.prefabdata_temp[sidecount] == CHUNKCONNECTION_PASSAGE)
			{
				foundpassage = TRUE;
				break;
			}
		}

		if(createpassage)
		if(!foundpassage)
			continue;
	
		if(!createpassage)
		if(foundpassage)
		if(!expandingpassage)
			continue;
		
		if(createpassage)
		if(!expandingpassage)
		{
		//	prefabside_fit = 0;
			for(sidecount = 0; sidecount < 6; sidecount++)
			{
			//	prefabside_fit = prefab.prefabdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidecount];
				
				groupmaxs_z = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+0];
				groupmins_x = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+1];
				groupmins_y = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+2];
				groupmaxs_x = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+3];
				groupmaxs_y = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+4];
				groupmins_z = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+5];
				
				if(groupmins != '0 0 0' || groupmaxs != '0 0 0')
			//	if(prefabside_fit)
				{
				/*	groupmaxs_z = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+0];
					groupmins_x = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+1];
					groupmins_y = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+2];
					groupmaxs_x = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+3];
					groupmaxs_y = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+4];
					groupmins_z = prefab.prefabdata[PREFABCHUNKSLOT_GROUPSIZE_0+5];*/

					groupmins = chunkpos + groupmins*chunksize*cubicradius*-2;
					groupmaxs = chunkpos + groupmaxs*chunksize*cubicradius*2;

					if(groupmaxs_x+grouppadding <= dungeondim_x*0.5)
					if(groupmins_x-grouppadding >= dungeondim_x*-0.5)
					if(groupmaxs_y+grouppadding <= dungeondim_y*0.5)
					if(groupmins_y-grouppadding >= dungeondim_y*-0.5)
					if(groupmaxs_z+grouppadding <= dungeondim_z*0.5)
					if(groupmins_z-grouppadding >= dungeondim_z*-0.5)
						insidedungeon = TRUE;
					
					if(!insidedungeon)
					{
						groupdoesntfit = TRUE;
						break;
					}
					
					for(nearchunk = list_unconnectedchunkchain; nearchunk && !groupdoesntfit; nearchunk = nearchunk.unconnectedchunkchain)
					{
						if(nearchunk == forechunk)
							continue;
						
						if(nearchunk.genorg_x >= groupmins_x)
						if(nearchunk.genorg_x <= groupmaxs_x)
						if(nearchunk.genorg_y >= groupmins_y)
						if(nearchunk.genorg_y <= groupmaxs_y)
						if(nearchunk.genorg_z >= groupmins_z)
						if(nearchunk.genorg_z <= groupmaxs_z)
						{
							groupdoesntfit = TRUE;
							break;
						}
						
						if(nearchunk.genorg_x >= groupmins_x-1*chunksize*cubicradius*2)
						if(nearchunk.genorg_x <= groupmaxs_x+1*chunksize*cubicradius*2)
						if(nearchunk.genorg_y >= groupmins_y-1*chunksize*cubicradius*2)
						if(nearchunk.genorg_y <= groupmaxs_y+1*chunksize*cubicradius*2)
						if(nearchunk.genorg_z >= groupmins_z-1*chunksize*cubicradius*2)
						if(nearchunk.genorg_z <= groupmaxs_z+1*chunksize*cubicradius*2)
						{
							for(sidecount = 0; sidecount < 6; sidecount++)
							{
								if(nearchunk.infoedit_chunksidedata[sidecount] != CHUNKCONNECTION_GENERATED)
								if(nearchunk.infoedit_chunksidedata[sidecount] != CHUNKCONNECTION_CLOSED)
								{
									switch(sidecount)
									{
										case 0:	ofs = VECOFS_U;		break;
										case 1:	ofs = VECOFS_W;		break;
										case 2:	ofs = VECOFS_S;		break;
										case 3:	ofs = VECOFS_E;		break;
										case 4:	ofs = VECOFS_N;		break;
										case 5:	ofs = VECOFS_D;		break;						
									}							
									
									nearchunkpos = nearchunk.genorg+ofs*chunksize*cubicradius*2;

									if(nearchunkpos_x >= groupmins_x)
									if(nearchunkpos_x <= groupmaxs_x)
									if(nearchunkpos_y >= groupmins_y)
									if(nearchunkpos_y <= groupmaxs_y)
									if(nearchunkpos_z >= groupmins_z)
									if(nearchunkpos_z <= groupmaxs_z)
									{
										groupdoesntfit = TRUE;
										break;
									}
								}
							}
						}
					}
					
					if(!groupdoesntfit)
					for(nearchunkpos_x = groupmins_x; nearchunkpos_x <= groupmaxs_x && !groupdoesntfit; nearchunkpos_x+=chunksize*cubicradius*2)
						for(nearchunkpos_y = groupmins_y; nearchunkpos_y <= groupmaxs_y && !groupdoesntfit; nearchunkpos_y+=chunksize*cubicradius*2)
							for(nearchunkpos_z = groupmins_z; nearchunkpos_z <= groupmaxs_z && !groupdoesntfit; nearchunkpos_z+=chunksize*cubicradius*2)
							{
								nearclusterpos = GetNearClusterOrg(nearchunkpos);
								filename = strcat(worldpath, itos(GetClusterRef(nearclusterpos)));
								file = fopen(filename, FILE_MMAP_READ);

								if(file != -1)
								{
									cluster_data = (int*)fgets(file);
									nearchunkref = GetChunkRef(nearchunkpos-nearclusterpos, __FUNC__);
									chunkslot0 = numprechunkvaluesincluster + nearchunkref*numslotsforchunkincluster;
										
									if(!CheckNullChunk(cluster_data, chunkslot0))
									{
										groupdoesntfit = TRUE;
										fclose(file);
										break;
									}
									
									fclose(file);
								}
							}

					if(!groupdoesntfit)
						gen_expandfit = TRUE;

					break;
				}
			}

			if(groupdoesntfit)
				continue;
		}
		
		// check every side of the prefab to see if it works
		for(sidecount = 0; sidecount < 6; sidecount++)
		{
			// set the values for the side being checked
			prefabside_type = prefab.prefabdata_temp[sidecount];
			prefabside_fit = prefab.prefabdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidecount];

			matchside_type = side_type[sidecount];
			matchside_fit = side_fit[sidecount];
			matchside_flags = side_flags[sidecount];
			matchside_rotation = side_rotation[sidecount];
			matchside_zone = side_zone[sidecount];
			matchside_prefabchunkflags = side_prefabchunkflags[sidecount];
			// don't use fit pieces for first generated piece
			if(!forechunk)
			{
				if(prefabside_fit)
				{
					nomatch = TRUE;
					break;
				}
			}
			
			if(prefabside_type == CHUNKCONNECTION_REQUIREONE)
				requireone = TRUE;

			// nothing exists on this side yet. any connection works here
			if(matchside_type == CHUNKCONNECTION_FREE)
			if(prefabside_type != CHUNKCONNECTION_REQUIREONE)
				continue;
			
			// nothing should be left open on the edge, only allow closed connections here
			if(matchside_type == CHUNKCONNECTION_EDGE)		
			if(prefabside_type == CHUNKCONNECTION_CLOSED || prefabside_type == CHUNKCONNECTION_REQUIREONE)
				continue;
			else
			{
				nomatch = TRUE;
				break;
			}

			if(prefabside_type == CHUNKCONNECTION_REQUIREONE)
			{
				if(matchside_type == CHUNKCONNECTION_OPENED || matchside_type == CHUNKCONNECTION_FREE || matchside_type == CHUNKCONNECTION_ANY)
				{
					prefab.prefabdata_temp[sidecount] = CHUNKCONNECTION_OPENED;
					prefabside_type = CHUNKCONNECTION_OPENED;
					
					if(sidecount != forechunkside)
						connecting_requireone = TRUE;
					
					if(matchside_type == CHUNKCONNECTION_FREE)
						continue;
				}
				else
				{
					prefab.prefabdata_temp[sidecount] = CHUNKCONNECTION_CLOSED;
					prefabside_type = CHUNKCONNECTION_CLOSED;
				}
			}
			
			// check side flags
			if(matchside_fit)
			{
				if(!(matchside_flags & CFL_ALLOWROTATEDFIT))
				if(prefab.genrotation != matchside_rotation)
				{
					nomatch = TRUE;
					break;
				}
			}
			
			if(prefabside_fit != matchside_fit)
			{
				nomatch = TRUE;
				break;
			}

			if(matchside_zone >= 0) // -1 is an empty space (so there's an existing chunk here)
			if(prefab.genzone != matchside_zone) // not the same zone
			{
				if(!(matchside_type == CHUNKCONNECTION_PASSAGE && prefabside_type == CHUNKCONNECTION_PASSAGE)) // don't connect to a different zone unless the connection is CHUNKCONNECTION_PASSAGE
				{
					nomatch = TRUE;
					break;
				}
			}
			else // is the same zone so don't let passages connect unless looking for a specific fit piece or unless the prefab is marked to allow it	
			if(matchside_type == CHUNKCONNECTION_PASSAGE && prefabside_type == CHUNKCONNECTION_PASSAGE)				
			if(!matchside_fit) 
			if(!((prefab.prefabchunkflags & CHFL_ALLOWSAMEZONEPASSAGE) && (matchside_prefabchunkflags & CHFL_ALLOWSAMEZONEPASSAGE)))
			{
				nomatch = TRUE;
				break;
				
			}

			// this side matches connection type, check more specific rules inside
			if(matchside_type == prefabside_type)
				continue;

			// don't let CHUNKCONNECTION_PASSAGE connect to anything else if it didn't already match up
			if(matchside_type == CHUNKCONNECTION_PASSAGE || prefabside_type == CHUNKCONNECTION_PASSAGE)
			{
				nomatch = TRUE;
				break;
			}
			
			// anything that isn't CHUNKCONNECTION_CLOSED or CHUNKCONNECTION_PASSAGE can match up to a CHUNKCONNECTION_ANY
			if(matchside_type == CHUNKCONNECTION_ANY || prefabside_type == CHUNKCONNECTION_ANY)
				continue;
					
			// this side didn't match up, check the next prefab
			nomatch = TRUE;
		
			break;
		}
	
		if(requireone)
		if(!connecting_requireone)
			nomatch = TRUE;

		// every side worked, this prefab is valid. add to the list to be chosen randomly from
		if(!nomatch)
		{
			nummatchingprefabs++;
			MatchingPrefabChain_Add(prefab);
		}
	}

	if(nummatchingprefabs)
	{
		// pick a random prefab from the list, keeping in mind generation rarity
		totalchance = 0;
		for(prefab = list_matchingprefabchain; prefab; prefab = prefab.matchingprefabchain)
			totalchance += max(0.01, prefab.prefabdata[PREFABCHUNKSLOT_CHANCE]*0.01);
			
		float chance = random()*totalchance;
		
		totalchance = 0;
		for(prefab = list_matchingprefabchain; prefab; prefab = nexte)
		{
			nexte = prefab.matchingprefabchain;

			if(!useprefab)
			{
				totalchance += max(0.01, prefab.prefabdata[PREFABCHUNKSLOT_CHANCE]*0.01);
				if(totalchance >= chance)
					useprefab = prefab;
			}
			
			MatchingPrefabChain_Remove(prefab);	
		}
		
		// stop generating in areas previous to the passage generation and clear values for the next passage iteration
		if(createpassage)
		{
			numchunkssincepassage = 0;
			truncatearea = TRUE;
			truncateareapos = chunkpos_z;
		}
		
		// copy the prefab data to cdata
		for(count = 0; count < numslotsforchunkincluster; count++)
			cdata[count] = useprefab.prefabdata[count+numprefabgenvaluesinchunk+numprecubicvaluesinchunk];	// FIXME: Use vis data from prefabs from non-edge cubic.
		
		if(!createpassage)
		if(!expandingpassage)
			numchunkssincepassage++;
	}
	else// nothing matches, spawn a solid chunk instead
	{
		if(createpassage)
		{
			gen_searchingforspace = TRUE;
			memfree(cdata);
			return -1;
		}
		else
		{
			if(prefab_zonefill[forechunk.genzone])
			{
				for(count = 0; count < numslotsforchunkincluster; count++)
					cdata[count] = prefab_zonefill[forechunk.genzone].prefabdata[count+numprefabgenvaluesinchunk+numprecubicvaluesinchunk];
			}
			else
				GenChunk_Solid(chunkpos, cdata);
		}
	}
	
	// write the chunk to disk
	if(WriteChunk(chunkpos, cdata))
		numchunks++;

	numchunksgeneratedthisframe++;	
	memfree(cdata);

	// add new chunk to queue if it has loose connections
	if(useprefab)
	for(sidecount = 0; sidecount < 6; sidecount++)
	{
		if(side_type[sidecount] == CHUNKCONNECTION_FREE)
		if(!((sidecount == 0 || sidecount == 5) && useprefab.prefabdata[sidecount] == CHUNKCONNECTION_CLOSED))
		{
			if(!chunk)
			{
				chunk = spawn();
				
				if(genstep)
				{
					stepchunk = spawn();
					setmodel(stepchunk, "models/editor/cubeselector.mdl");
					stepchunk.scale = (chunksize-1)*0.02;
					stepchunk.colormod = useprefab.colormod;
					setorigin(stepchunk, chunkpos*0.02);
					
					if(createpassage)
						stepchunk.colormod = stepchunk.colormod+'0 1 0';

					if(expandingpassage)
						stepchunk.colormod = stepchunk.colormod+'0 0 1';
				}
				
				chunk.genorg = chunkpos;
				chunk.genrotation = useprefab.genrotation;
				chunk.genzone = useprefab.genzone;
				chunk.prefabchunkflags = useprefab.prefabchunkflags;
				
				
				if(lineargeneration)
				{
					for(e = list_unconnectedchunkchain; e; e = e.unconnectedchunkchain)
						lastent = e;
					list_unconnectedchunkchain = LinkedList_Append(chunk, list_unconnectedchunkchain, lastent, unconnectedchunkchain, unconnectedchunkchain_prev);
				}
				else
					UnconnectedChunkChain_Add(chunk);
				
			//	chunk.infoedit_chunksidedata = memalloc(sizeof(int)*numsideinfoslots);

				for(newchunksidecount = 0; newchunksidecount < 6; newchunksidecount++)
					chunk.infoedit_chunksidedata[newchunksidecount] = CHUNKCONNECTION_GENERATED;
			}
			
			chunk.lookingforconnections++;
			chunk.infoedit_chunksidedata[sidecount] = useprefab.prefabdata_temp[sidecount];
			chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidecount] = useprefab.prefabdata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidecount];
			chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+sidecount] = useprefab.prefabdata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+sidecount];
			
		//	print(ftos(chunk.lookingforconnections), "\n");
			
			// don't try to expand from CHUNKCONNECTION_ANY
			if(chunk.infoedit_chunksidedata[sidecount] == CHUNKCONNECTION_ANY)
				chunk.infoedit_chunksidedata[sidecount] = CHUNKCONNECTION_CLOSED;
		}
	}
	
	return TRUE;	
}

void TruncateChunks()
{
	if(!truncatearea)
		return;
	
	int count = 0;
	
	for(entity chunk = list_unconnectedchunkchain; chunk; chunk = chunk.unconnectedchunkchain)
	{
	//	if(chunk.genorg_z == truncateareapos)
	//	{
			for(count = 0; count < 6; count++)
			if(chunk.infoedit_chunksidedata[count] != CHUNKCONNECTION_GENERATED)
			if(chunk.infoedit_chunksidedata[count] != CHUNKCONNECTION_PASSAGE)
				chunk.infoedit_chunksidedata[count] = CHUNKCONNECTION_CLOSED;
	//	}
	}	
	
	truncatearea = FALSE;
}

void GenerateWorld_Prefabs()
{
	int sidecount = 0, sidetype = 0, chunkgen = FALSE, foundfit = FALSE, vertical = 0;
	vector ofs = '0 0 0';
	entity nexte = __NULL__, chunk = __NULL__;
	
	numchunksgeneratedthisframe = 0;
	
	if(!world_initialized)
	{
		SetupPrefabs();
		chunksperpassage = cvar("cq_chunksperpassage");
		world_initialized = 1;
		GenerateChunks_Dungeon(__NULL__, '0 0 0', FALSE, FALSE, TRUE, 0);
	}
	else
	if(world_initialized == 1)
	{	
		if(list_unconnectedchunkchain)			// generating dungeon
		{
			if(genpaused)
				return;
			
			for(chunk = list_unconnectedchunkchain; chunk && chunkgen > -1 && numchunksgeneratedthisframe < maxchunkstogenerateperframe; chunk = nexte)
			{
				nexte = chunk.unconnectedchunkchain;

				if(gen_expandfit)
				{
					for(sidecount = 0; sidecount < 6; sidecount++)
					{
						if(chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidecount])
						{
							foundfit = TRUE;
							break;
						}
					}
					
					if(!foundfit)
						continue;
				}
				
				for(sidecount = 0; sidecount < 6 && chunk; sidecount++)
				{					
					vertical = FALSE;
					sidetype = chunk.infoedit_chunksidedata[sidecount];

					if(sidetype != CHUNKCONNECTION_GENERATED)
					{
						switch(sidecount)
						{
							case 0:	ofs = VECOFS_U;	vertical = 1;		break;
							case 1:	ofs = VECOFS_W;						break;
							case 2:	ofs = VECOFS_S;						break;
							case 3:	ofs = VECOFS_E;						break;
							case 4:	ofs = VECOFS_N;						break;
							case 5:	ofs = VECOFS_D;	vertical = -1;		break;						
						}

					//	if(!(vertical && sidetype == CHUNKCONNECTION_CLOSED))
						
						chunkgen = GenerateChunks_Dungeon(chunk, chunk.genorg + ofs*chunksize*cubicradius*2, FALSE, sidetype == CHUNKCONNECTION_CLOSED, sidetype == CHUNKCONNECTION_PASSAGE, vertical);
					
						if(chunkgen)
						{
							TruncateChunks();
							
							if(chunkgen == -1)
								chunk.infoedit_chunksidedata[sidecount] = CHUNKCONNECTION_CLOSED;
	
							if(chunkgen == 1)
							{
								chunk.infoedit_chunksidedata[sidecount] = CHUNKCONNECTION_GENERATED;
								if(SubtractConnectionFromGenChunk(chunk))	// the if checks if this was the last connection for the chunk
									break;
							}
						}
					}
				}
			}
			
			if(genstep)
				genpaused = TRUE;
			
			if(!chunk)
			if(gen_searchingforspace)
			{
				numchunkssincepassage-=1;
				gen_searchingforspace = FALSE;
			}
			
			if(!foundfit)
				gen_expandfit = FALSE;
		}
		else
		{
			while(numchunksgeneratedthisframe < maxchunkstogenerateperframe)
			{
				GenerateChunks_Dirt(GetChunkOrigin(worldgen_fillpos));
				worldgen_fillpos++;
			
				if(worldgen_fillpos == maxchunks)
				{
					worldgen_filled = TRUE;
					break;
				}
			}
		}
		
		if(worldgen_filled)
		{
			world_initialized = 2;
			RemovePrefabs();
		//	RemoveZones();
		}
		
		for(entity e = list_playerchain; e; e = e.playerchain)
			centerprint(e, "Chunks Generated: ", ftos(numchunks), "/", ftos(maxchunks), "\n");		
		
	}
	else
	if(world_initialized == 2)
		GenCubicVisibility();
}