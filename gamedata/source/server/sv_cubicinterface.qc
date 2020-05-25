void LoadPrefab_Cluster(vector clusterorg)
{
	entity cluster = GetChunkForLocation(__NULL__, clusterorg);
	if(!cluster)
		return;

	entity chunk = __NULL__;
	int chunkslot0 = 0, cubicslot0 = 0, i = 0;
	int *cluster_data;
	vector org = '0 0 0', pos = '0 0 0';
	
	string prefabname = self.prefabfilename;
	
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/players/", self.netname, "/clusters/", prefabname);
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
				SetNumVisibleCubics(chunk, cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS]);
	
				for(i = 0; i < pow(chunksize,3); i++)
				{
					cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + i*numvaluespercubic;

					chunk.cubic_blocktype[i] = cluster_data[cubicslot0+CUBICSLOT_TYPE];
					chunk.cubic_blockshape[i] = cluster_data[cubicslot0+CUBICSLOT_SHAPE];
					chunk.cubic_blockrotation[i] = GetFixedRotation(cluster_data[cubicslot0+CUBICSLOT_ROTATION], chunk.cubic_blockshape[i]);
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

	entity chunk = __NULL__;	
	int chunkslot0 = 0, cubicslot0 = 0, i = 0;
	int *cluster_data;	
	vector org = '0 0 0', pos = '0 0 0';
	
	string prefabname = self.prefabfilename;
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/players/", self.netname, "/clusters/", prefabname);
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
					cluster_data[cubicslot0+CUBICSLOT_ROTATION] = GetFixedRotation(chunk.cubic_blockrotation[i], chunk.cubic_blockshape[i]);
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
	
	vector pos = '0 0 0', org = '0 0 0';
	entity chunk = __NULL__;
	
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
				
				SetNumVisibleCubics(chunk, 0);
				
				for(int i = 0; i < pow(chunksize, 3); i++)
				{
					chunk.cubic_blocktype[i] = type;
					chunk.cubic_blockshape[i] = shape;
					chunk.cubic_blockrotation[i] = GetFixedRotation(rotation, shape);						
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
	
	vector pos = '0 0 0';
	entity chunk = __NULL__;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{	
				chunk = GetChunkForLocation(__NULL__, GetChunkOffsetFromGrid(pos)+clusterorg);
				
				if(!chunk)
					return;
				
				SetNumVisibleCubics(chunk, 0);
				
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

	int i = 0, cubicslot0 = 0;
	int *chunk_data;

	string prefabname = self.prefabfilename;
	
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/players/", self.netname, "/", prefabname);
	float file = fopen(filename, FILE_MMAP_READ, sizeof(*chunk_data)*(numslotsforchunkincluster+numprefabgenvaluesinchunk));
	
	if(file == -1)
	{
		sprint(self, "File doesn't exist in \"prefabs/players/", self.netname, "\".\n");
		return;
	}
	
	chunk_data = (int*)fgets(file);
	
	for(i = 0; i < numsideinfoslots; i++)
		chunk.infoedit_chunksidedata[i] = chunk_data[i];

	chunk.prefabzone = chunk_data[PREFABCHUNKSLOT_ZONE];
	chunk.prefabchance = chunk_data[PREFABCHUNKSLOT_CHANCE];
	chunk.prefabchunkflags = chunk_data[PREFABCHUNKSLOT_CHUNKFLAGS];

	sprint(self, "Loding chunk with zone: ", itos(chunk.prefabzone), "\n");

	chunk.chunkbits = chunk_data[numprefabgenvaluesinchunk+CHUNKSLOT_CHUNKBITS];
	SetNumVisibleCubics(chunk, chunk_data[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS]);
	
	for(i = 0; i < pow(chunksize, 3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+numprefabgenvaluesinchunk+i*numvaluespercubic;

		chunk.cubic_blocktype[i] = chunk_data[cubicslot0+CUBICSLOT_TYPE];
		chunk.cubic_blockshape[i] = chunk_data[cubicslot0+CUBICSLOT_SHAPE];
		chunk.cubic_blockrotation[i] = GetFixedRotation(chunk_data[cubicslot0+CUBICSLOT_ROTATION], chunk.cubic_blockshape[i]);		
		chunk.cubic_cullbits[i] = chunk_data[cubicslot0+CUBICSLOT_CULLBITS];
	}
	
	fclose(file);
	UpdateChunkAreaVisibility_OuterEdge(chunk);
	SetChunkAsModified(chunk);
	
	sprint(self, filename, " loaded.\n");
}

void InfoEdit_Chunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	for(int sidecount = 0; sidecount < numsideinfoslots; sidecount++)
		self.infoedit_chunksidedata[sidecount] = chunk.infoedit_chunksidedata[sidecount];
	
	self.prefabzone = chunk.prefabzone;
	if(chunk.prefabchance)
		self.prefabchance = chunk.prefabchance;
	else
		self.prefabchance = 100;
	self.prefabchunkflags = chunk.prefabchunkflags;
	
	self.editor_infoedit = TRUE;
	self.editor_editchunk = GetChunkOriginRef(chunkorg, __FUNC__);	
}

void SetSelectionEdge(vector polarity, vector ofs)
{
	if(polarity_x > 0)
		self.editor_selection_maxs_x = ofs_x;
	else
	if(polarity_y > 0)
		self.editor_selection_maxs_y = ofs_y;
	else
	if(polarity_z > 0)
		self.editor_selection_maxs_z = ofs_z;
	else
	if(polarity_x < 0)
		self.editor_selection_mins_x = ofs_x;
	else
	if(polarity_y < 0)
		self.editor_selection_mins_y = ofs_y;
	else
	if(polarity_z < 0)
		self.editor_selection_mins_z = ofs_z;		
}

void InitializeSelectionEdge()
{
	self.editor_selection_mins = '-1 -1 -1'*cubicradius*2;
	self.editor_selection_maxs = '1 1 1'*cubicradius*2;
	
//	print(vtos(self.editor_selection_maxs), "\n");
}

void SavePrefab_Chunk(vector chunkorg)
{
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	int i = 0, cubicslot0 = 0;
	int *chunk_data;	
	
	string prefabname = self.prefabfilename;
	if(strlen(prefabname) < 1)
	{
		sprint(self, "Invalid filename.\n");
		return;
	}
	
	string filename = strcat("prefabs/players/", self.netname, "/", prefabname);
	float file = fopen(filename, FILE_MMAP_RW, sizeof(*chunk_data)*(numslotsforchunkincluster+numprefabgenvaluesinchunk));
	chunk_data = (int*)fgets(file);
	
	// tells the generator what can connect to each side of this chunk
	for(i = 0; i < numsideinfoslots; i++)
		chunk_data[i] = chunk.infoedit_chunksidedata[i];

	chunk_data[PREFABCHUNKSLOT_ZONE] = self.prefabzone;
	chunk_data[PREFABCHUNKSLOT_CHANCE] = self.prefabchance;
	chunk_data[PREFABCHUNKSLOT_CHUNKFLAGS] = self.prefabchunkflags;
	
	chunk_data[numprefabgenvaluesinchunk+CHUNKSLOT_CHUNKBITS] = chunk.chunkbits;
	chunk_data[numprefabgenvaluesinchunk+CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
	
	for(i = 0; i < pow(chunksize,3); i++)
	{
		cubicslot0 = numprecubicvaluesinchunk+numprefabgenvaluesinchunk+i*numvaluespercubic;

		chunk_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
		chunk_data[cubicslot0+CUBICSLOT_SHAPE] = chunk.cubic_blockshape[i];
		chunk_data[cubicslot0+CUBICSLOT_ROTATION] = GetFixedRotation(chunk.cubic_blockrotation[i], chunk.cubic_blockshape[i]);		
		chunk_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];
	}
	
	fclose(file);
	
	sprint(self, filename, " saved.\n");
}

void AddChunk(vector chunkorg, int type, int shape, int rotation)
{
	if(NonSolidType(type))
	{
		sprint(self, "Can't add a chunk of that type of block.\n");
		return;
	}
	
	entity chunk = GetChunkForLocation(__NULL__, chunkorg);
	
	if(!chunk)
		return;
	
	SetNumVisibleCubics(chunk, 0);
	
	for(int i = 0; i < pow(chunksize, 3); i++)
	{
		chunk.cubic_blocktype[i] = type;
		chunk.cubic_blockshape[i] = shape;
		chunk.cubic_blockrotation[i] = GetFixedRotation(rotation, shape);		
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
	
	SetNumVisibleCubics(chunk, 0);
	
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

void CopyCubicData(vector org)
{
	entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(org));
	if(!chunk)
		return;
	
	int i = GetCubicRef(org-chunk.origin, __FUNC__);
	
	self.editor_blocktype = chunk.cubic_blocktype[i];
	self.editor_blockshape = chunk.cubic_blockshape[i];
	self.editor_blockrotation = chunk.cubic_blockrotation[i];
}

void AddCubic(vector org, int type, int shape, int rotation, int avoidexistingcubics)
{
	if(!type || !shape)
		return;
	
	vector cubicchunkorg = GetNearChunkOrg(org);
	entity chunk = GetChunkForLocation(__NULL__, cubicchunkorg);
	
	if(!chunk)
		return;
	
/*
	if(GetCubicStatus(chunk, org, FALSE) != -1)
	{
		dprint("Error: Trying to create cubic where one already exists.\n");
		return;
	}
*/

	if(avoidexistingcubics)
		if(GetCubicStatus(chunk, org, FALSE) != -1)
			return;

	if(GetCubicStatus(chunk, org, FALSE) == -1)
		SetNumVisibleCubics(chunk, chunk.numvisiblecubics+1);

	int i = GetCubicRef(org-cubicchunkorg, __FUNC__);
	chunk.cubic_blocktype[i] = type;
	chunk.cubic_blockshape[i] = shape;
	chunk.cubic_blockrotation[i] = GetFixedRotation(rotation, shape);
	
	chunk.cubic_cullbits[i] = (chunk.cubic_cullbits[i] & CULLBITS_ALL) + GetPartialSideCullBitsForShape(type, shape, rotation);
	
	UpdateChunkAreaVisibility(chunk, org, TRUE);
}

void AddCubicArea(vector cubicorg, int type, int shape, int rotation, int avoidexistingcubics)
{
	vector org = '0 0 0';
	vector edgemins = cubicorg + self.editor_selection_mins + '1 1 1'*cubicradius*2;
	vector edgemaxs = cubicorg + self.editor_selection_maxs - '1 1 1'*cubicradius*2;
	
	for(org_x = edgemins_x; org_x <= edgemaxs_x; org_x+=cubicradius*2)
		for(org_y = edgemins_y; org_y <= edgemaxs_y; org_y+=cubicradius*2)
			for(org_z = edgemins_z; org_z <= edgemaxs_z; org_z+=cubicradius*2)
			{
				if(org_x > worlddim_x*0.5 || org_x < worlddim_x*-0.5
				|| org_y > worlddim_y*0.5 || org_y < worlddim_y*-0.5
				|| org_z > worlddim_z*0.5 || org_z < worlddim_z*-0.5)
					continue;

				AddCubic(org, type, shape, rotation, avoidexistingcubics);
			}
}

void ClearCubic(entity chunk, vector cubicorg)
{
	if(!chunk)
		return;

	int memslot = GetCubicStatus(chunk, cubicorg, FALSE);
	
	if(memslot == -1)
		return;
	
	int cullbits = chunk.cubic_cullbits[memslot];
	if((cullbits & CULLBITS_ALL) != CULLBITS_ALL)
		SetNumVisibleCubics(chunk, chunk.numvisiblecubics-1);
	
	entity bbox = GetCubicBBoxForLocation(cubicorg);
	if(bbox)
		Remove(bbox);	// this is just a bbox entity
	
	chunk.cubic_blocktype[memslot] = 0;
	chunk.cubic_cullbits[memslot] = 0;
	
	UpdateChunkAreaVisibility(chunk, cubicorg, TRUE);
}

void ClearCubicArea(entity chunk, vector cubicorg)
{
	vector org = '0 0 0';
	vector edgemins = cubicorg + self.editor_selection_mins + '1 1 1'*cubicradius*2;
	vector edgemaxs = cubicorg + self.editor_selection_maxs - '1 1 1'*cubicradius*2;
	
	for(org_x = edgemins_x; org_x <= edgemaxs_x; org_x+=cubicradius*2)
		for(org_y = edgemins_y; org_y <= edgemaxs_y; org_y+=cubicradius*2)
			for(org_z = edgemins_z; org_z <= edgemaxs_z; org_z+=cubicradius*2)
			{
				if(org_x > worlddim_x*0.5 || org_x < worlddim_x*-0.5
				|| org_y > worlddim_y*0.5 || org_y < worlddim_y*-0.5
				|| org_z > worlddim_z*0.5 || org_z < worlddim_z*-0.5)
					continue;
				
				chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(org));
				ClearCubic(chunk, org);
			}
}

int GetClampedEditorRotationForShape(int shape, int rotation)
{
	if(shape == BLOCKSHAPE_RAMP || shape == BLOCKSHAPE_SLAB)
	if(rotation > BLOCKROTATION_CCW_S)
	switch(rotation)
	{
		case BLOCKROTATION_FW_E: rotation = BLOCKROTATION_W;		break;
		case BLOCKROTATION_FW_N: rotation = BLOCKROTATION_S;		break;
		case BLOCKROTATION_FW_W: rotation = BLOCKROTATION_E;		break;
		case BLOCKROTATION_FW_S: rotation = BLOCKROTATION_N;		break;
		case BLOCKROTATION_BW_E: rotation = BLOCKROTATION_UD_E;		break;
		case BLOCKROTATION_BW_N: rotation = BLOCKROTATION_UD_N;		break;
		case BLOCKROTATION_BW_W: rotation = BLOCKROTATION_UD_W;		break;
		case BLOCKROTATION_BW_S: rotation = BLOCKROTATION_UD_S;		break;
	}
	
	return rotation;
}

void ClearEditInfo()
{
	self.editor_infoedit = FALSE;
	self.editor_editchunk = -1;
	for(int sidecount = 0; sidecount < numsideinfoslots; sidecount++)
		self.infoedit_chunksidedata[sidecount] = 0;
}

//entity	testbox;
//float	tracetime;

int IncreaseBlockType(int type)
{
	type++;
	if(numobjectblocktypes)
	{
		if(type == numtextureblocktypes+1)
			type = baseobjecttypeid;
		else
		if(type == baseobjecttypeid+numobjectblocktypes)
			type = 1;
	}
	else
	if(type == numtextureblocktypes+1)
		type = 1;
	
	return type;
}

int DecreaseBlockType(int type)
{
	type--;
	if(type < 1)
	{
		if(numobjectblocktypes)
			type = baseobjecttypeid + numobjectblocktypes - 1;
		else
			type = numtextureblocktypes;
	}
	else
	if(numobjectblocktypes)
	if(type == baseobjecttypeid-1)
		type = numtextureblocktypes;

	return type;	
}

vector IncreaseBlockShape(int shape, int rotation)
{
	shape++;
	if(shape > numblockshapes)
		shape = 1;	
	rotation = GetClampedEditorRotationForShape(shape, rotation);
	
	return [shape, rotation, 0];
}

vector DecreaseBlockShape(int shape, int rotation)
{
	shape-=1;
	if(shape < 1)
		shape = numblockshapes;
	rotation = GetClampedEditorRotationForShape(shape, rotation);
	
	return [shape, rotation, 0];
}

int IncreaseBlockRotation_Y(int rotation)
{
	rotation++;
	
	if(rotation == BLOCKROTATION_S+1)
		rotation = BLOCKROTATION_E;
	else
	if(rotation == BLOCKROTATION_CW_S+1)
		rotation = BLOCKROTATION_CW_E;
	else
	if(rotation == BLOCKROTATION_UD_S+1)
		rotation = BLOCKROTATION_UD_E;
	else
	if(rotation == BLOCKROTATION_CCW_S+1)
		rotation = BLOCKROTATION_CCW_E;
	else
	if(rotation == BLOCKROTATION_FW_S+1)
		rotation = BLOCKROTATION_FW_E;
	else
	if(rotation == BLOCKROTATION_BW_S+1)
		rotation = BLOCKROTATION_BW_E;		
	
	return rotation;
}

int DecreaseBlockRotation_Y(int rotation)
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

int IncreaseBlockRotation_XZ(int shape, int rotation)
{
	rotation+=4;
	if((shape == BLOCKSHAPE_RAMP || shape == BLOCKSHAPE_SLAB) && rotation > BLOCKROTATION_CCW_S)
		rotation = rotation-(BLOCKROTATION_CCW_S+1);	
	else
	if(rotation > BLOCKROTATION_BW_S)
		rotation = rotation-(BLOCKROTATION_BW_S+1);
	
	return rotation;
}

int DecreaseBlockRotation_XZ(int shape, int rotation)
{
	rotation-=4;
	if(rotation < BLOCKROTATION_E)
	if(shape == BLOCKSHAPE_RAMP || shape == BLOCKSHAPE_SLAB)
		rotation = (BLOCKROTATION_CCW_S+1) + rotation;
	else
		rotation = (BLOCKROTATION_BW_S+1) + rotation;
	
	return rotation;
}

int ModifyBlock(int modificationtype, int(int) func1, vector(int, int) func2, int(int, int) func3)
{
	if(self.tool != TOOL_EDITOR_MODIFY)
		return FALSE;
	
	if(self.toolsize != TOOLSIZE_EDITOR_CUBIC)
		return FALSE;
	
	vector infovec = '0 0 0';
	makevectors(self.v_angle);
	vector targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*20;
	vector tracepos = GetNearestCubicOrigin(TraceCubic(self.origin+self.view_ofs, targetpos, TRUE), chunksize_iseven);
	entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(tracepos));
	
	if(!chunk)
		return FALSE;
	
	if(GetCubicStatus(chunk, tracepos, FALSE) == -1)
		return FALSE;
	
	int i = GetCubicRef(tracepos-chunk.origin, __FUNC__);
	
	if(modificationtype == 0)
		self.editor_blocktype = chunk.cubic_blocktype[i] = func1(chunk.cubic_blocktype[i]);
	else
	if(modificationtype == 1)
	{
		infovec = func2(chunk.cubic_blockshape[i], chunk.cubic_blockrotation[i]);
		self.editor_blockshape = chunk.cubic_blockshape[i] = infovec_x;
		self.editor_blockrotation = chunk.cubic_blockrotation[i] = infovec_y;
	}
	else
	if(modificationtype == 2)
		self.editor_blockrotation = chunk.cubic_blockrotation[i] = func1(chunk.cubic_blockrotation[i]);
	else
	if(modificationtype == 3)
		self.editor_blockrotation = chunk.cubic_blockrotation[i] = func3(chunk.cubic_blockshape[i], chunk.cubic_blockrotation[i]);
	
	chunk.cubic_cullbits[i] = (chunk.cubic_cullbits[i] & CULLBITS_ALL) + GetPartialSideCullBitsForShape(chunk.cubic_blocktype[i], chunk.cubic_blockshape[i], chunk.cubic_blockrotation[i]);
	UpdateChunkAreaVisibility(chunk, tracepos, TRUE);
	
//	SetChunkSendFlags(chunk, SFL_BUILD);

	return TRUE;	
}

void ApplyEditorValuesToCubic(vector org, int alwayscall)
{
	if(!alwayscall)
	if(org == lasteditorvaluesorg)
		return;

	lasteditorvaluesorg = org;
	
	entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(org));
	if(!chunk)
		return;
	
	if(GetCubicStatus(chunk, org, FALSE) == -1)
		return;
	
	int i = GetCubicRef(org-chunk.origin, __FUNC__);
	
	int old_blocktype = chunk.cubic_blocktype[i];
	int old_blockshape = chunk.cubic_blockshape[i];
	int old_blockrotation = chunk.cubic_blockrotation[i];
	int old_cullbits = chunk.cubic_cullbits[i];
	
	chunk.cubic_blocktype[i] = self.editor_blocktype;
	chunk.cubic_blockshape[i] = self.editor_blockshape;
	chunk.cubic_blockrotation[i] = self.editor_blockrotation;
	chunk.cubic_cullbits[i] = (chunk.cubic_cullbits[i] & CULLBITS_ALL) + GetPartialSideCullBitsForShape(chunk.cubic_blocktype[i], chunk.cubic_blockshape[i], chunk.cubic_blockrotation[i]);
	
	if(chunk.cubic_blocktype[i] != old_blocktype
	|| chunk.cubic_blockshape[i] != old_blockshape
	|| chunk.cubic_blockrotation[i] != old_blockrotation
	|| chunk.cubic_cullbits[i] != old_cullbits)
	{
		UpdateChunkAreaVisibility(chunk, org, TRUE);
	//	SetChunkSendFlags_BUILD_Chain_Add(chunk);
	//	SetChunkSendFlags(chunk, SFL_BUILD);
	}
}

void ApplyEditorValuesToCubicArea(vector cubicorg, int alwayscall)
{
	vector org = '0 0 0', edgemins = '0 0 0', edgemaxs = '0 0 0';
	
	if(self.editor_blocktype >= baseobjecttypeid)
		edgemins = edgemaxs = cubicorg;
	else
	{
		edgemins = cubicorg + self.editor_selection_mins + '1 1 1'*cubicradius*2;
		edgemaxs = cubicorg + self.editor_selection_maxs - '1 1 1'*cubicradius*2;
	}
	
	for(org_x = edgemins_x; org_x <= edgemaxs_x; org_x+=cubicradius*2)
		for(org_y = edgemins_y; org_y <= edgemaxs_y; org_y+=cubicradius*2)
			for(org_z = edgemins_z; org_z <= edgemaxs_z; org_z+=cubicradius*2)
			{
				if(org_x > worlddim_x*0.5 || org_x < worlddim_x*-0.5
				|| org_y > worlddim_y*0.5 || org_y < worlddim_y*-0.5
				|| org_z > worlddim_z*0.5 || org_z < worlddim_z*-0.5)
					continue;

				ApplyEditorValuesToCubic(org, alwayscall);
			}	
}

vector GeatNearOrgForTool(vector tracepos, int sizeoftool)
{
	vector org = '0 0 0';
	
	switch(sizeoftool)
	{
		case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(tracepos, chunksize_iseven);	break;
		case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(tracepos);							break;
		case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(tracepos);							break;
	}
	
	return org;
}

void Player_CubiQuakeControls()
{
	vector infovec = '0 0 0', tracepos = '0 0 0', org = '0 0 0', targetpos = '0 0 0';
	int getinside = FALSE;

	if(self.impulse >= TOOLSIZE_EDITOR_CUBIC && self.impulse <= TOOL_EDITOR_INFOEDIT)	// the whole range of tools
	if(self.impulse != TOOL_EDITOR_INFOEDIT)	// clears editinfo fields when using other tools
		ClearEditInfo();

//	if(!self.button3)
	if(!self.editor_sizetool)	
	if(self.impulse == TOOLSIZE_EDITOR_CUBIC)
		self.toolsize = TOOLSIZE_EDITOR_CUBIC;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CHUNK)
		self.toolsize = TOOLSIZE_EDITOR_CHUNK;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CLUSTER)
		self.toolsize = TOOLSIZE_EDITOR_CLUSTER;
	else
	if(self.impulse == TOOL_EDITOR_MODIFY)
		self.tool = TOOL_EDITOR_MODIFY;
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
	if(self.impulse == TOOL_EDITOR_INFOEDIT)
		self.tool = TOOL_EDITOR_INFOEDIT;
	else
	if(self.impulse == EDITOR_BLOCKTYPE_INCREASE)
	{
		if(!ModifyBlock(0, IncreaseBlockType, __NULL__, __NULL__))
			self.editor_blocktype = IncreaseBlockType(self.editor_blocktype);
	}
	else
	if(self.impulse == EDITOR_BLOCKTYPE_DECREASE)
	{
		if(!ModifyBlock(0, DecreaseBlockType, __NULL__, __NULL__))
			self.editor_blocktype = DecreaseBlockType(self.editor_blocktype);
	}
	else
	if(self.impulse == EDITOR_BLOCKSHAPE_INCREASE)
	{
		if(!ModifyBlock(1, __NULL__, IncreaseBlockShape, __NULL__))
		{
			infovec = IncreaseBlockShape(self.editor_blockshape, self.editor_blockrotation);
			self.editor_blockshape = infovec_x;
			self.editor_blockrotation = infovec_y;
		}
	}
	else
	if(self.impulse == EDITOR_BLOCKSHAPE_DECREASE)
	{
		if(!ModifyBlock(1, __NULL__, DecreaseBlockShape, __NULL__))
		{
			infovec = DecreaseBlockShape(self.editor_blockshape, self.editor_blockrotation);
			self.editor_blockshape = infovec_x;
			self.editor_blockrotation = infovec_y;
		}		
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_Y_INCREASE)
	{
		if(!ModifyBlock(2, IncreaseBlockRotation_Y, __NULL__, __NULL__))
			self.editor_blockrotation = IncreaseBlockRotation_Y(self.editor_blockrotation);		
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_Y_DECREASE)
	{
		if(!ModifyBlock(2, DecreaseBlockRotation_Y, __NULL__, __NULL__))
			self.editor_blockrotation = DecreaseBlockRotation_Y(self.editor_blockrotation);	
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_XZ_INCREASE)
	{
		if(!ModifyBlock(3, __NULL__, __NULL__, IncreaseBlockRotation_XZ))
			self.editor_blockrotation = IncreaseBlockRotation_XZ(self.editor_blockshape, self.editor_blockrotation);	
	}
	else
	if(self.impulse == EDITOR_BLOCKROTATION_XZ_DECREASE)
	{
		if(!ModifyBlock(3, __NULL__, __NULL__, DecreaseBlockRotation_XZ))
			self.editor_blockrotation = DecreaseBlockRotation_XZ(self.editor_blockshape, self.editor_blockrotation);
	}

	if(self.impulse == CLIENT_TOGGLELIGHT)
		stuffcmd(self, "cq_toggleclientlight\n");

	if(self.impulse == 98)
	if(self.tool)
		self.editor_sizetool = !self.editor_sizetool;

	if(self.impulse == 11)	// this turns off edit mode
	{
		self.tool = 0;
		self.editor_sizetool = FALSE;
		ClearEditInfo();
	}
	
	if(self.impulse == 12)
	{
		eprint(GetChunkForLocation(__NULL__, self.playerclusterorg));
	}
	
	// this lets us know when button0 is pressed vs held. 1 = pressed, 2 = held.
	if(self.button0)
	{
		if(self.button0_down < 2)
			self.button0_down++;
	}
	else
		self.button0_down = FALSE;

	if(self.button1)
	{
		if(self.button1_down < 2)
			self.button1_down++;
	}
	else
		self.button1_down = FALSE;

/*	if(time > tracetime)
	{
		tracetime = time+0.06;
		makevectors(self.v_angle);
		targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*20;
		vector tracepostest = TraceCubic(self.origin+self.view_ofs, targetpos, TRUE);
		setorigin(testbox, tracepostest);
	}*/
	
	if(self.button0_down == 1)
	{
		if(genpaused)
			genpaused = FALSE;
	}
	
//	if(self.button3)
	if(self.editor_sizetool)
		return;
	
	if(self.tool >= TOOL_EDITOR_MODIFY && self.tool <= TOOL_EDITOR_INFOEDIT)
	if(!(self.tool == TOOL_EDITOR_INFOEDIT && self.editor_infoedit))
	if(self.button0_down == 1)	// initial button press
	{
//		if(self.loadingchunks || self.loadingbackgroundchunks)
//			centerprint(self, "Tried using a tool when chunks were still loading in. Try again.");
//		else
//		{
			getinside = FALSE;
			
			if(self.tool == TOOL_EDITOR_MODIFY || self.tool == TOOL_EDITOR_COPY || self.tool == TOOL_EDITOR_INFOEDIT)
				getinside = TRUE;
			
			makevectors(self.v_angle);
			targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*tooltracedist*((self.toolsize > TOOLSIZE_EDITOR_CUBIC)*1+1);
			tracepos = TraceCubic(self.origin+self.view_ofs, targetpos, getinside);
			org = GeatNearOrgForTool(tracepos, self.toolsize);

			if(!ToolIsOnEdge(self.playerclusterorg, org, self.toolsize, self.tool, self.editor_selection_mins, self.editor_selection_maxs))
			if(self.tool == TOOL_EDITOR_ADD)
			{
				switch(self.toolsize)
				{									
					case TOOLSIZE_EDITOR_CUBIC:		if(self.editor_blocktype >= baseobjecttypeid)
														AddCubic(GetNearestCubicOrigin(tracepos, chunksize_iseven), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation, TRUE);
													else
														AddCubicArea(GetNearestCubicOrigin(tracepos, chunksize_iseven), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation, self.editor_fillmode);
													break;
					
					case TOOLSIZE_EDITOR_CHUNK:		AddChunk(GetNearChunkOrg(tracepos), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation);							break;
					case TOOLSIZE_EDITOR_CLUSTER:	AddCluster(GetNearClusterOrg(tracepos), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation);						break;
				}
			}
			else
			if(self.tool == TOOL_EDITOR_MODIFY)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		ApplyEditorValuesToCubicArea(GetNearestCubicOrigin(tracepos, chunksize_iseven), TRUE);												break;
				}		
			}
			else
			if(self.tool == TOOL_EDITOR_COPY)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		CopyCubicData(GetNearestCubicOrigin(tracepos, chunksize_iseven));																				break;
					case TOOLSIZE_EDITOR_CHUNK:		SavePrefab_Chunk(GetNearChunkOrg(tracepos));									break;
					case TOOLSIZE_EDITOR_CLUSTER:	SavePrefab_Cluster(GetNearClusterOrg(tracepos));								break;
				}		
			}
			else
			if(self.tool == TOOL_EDITOR_PASTE)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		AddCubic(GetNearestCubicOrigin(tracepos, chunksize_iseven), self.editor_blocktype, self.editor_blockshape, self.editor_blockrotation, TRUE);	break;
					case TOOLSIZE_EDITOR_CHUNK:		LoadPrefab_Chunk(GetNearChunkOrg(tracepos));									break;
					case TOOLSIZE_EDITOR_CLUSTER:	LoadPrefab_Cluster(GetNearClusterOrg(tracepos));								break;
				}		
			}
			else
			if(self.tool == TOOL_EDITOR_INFOEDIT)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CHUNK:		InfoEdit_Chunk(GetNearChunkOrg(tracepos));
					default:	break;
				}
			}
//		}
	}
	else
	if(self.button0_down == 2 && self.tool == TOOL_EDITOR_MODIFY)
	{
//		if(self.loadingchunks || self.loadingbackgroundchunks)
//			centerprint(self, "Tried using a tool when chunks were still loading in. Try again.");
//		else
//		{		
			getinside = FALSE;
			
			if(self.tool == TOOL_EDITOR_MODIFY || self.tool == TOOL_EDITOR_COPY || self.tool == TOOL_EDITOR_INFOEDIT)
				getinside = TRUE;
			
			makevectors(self.v_angle);
			targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*tooltracedist*((self.toolsize > TOOLSIZE_EDITOR_CUBIC)*1+1);
			tracepos = TraceCubic(self.origin+self.view_ofs, targetpos, getinside);
			org = GeatNearOrgForTool(tracepos, self.toolsize);
			
			if(!ToolIsOnEdge(self.playerclusterorg, org, self.toolsize, self.tool, self.editor_selection_mins, self.editor_selection_maxs))
			if(self.tool == TOOL_EDITOR_MODIFY)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		ApplyEditorValuesToCubicArea(GetNearestCubicOrigin(tracepos, chunksize_iseven), FALSE);						break;
				}		
			}
//		}
	}
	else
	if(self.impulse == 99)
	{
//		if(self.loadingchunks || self.loadingbackgroundchunks)
//			centerprint(self, "Tried using a tool when chunks were still loading in. Try again.");
//		else
//		{
			if(self.tool == TOOL_EDITOR_MODIFY || self.tool == TOOL_EDITOR_COPY || self.tool == TOOL_EDITOR_INFOEDIT)
				getinside = TRUE;

			makevectors(self.v_angle);
			targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*tooltracedist*((self.toolsize > TOOLSIZE_EDITOR_CUBIC)*1+1);
			tracepos = TraceCubic(self.origin+self.view_ofs, targetpos, getinside);				
			org = GeatNearOrgForTool(tracepos, self.toolsize);

			if(self.tool == TOOL_EDITOR_ADD)
				self.editor_fillmode = !self.editor_fillmode;
			else	
			if(!ToolIsOnEdge(self.playerclusterorg, org, self.toolsize, self.tool, self.editor_selection_mins, self.editor_selection_maxs))				
			if(self.tool == TOOL_EDITOR_MODIFY)
			{
				switch(self.toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(tracepos));
													vector cubicorg = GetNearestCubicOrigin(tracepos, chunksize_iseven);
													
													if(self.editor_blocktype >= baseobjecttypeid)
														ClearCubic(chunk, cubicorg);
													else
														ClearCubicArea(chunk, cubicorg);
													break;
													
					case TOOLSIZE_EDITOR_CHUNK:		ClearChunk(GetNearChunkOrg(tracepos));											break;
					case TOOLSIZE_EDITOR_CLUSTER:	ClearCluster(GetNearClusterOrg(tracepos));										break;
				}		
			}
//		}			
	}
}