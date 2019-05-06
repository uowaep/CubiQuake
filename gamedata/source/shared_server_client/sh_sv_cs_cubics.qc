// VERSION
int		cubic_revision	= 83;

// WORLD SETTINGS

int 	worldsize;
int 	worldheight;
int		clustersize;
int		chunksize;
int		chunksize_iseven;

int		cubicradius;
int		physicssize;
int		physicssize_iseven;
int 	chunk_sharerange;
int		loadsize;
int		loadsize_iseven;
int		viewsize;
int		viewsize_distant;
int		viewheight;
int		viewheight_distant;
int		loadradiusarea;

int		maxclusters;
int		maxchunks;
int		numslotsforchunkincluster;
int		clusterdataslots;
vector	worlddim;
vector	loadcenter;
vector	viewcenter;
vector	viewcenter_distant;
int		maxviewsize;
int		maxviewheight;
vector	maxviewcenter;
int		clustertablesize;

//		if you modify game logic relating to chunk information, you might want to edit these

int		numworldslots	= 1;
int		WORLDSLOT_WORLDSIZE		= 0;

int		numprechunkvaluesincluster	= 2;
int		CLUSTERSLOT_AVERAGETYPE			= 0; // not used, was going to use for distant drawing.
int		CLUSTERSLOT_NUMVISIBLECUBICS	= 1;

int		numprecubicvaluesinchunk	= 2;
int		CHUNKSLOT_CHUNKBITS				= 0;
int		CHUNKSLOT_NUMVISIBLECUBICS		= 1;

int		numvaluespercubic			= 4;
int		CUBICSLOT_TYPE					= 0;
int		CUBICSLOT_SHAPE					= 1;
int		CUBICSLOT_ROTATION				= 2;
int		CUBICSLOT_CULLBITS				= 3;

.int	numvisiblecubics;

.int	chunkbits;
int		CHUNKBITS_CORPOREAL		= 1;

.*int	cubic_cullbits;
int		CULLBITS_U				= 1;
int		CULLBITS_W				= 2;
int		CULLBITS_S				= 4;
int		CULLBITS_E				= 8;
int		CULLBITS_N				= 16;
int		CULLBITS_D				= 32;
int		CULLBITS_ALL			= 63;	// (1+2+4+8+16+32)

int		CULLBITS_PARTIAL_U		= 64;
int		CULLBITS_PARTIAL_W		= 128;
int		CULLBITS_PARTIAL_S		= 256;
int		CULLBITS_PARTIAL_E		= 512;
int		CULLBITS_PARTIAL_N		= 1024;
int		CULLBITS_PARTIAL_D		= 2048;
int		CULLBITS_PARTIAL_ALL	= 4032;	// (64+128+256+512+1024+2048)

.*int	cubic_blocktype;
int		numblocktypes = 3;
int		BLOCKTYPE_DIRT		= 1;
int		BLOCKTYPE_BRICK		= 2;
int		BLOCKTYPE_BLOCK		= 3;

.*int	cubic_blockshape;
int		numblockshapes	= 4;
int		BLOCKSHAPE_CUBE		= 1;
int		BLOCKSHAPE_RAMP		= 2;
int		BLOCKSHAPE_WEDGETIP	= 3;
int		BLOCKSHAPE_WEDGE	= 4;

.*int	cubic_blockrotation;
int		BLOCKROTATION_E		= 0;
int		BLOCKROTATION_N		= 1;
int		BLOCKROTATION_W		= 2;
int		BLOCKROTATION_S		= 3;
int		BLOCKROTATION_CW_E	= 4;
int		BLOCKROTATION_CW_N	= 5;
int		BLOCKROTATION_CW_W	= 6;
int		BLOCKROTATION_CW_S	= 7;
int		BLOCKROTATION_UD_E	= 8;
int		BLOCKROTATION_UD_N	= 9;
int		BLOCKROTATION_UD_W	= 10;
int		BLOCKROTATION_UD_S	= 11;
int		BLOCKROTATION_CCW_E	= 12;
int		BLOCKROTATION_CCW_N	= 13;
int		BLOCKROTATION_CCW_W	= 14;
int		BLOCKROTATION_CCW_S	= 15;
int		BLOCKROTATION_FW_E	= 16;
int		BLOCKROTATION_FW_N	= 17;
int		BLOCKROTATION_FW_W	= 18;
int		BLOCKROTATION_FW_S	= 19;
int		BLOCKROTATION_BW_E	= 20;
int		BLOCKROTATION_BW_N	= 21;
int		BLOCKROTATION_BW_W	= 22;
int		BLOCKROTATION_BW_S	= 23;

void InitGameVariables()
{
//	WORLD SETTINGS

	// changing the following values will break a generated world (re-generate afterward)
// 	worldsize = 11;							// must be odd
 	worldheight = worldsize;				// must be odd (not working, must set to worldsize to not break stuff)
	clustersize = 3;						// must be odd
	chunksize = 6;							// even and ood both work here
	chunksize_iseven = TRUE;				// set to reflect chunksize

	// changing these values won't break the world, but might affect performance
	cubicradius = 16;						// quake units of center of cubic to edge (this will scale the world)
	physicssize = 3;						// even and odd both work here. (needs to increase if cubic size shrinks if player size doesn't also change)
	physicssize_iseven = FALSE;				// set to reflect physicssize
	chunk_sharerange	= 500;				// doesn't do anything yet
	loadsize = 3;							// must be odd
	loadsize_iseven = FALSE;				// must be FALSE, even values don't work yet
	viewsize = 5;							// must be odd/even if loadsize is odd/even
	viewsize_distant = 3;					// must be odd/even if loadsize is odd/even
	viewheight = 3;							// must be odd/even if loadsize is odd/even
	viewheight_distant = 5;					// must be odd/even if loadsize is odd/even
	loadradiusarea = FALSE;					// broken because of layered loading using cube shaped logic (could try an oval type sphere)

	// set these to match the highest values
	maxviewsize = viewsize;		
	maxviewheight = viewheight_distant;

	
	// do not edit these
	maxclusters = worldsize*worldsize*worldheight;
	maxchunks = pow(worldsize*clustersize, 2)*(worldheight*clustersize);
	numslotsforchunkincluster = numprecubicvaluesinchunk + pow(chunksize, 3)*numvaluespercubic;
	clusterdataslots = numprechunkvaluesincluster+pow(clustersize, 3)*numslotsforchunkincluster;
	worlddim = [worldsize, worldsize, worldheight]*clustersize*chunksize*cubicradius*2;
	loadcenter = '1 1 1'*(loadsize-1)*0.5;
	viewcenter = ('1 1 0'*(viewsize-1)+'0 0 1'*(viewheight-1))*0.5;
	viewcenter_distant = ('1 1 0'*(viewsize_distant-1)+'0 0 1'*(viewheight_distant-1))*0.5;
	maxviewcenter = ('1 1 0'*(maxviewsize-1)+'0 0 1'*(maxviewheight-1))*0.5;
	clustertablesize = maxviewsize*maxviewsize*maxviewheight;
}

int		SFL_ISNEW		= 1;
int		SFL_BUILD		= 2;

.int	enttype;
int		ENT_CLUSTER			= 1;
int		ENT_CHUNK			= 2;
int		ENT_CUBICBBOX		= 3;

int		STAT_TOOL					= 32;
int		STAT_TOOLSIZE				= 33;
int		STAT_PLAYERCLUSTERID		= 34;
int		STAT_EDITOR_BLOCKTYPE		= 35;
int		STAT_EDITOR_BLOCKSHAPE		= 36;
int		STAT_EDITOR_BLOCKROTATION	= 37;

.int	numvertexindexes;
.entity	parentchunk;

vector	VECOFS_NW	= '-1 1 0';
vector	VECOFS_N	= '0 1 0';
vector	VECOFS_NE	= '1 1 0';
vector	VECOFS_W	= '-1 0 0';
vector	VECOFS_C	= '0 0 0';
vector	VECOFS_E	= '1 0 0';
vector	VECOFS_SW	= '-1 -1 0';
vector	VECOFS_S	= '0 -1 0';
vector	VECOFS_SE	= '1 -1 0';

vector	VECOFS_UNW = '-1 1 1';
vector	VECOFS_UN	= '0 1 1';
vector	VECOFS_UNE = '1 1 1';
vector	VECOFS_UW	= '-1 0 1';
vector	VECOFS_U	= '0 0 1';
vector	VECOFS_UE	= '1 0 1';
vector	VECOFS_USW = '-1 -1 1';
vector	VECOFS_US	= '0 -1 1';
vector	VECOFS_USE = '1 -1 1';

vector	VECOFS_DNW = '-1 1 -1';
vector	VECOFS_DN	= '0 1 -1';
vector	VECOFS_DNE = '1 1 -1';
vector	VECOFS_DW	= '-1 0 -1';
vector	VECOFS_D	= '0 0 -1';
vector	VECOFS_DE	= '1 0 -1';
vector	VECOFS_DSW = '-1 -1 -1';
vector	VECOFS_DS	= '0 -1 -1';
vector	VECOFS_DSE = '1 -1 -1';

// these are all also impulses
int		TOOLSIZE_EDITOR_CUBIC	= 100;
int		TOOLSIZE_EDITOR_CHUNK	= 101;
int		TOOLSIZE_EDITOR_CLUSTER	= 102;

int		TOOL_EDITOR_REMOVE	= 110;
int		TOOL_EDITOR_ADD		= 111;
int		TOOL_EDITOR_COPY	= 112;
int		TOOL_EDITOR_PASTE	= 113;

int		EDITOR_BLOCKTYPE_INCREASE			= 120;
int		EDITOR_BLOCKTYPE_DECREASE			= 121;
int		EDITOR_BLOCKSHAPE_INCREASE			= 122;
int		EDITOR_BLOCKSHAPE_DECREASE			= 123;
int		EDITOR_BLOCKROTATION_Y_INCREASE		= 124;
int		EDITOR_BLOCKROTATION_Y_DECREASE		= 125;
int		EDITOR_BLOCKROTATION_XZ_INCREASE	= 126;
int		EDITOR_BLOCKROTATION_XZ_DECREASE	= 127;

int			clusters_allocated;
entity		*cluster_ent;
.*entity	chunk_ent;

int GetClusterOccupancyRef(vector ofs)
{
	ofs -= '1 1 1'*clustersize*chunksize*cubicradius;
	ofs *= 1/(clustersize*chunksize*cubicradius*2);
	ofs += ([maxviewsize, maxviewsize, maxviewheight])*0.5;
	return ofs_x*maxviewsize*maxviewsize + ofs_y*maxviewsize + ofs_z;
}


int GetClusterRef(vector ofs)
{
	ofs -= '1 1 1'*clustersize*chunksize*cubicradius;
	ofs *= 1/(clustersize*chunksize*cubicradius*2);
	ofs += ([worldsize, worldsize, worldheight])*0.5;
	return ofs_x*worldsize*worldsize + ofs_y*worldsize + ofs_z;
}

vector GetClusterOffset(float refid)
{
	vector ofs;
	ofs_x = floor(refid/(worldsize*worldsize));
	ofs_y = floor((refid-(ofs_x*worldsize*worldsize))/worldsize);
	ofs_z = refid - (ofs_x*worldsize*worldsize) - ofs_y*worldsize;
	ofs += (([worldsize, worldsize, worldheight])*-0.5) + '1 1 1'*0.5;
	ofs *= clustersize*chunksize*cubicradius*2;

	return ofs;
}

int GetChunkOriginRef(vector ofs)
{
	ofs -= '1 1 1'*chunksize*cubicradius;
	ofs *= 1/(chunksize*cubicradius*2);
	ofs += ([worldsize, worldsize, worldheight])*clustersize*0.5;
	return ofs_x*pow(worldsize*clustersize, 2) + ofs_y*(worldsize*clustersize) + ofs_z;
}

vector GetChunkOrigin(float refid)
{
	vector ofs;
	ofs_x = floor(refid/pow(worldsize*clustersize, 2));
	ofs_y = floor((refid-(ofs_x*pow(worldsize*clustersize, 2)))/(worldsize*clustersize));
	ofs_z = refid - (ofs_x*(worldsize*clustersize)*(worldsize*clustersize)) - ofs_y*(worldsize*clustersize);
	ofs += (([worldsize*clustersize, worldsize*clustersize, worldheight*clustersize])*-0.5) + '1 1 1'*0.5;
	ofs *= chunksize*cubicradius*2;

	return ofs;
}

int GetChunkRef(vector ofs)
{
	ofs -= '1 1 1'*chunksize*cubicradius;
	ofs *= 1/(chunksize*cubicradius*2);
	ofs += '1 1 1'*clustersize*0.5;
	return ofs_x*clustersize*clustersize + ofs_y*clustersize + ofs_z;
}

vector GetChunkOffset(float refid)
{
	vector ofs;
	ofs_x = floor(refid/(clustersize*clustersize));
	ofs_y = floor((refid-(ofs_x*clustersize*clustersize))/clustersize);
	ofs_z = refid - (ofs_x*clustersize*clustersize) - ofs_y*clustersize;
	ofs += '-1 -1 -1'*clustersize*0.5 + '1 1 1'*0.5;
	ofs *= chunksize*cubicradius*2;

	return ofs;
}

int GetCubicRef(vector ofs)
{
	ofs -= '1 1 1'*cubicradius;
	ofs *= 1/(cubicradius*2);
	ofs += '1 1 1'*chunksize*0.5;
	return ofs_x*chunksize*chunksize + ofs_y*chunksize + ofs_z;
}

vector GetCubicOffset(float refid)
{
	vector ofs;
	ofs_x = floor(refid/(chunksize*chunksize));
	ofs_y = floor((refid-(ofs_x*chunksize*chunksize))/chunksize);
	ofs_z = refid - (ofs_x*chunksize*chunksize) - ofs_y*chunksize;
	ofs += '-1 -1 -1'*chunksize*0.5 + '1 1 1'*0.5;
	ofs *= cubicradius*2;

	return ofs;
}

int	GetCubicStatus(entity chunk, vector cubicorg)
{
	if(!chunk)
		return -1;
	
	int memslot = GetCubicRef(cubicorg-chunk.origin);

	if(chunk.cubic_blocktype[memslot] > 0)
		return memslot;

	return -1;
}

vector GetNearClusterOrg(vector org)
{
	vector clusterorg;
	float clusterwidth = (clustersize*chunksize*cubicradius*2);
	clusterorg_x = rint(org_x/clusterwidth)*clusterwidth;
	clusterorg_y = rint(org_y/clusterwidth)*clusterwidth;
	clusterorg_z = rint(org_z/clusterwidth)*clusterwidth;
	return clusterorg;
}

vector GetNearChunkOrg(vector org)
{
	vector chunkorg;
	float chunkwidth = (chunksize*cubicradius*2);
	chunkorg_x = rint(org_x/chunkwidth)*chunkwidth;
	chunkorg_y = rint(org_y/chunkwidth)*chunkwidth;
	chunkorg_z = rint(org_z/chunkwidth)*chunkwidth;	
	return chunkorg;
}


vector GetNearestCubicOrigin(vector org, int centeroffset)
{
	vector cubicorg;
	
	if(centeroffset)
	{
		cubicorg_x = floor(org_x/(cubicradius*2))*cubicradius*2; 
		cubicorg_y = floor(org_y/(cubicradius*2))*cubicradius*2;
		cubicorg_z = floor(org_z/(cubicradius*2))*cubicradius*2;
		cubicorg += '1 1 1'*cubicradius;
	}
	else
	{
		cubicorg_x = rint(org_x/(cubicradius*2))*cubicradius*2; 
		cubicorg_y = rint(org_y/(cubicradius*2))*cubicradius*2;
		cubicorg_z = rint(org_z/(cubicradius*2))*cubicradius*2;
	}
	
	return cubicorg;
}

float GetToolScale(int toolsize)
{
	float toolscale;
	
	switch(toolsize)
	{
		case TOOLSIZE_EDITOR_CUBIC:		toolscale = 1;						break;
		case TOOLSIZE_EDITOR_CHUNK:		toolscale = chunksize;				break;
		case TOOLSIZE_EDITOR_CLUSTER:	toolscale = chunksize*clustersize;	break;
	}	
	
	return toolscale;
}

//#ifdef SSQC
/*entity GetClusterForLocation(entity cluster, vector clusterorg)
{
	if(cluster && clusterorg == cluster.origin)
		return cluster;
		
	for(cluster = findradius(clusterorg, 0); cluster; cluster = cluster.chain)
		if(cluster.enttype == ENT_CLUSTER)
			return cluster;

	return __NULL__;
}*/

entity GetClusterForLocation(entity cluster, vector clusterorg)
{
	if(!clusters_allocated)
		return __NULL__;

	return cluster_ent[GetClusterRef(clusterorg)];
}
//#endif

//#ifdef SSQC
entity GetChunkForLocation(entity chunk, vector cubicchunkorg)
{
	if(!clusters_allocated)
		return __NULL__;
	
	entity cluster = cluster_ent[GetClusterRef(GetNearClusterOrg(cubicchunkorg))];
	
	if(!cluster)
		return __NULL__;
	
	chunk = cluster.chunk_ent[GetChunkRef(cubicchunkorg-cluster.origin)];	
	
	if(!chunk)
	{
	//	print("no chunk\n");
		return __NULL__;
	}
	
	return chunk;
}
//#endif

/*#ifdef CSQC
entity GetChunkForLocation(entity chunk, vector cubicchunkorg)
{
	if(chunk && cubicchunkorg == chunk.origin)
		return chunk;

	for(chunk = findradius(cubicchunkorg, 0); chunk; chunk = chunk.chain)
		if(chunk.enttype == ENT_CHUNK)
			return chunk;

	return __NULL__;
}
#endif*/

int	CubicSharesSide(entity chunk, vector cubicorg)
{
	int cullmatch, cubicslot;
	vector ofs, nearcubicorg, nearchunkorg;
	entity nearchunk;
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	cullmatch = CULLBITS_D;		break;
			case 1:	ofs = VECOFS_W;	cullmatch = CULLBITS_E;		break;
			case 2:	ofs = VECOFS_S;	cullmatch = CULLBITS_N;		break;
			case 3:	ofs = VECOFS_E;	cullmatch = CULLBITS_W;		break;
			case 4:	ofs = VECOFS_N;	cullmatch = CULLBITS_S;		break;
			case 5:	ofs = VECOFS_D;	cullmatch = CULLBITS_U;		break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		nearchunkorg = GetNearChunkOrg(nearcubicorg);
		if(!chunk || nearchunkorg != chunk.origin)
			nearchunk = GetChunkForLocation(__NULL__, nearchunkorg);
		else
			nearchunk = chunk;
		
		if(!nearchunk)
			continue;
		
		cubicslot = GetCubicStatus(nearchunk, nearcubicorg);
		
		if(cubicslot != -1)
			return TRUE;		
	}		
	
	return FALSE;
}

int CubicSharesCulledSide(entity chunk, vector cubicorg)
{
	int cullmatch, cubicslot, cullbits;
	vector ofs, nearcubicorg, nearchunkorg;
	entity nearchunk;
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	cullmatch = CULLBITS_D;		break;
			case 1:	ofs = VECOFS_W;	cullmatch = CULLBITS_E;		break;
			case 2:	ofs = VECOFS_S;	cullmatch = CULLBITS_N;		break;
			case 3:	ofs = VECOFS_E;	cullmatch = CULLBITS_W;		break;
			case 4:	ofs = VECOFS_N;	cullmatch = CULLBITS_S;		break;
			case 5:	ofs = VECOFS_D;	cullmatch = CULLBITS_U;		break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		nearchunkorg = GetNearChunkOrg(nearcubicorg);
		if(!chunk || nearchunkorg != chunk.origin)
			nearchunk = GetChunkForLocation(__NULL__, nearchunkorg);
		else
			nearchunk = chunk;
		
		if(!nearchunk)
			continue;
		
		cubicslot = GetCubicStatus(nearchunk, nearcubicorg);
		
		if(cubicslot == -1)
			continue;
		
		cullbits = nearchunk.cubic_cullbits[cubicslot];
		
		if(cullbits & cullmatch)
			return TRUE;
	}
	
	return FALSE;
}

int CubicSharesEdges(vector cubicorg, vector start)
{
	int foundsharededges;
	vector ofs, nearcubicorg;
	vector forwardvec = start - cubicorg;
	
	for(int edgecount = 0; edgecount < 12; edgecount++)
	{
		switch(edgecount)
		{
			case 0:		ofs = VECOFS_NW;	break;
			case 1: 	ofs = VECOFS_NE;	break;
			case 2: 	ofs = VECOFS_SW;	break;
			case 3: 	ofs = VECOFS_SE;	break;
			case 4: 	ofs = VECOFS_UN;	break;
			case 5: 	ofs = VECOFS_UE;	break;
			case 6: 	ofs = VECOFS_UW;	break;
			case 7: 	ofs = VECOFS_US;	break;
			case 8:		ofs = VECOFS_DN;	break;
			case 9:		ofs = VECOFS_DE;	break;
			case 10:	ofs = VECOFS_DW;	break;
			case 11:	ofs = VECOFS_DS;	break;			
		}
		
		if((ofs_x >= 0 && forwardvec_x >= 0) || (ofs_x <= 0 && forwardvec_x <= 0))
		if((ofs_y >= 0 && forwardvec_y >= 0) || (ofs_y <= 0 && forwardvec_y <= 0))
		if((ofs_z >= 0 && forwardvec_z >= 0) || (ofs_z <= 0 && forwardvec_z <= 0))
		{
			nearcubicorg = GetNearestCubicOrigin(cubicorg+ofs*cubicradius*2, chunksize_iseven);
			if(GetCubicStatus(GetChunkForLocation(__NULL__, GetNearChunkOrg(nearcubicorg)), nearcubicorg) != -1)
			{
				foundsharededges++;
			
				if(foundsharededges == 3)
					return TRUE;		
			}			
		}
	}
	
	return FALSE;
}

vector NearestNearCubicOrg(vector cubicorg, vector start)
{
	vector ofs, nearcubicorg, nearestcubicorg, offsettostart, shortestoffset;
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
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
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		
		offsettostart = nearcubicorg - start;
		if(shortestoffset == '0 0 0' || (offsettostart*offsettostart < shortestoffset*shortestoffset))
		{
			nearestcubicorg = nearcubicorg;
			shortestoffset = offsettostart;
		}
	}
	
	return nearestcubicorg;	
}

vector TraceCubic(vector start, vector end, int getinside)
{
	#ifdef SSQC
	int cullbits;
	#endif
	vector cubicorg;
	vector lastcubicorg = GetNearestCubicOrigin(start, chunksize_iseven);
	entity chunk = __NULL__;
	vector offset = normalize(end-start)*cubicradius;

	for(vector pos = start; (start-pos)*(start-pos) < (start-end)*(start-end); pos = pos+offset)
	{
		cubicorg = GetNearestCubicOrigin(pos, chunksize_iseven);
	
		if(cubicorg != lastcubicorg)
		{
			chunk = GetChunkForLocation(chunk, GetNearChunkOrg(pos));			
			
			if(chunk)
			{
				#ifdef SSQC
				cullbits = chunk.cubic_cullbits[GetCubicRef(cubicorg-chunk.origin)];
				if((cullbits & CULLBITS_ALL) == CULLBITS_ALL)
				{
					if(getinside)
						return NearestNearCubicOrg(cubicorg, start);
					else
						return lastcubicorg;
				}
				#endif
				
				if(GetCubicStatus(chunk, cubicorg) != -1)
				{
					if(getinside)
						return cubicorg;
					else
					{
						if(CubicSharesSide(chunk, lastcubicorg))	// checks if the lastcubicorg is touching another cubic side
							return lastcubicorg;
						else
						{
							cubicorg = NearestNearCubicOrg(cubicorg, start);	// closest cubic from the first solid cubic found

							if(GetCubicStatus(GetChunkForLocation(chunk, GetNearChunkOrg(cubicorg)), cubicorg) == -1)	// check if nearest is located at an empty, 
								return cubicorg;	// cubic was empty so trace ends there
							else
								return NearestNearCubicOrg(cubicorg, start);	// cubic was not empty so set trace 1 cubic closer
						}
					}
				}
			}
			
			#ifdef CSQC
			if(CubicSharesCulledSide(chunk, cubicorg))	// csqc doesn't know about non-visible cubics, so we must check for culled sides of visible cubics to know about them
			{
				if(getinside)
					return NearestNearCubicOrg(cubicorg, start);
				else
					return lastcubicorg;
			}
			else
			if(CubicSharesEdges(cubicorg, start))
			{
				if(getinside)
					return NearestNearCubicOrg(NearestNearCubicOrg(cubicorg, start), start);
				else
					return lastcubicorg;				
			}
			#endif
			
			lastcubicorg = cubicorg;
		}
	}
	
	return end;
}

int ToolIsOnEdge(vector clusterpos, vector toolpos)
{
	vector editsizeA = ('1 1 0'* (viewsize-1) + '0 0 1'*(viewheight-1))*clustersize*chunksize*cubicradius;
	vector editsizeB = ('1 1 0'* (viewsize_distant-1) + '0 0 1'*(viewheight_distant-1))*clustersize*chunksize*cubicradius;
	
	if(toolpos_x <= clusterpos_x - editsizeA_x || toolpos_x >= clusterpos_x + editsizeA_x
	|| toolpos_y <= clusterpos_y - editsizeA_y || toolpos_y >= clusterpos_y + editsizeA_y
	|| toolpos_z <= clusterpos_z - editsizeA_z || toolpos_z >= clusterpos_z + editsizeA_z)
	if(toolpos_x <= clusterpos_x - editsizeB_x || toolpos_x >= clusterpos_x + editsizeB_x
	|| toolpos_y <= clusterpos_y - editsizeB_y || toolpos_y >= clusterpos_y + editsizeB_y
	|| toolpos_z <= clusterpos_z - editsizeB_z || toolpos_z >= clusterpos_z + editsizeB_z)		
		return TRUE;
	
	if(toolpos_x < worlddim_x*-0.5 || toolpos_x > worlddim_x*0.5
	|| toolpos_y < worlddim_y*-0.5 || toolpos_y > worlddim_y*0.5
	|| toolpos_z < worlddim_z*-0.5 || toolpos_z > worlddim_z*0.5)
		return TRUE;
		
	return FALSE;
}

void FreeChunkAllocations(entity chunk)
{
	memfree(chunk.cubic_blocktype);		
	memfree(chunk.cubic_blockshape);
	memfree(chunk.cubic_blockrotation);
	memfree(chunk.cubic_cullbits);
}