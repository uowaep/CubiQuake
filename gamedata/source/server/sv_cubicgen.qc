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
	float file;
	int count, chunkslot0, slot, newwrite;
	int *cluster_data;
	
	vector clusterpos = GetNearClusterOrg(chunkpos);	
	int chunkref = GetChunkRef(chunkpos-clusterpos);

	string filename = strcat(worldpath, itos(GetClusterRef(clusterpos)));
	file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
	cluster_data = (int*)fgets(file);


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

vector GetCubicOffsetForGeneration(vector pos)	{	return (pos+'-1 -1 -1'*chunksize*0.5)*cubicradius*2 + '1 1 1'*cubicradius;	}

int ChunkGen_SetCubic(int *cdata, int type, int cubicslot0)
{
	cdata[cubicslot0+CUBICSLOT_TYPE]		= type;
	cdata[cubicslot0+CUBICSLOT_SHAPE]		= BLOCKSHAPE_CUBE;
	cdata[cubicslot0+CUBICSLOT_ROTATION]	= BLOCKROTATION_E;
	cdata[cubicslot0+CUBICSLOT_CULLBITS]	= 0;
	
	cubicslot0 += numvaluespercubic;
	
	return cubicslot0;
}

// CHUNK TYPES

void GenChunk_Sky(vector chunkpos, int *cdata)
{
	vector pos;
	int cubicslot0;
	
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
				cubicslot0 = ChunkGen_SetCubic(cdata, 0, cubicslot0);
}

void GenChunk_Surface(vector chunkpos, int *cdata)
{
	int type, cubicslot0;
	vector pos;

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
					type = max(1, ceil(random()*numblocktypes));
				
				cubicslot0 = ChunkGen_SetCubic(cdata, type, cubicslot0);
			}
		}
}

void GenChunk_Solid(vector chunkpos, int *cdata)
{
	vector pos;
	int cubicslot0;
	
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
				cubicslot0 = ChunkGen_SetCubic(cdata, max(1, ceil(random()*numblocktypes)), cubicslot0);
}

int GenSpawnChunk(vector chunkpos)
{
	int surfacelevel = -1*(chunksize*cubicradius*2);
	int *cdata = memalloc(sizeof(int)*pow(chunksize, 3)*numvaluespercubic);
		
	if(chunkpos_z < surfacelevel)
		GenChunk_Solid(chunkpos, cdata);
	else
	if(chunkpos_z == surfacelevel)
		GenChunk_Surface(chunkpos, cdata);
	else
		GenChunk_Sky(chunkpos, cdata);
	
	int newwrite = WriteChunk(chunkpos, cdata);
	memfree(cdata);
	
	return newwrite;
}

void QueueChunk(vector pos)
{
	int id;
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
	int chunkclusterid = GetChunkRef(pos-clusterorg);

	// CHECK WORLD BOUNDS
	if(pos_x > worlddim_x*0.5 || pos_x < worlddim_x*-0.5
	|| pos_y > worlddim_y*0.5 || pos_y < worlddim_y*-0.5
	|| pos_z > worlddim_z*0.5 || pos_z < worlddim_z*-0.5)
		return;		

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

void GenerateChunks(vector chunkpos)
{
	vector ofs, nearchunkpos;
	
	// Write chunk to disk here
	if(!GenSpawnChunk(chunkpos))
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
	int cullbits, chunkslot0, cubicslot0B, i, cubicnum, clusterid, cubicslot0, chunk_numvisiblecubics, nearclusterid, nearchunkid, nearcubicid;
	vector nearcubicorg, nearchunkorg, nearclusterorg, clusterorg, chunkorg;
	int maxvised = 1;
	float file, fileB;
	entity e;
	
	vector ofs = '0 0 0';
	vector cubicchunkorg = '0 0 0';
	int numvised = 0;
	int totalvisiblecubicsincluster = 0;
	int *cluster_data = __NULL__;
	int *cluster_dataB = __NULL__;
	
	for(clusterid = generating_clusterid; clusterid < maxclusters && numvised < maxvised; clusterid++)
	{
		numvised++;
		totalvised++;

		string filename = strcat(worldpath, itos(clusterid));
		file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);

		cluster_data = (int*)fgets(file);
		clusterorg = GetClusterOffset(clusterid);
		
		for(i = 0; i < pow(clustersize, 3); i++)
		{
			chunkslot0 = numprechunkvaluesincluster + i*numslotsforchunkincluster;
			
			if(CheckNullChunk(cluster_data, chunkslot0))
			{
				print("found null chunk\n");
				continue;
			}

			chunkorg = clusterorg + GetChunkOffset(i);
			chunk_numvisiblecubics = pow(chunksize, 3);
			
			for(cubicnum = 0; cubicnum < pow(chunksize, 3); cubicnum++)
			{
				cubicslot0 = chunkslot0+numprecubicvaluesinchunk+cubicnum*numvaluespercubic;
				vector cubicorg = chunkorg + GetCubicOffset(cubicnum);
				cullbits = 0;

				if(cluster_data[cubicslot0+CUBICSLOT_TYPE] == 0) // no type (empty space)
				{		
					chunk_numvisiblecubics-=1;	
					continue;
				}
				
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
					nearchunkid = GetChunkRef(nearchunkorg-nearclusterorg);
					nearcubicid = GetCubicRef(nearcubicorg-nearchunkorg);
					
					fileB = 0;
					
					if(nearclusterid != clusterid)
					{
						string filenameB = strcat(worldpath, itos(nearclusterid));
						fileB = fopen(filenameB, FILE_MMAP_READ, sizeof(*cluster_dataB)*clusterdataslots);

						if(fileB < 0)
						{
							print("Error: Trying to open file that doesn't exist.\n");
							cullbits = cullbits | bitshift(1, sidecount);
							continue;
						}
						
						cluster_dataB = (int*)fgets(fileB);
					}
					else
						cluster_dataB = cluster_data;
					
					cubicslot0B = numprechunkvaluesincluster + nearchunkid*numslotsforchunkincluster + numprecubicvaluesinchunk + nearcubicid*numvaluespercubic;
					if(cluster_dataB[cubicslot0B+CUBICSLOT_TYPE] != 0) // TYPE is not empty
						cullbits = cullbits | bitshift(1, sidecount);
					
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
		for(e = list_playerchain; e; e = e.playerchain)
			e.movetype = MOVETYPE_WALK;
	}
	else
	{
		generating_clusterid = clusterid;
		for(e = list_playerchain; e; e = e.playerchain)
			centerprint(e, "Building faces: ", itos(totalvised*pow(clustersize, 3)*pow(chunksize, 3)), "/", itos(maxclusters*pow(clustersize, 3)*pow(chunksize, 3)), " cubics faceified.\n");
	}
}

void GenerateWorld()
{
	string s, token;
	int id, tokenlen;
	vector pos;

	numchunksgeneratedthisframe = 0;
	
	if(!world_initialized)
	{
		world_initialized = 1;
		GenerateChunks('0 0 -1'*chunksize*cubicradius*2);
	}
	else
	if(world_initialized == 1)
	{
		while(strlen(chunkgenqueue_string) && numchunksgeneratedthisframe < maxchunkstogenerateperframe)
		{
			s = substring(chunkgenqueue_string, 0, 10); // 10 setes it at almost 10 billion. cutting the string there saves on tokens to generate. we only need the first one.
			tokenize(s);
			token = argv(0);
			id = stoi(token);
			tokenlen = strlen(token);

			chunkgenqueue_string = substring(chunkgenqueue_string, tokenlen+1, strlen(chunkgenqueue_string)-(tokenlen+1));		
			pos = GetChunkOrigin(id);

			GenerateChunks(pos);
			
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