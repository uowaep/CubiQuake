// VERSION
int		cq_version		= 170;
string	cubic_revision	= "cubiquake r170";

// WORLD SETTINGS

int 	worldsize;
int 	worldheight;
int		clustersize;
int		chunksize;
int		chunksize_iseven;
vector	dungeonsize;

float	cubicradius;
int		physicssize;
int		physicssize_iseven;
int 	chunk_sharerange;
int		loadsize;
int		loadsize_iseven;
int		viewsize;
int		viewheight;
int		viewsize_distant;
int		viewheight_distant;
int		loadradiusarea;

int		maxcubicupdates;
int		maxchunksghostedperframe;

int		maxclusters;
int		maxchunks;
int		numslotsforchunkincluster;
int		clusterdataslots;
vector	worlddim;
vector	dungeondim;
vector	clusterdim;
vector	chunkdim;
vector	loadcenter;
vector	viewcenter;
vector	viewcenter_distant;
int		maxviewsize;
int		maxviewheight;
vector	maxviewcenter;
int		maxbloatents;
//int		clustertablesize;

#ifdef CSQC
int		maxlightradius;
vector	ambientlight;
#endif


//		if you modify game logic relating to chunk information, you might want to edit these

int		numworldslots	= 3;	// i'll have to introduce a new file name to add versions to the world file, or use slot 4
int		WORLDSLOT_WORLDSIZE		= 0;
int		WORLDSLOT_CLUSTERSIZE	= 1;
int		WORLDSLOT_CHUNKSIZE		= 2;

int		numprecubicvaluesinchunk	= 2;
int		CHUNKSLOT_CHUNKBITS				= 0;
int		CHUNKSLOT_NUMVISIBLECUBICS		= 1;

int		numprechunkvaluesincluster	= 2;
int		CLUSTERSLOT_VERSION				= 0;
int		CLUSTERSLOT_NUMVISIBLECUBICS	= 1;

int		numsideinfoslots = 24;
int		numprefabgenvaluesinchunk	= numsideinfoslots+4;
int		olda_numprefabgenvaluesinchunk = 27;

int		PREFABCHUNKSLOT_CHUNKSIDETYPE_0		= 0;	// 0-5
int		PREFABCHUNKSLOT_CONNECTIONFIT_0		= 6;	// 6-11
int		PREFABCHUNKSLOT_CONNECTIONFLAGS_0	= 12;	// 12-17
int		PREFABCHUNKSLOT_GROUPSIZE_0			= 18;	// 18-23

int		PREFABCHUNKSLOT_ZONE				= 24;
int		PREFABCHUNKSLOT_CHANCE				= 25;
int		PREFABCHUNKSLOT_VERSION				= 26;	// was chunkflags, but chunkflags could only have been 0 or 1 - r161
int		PREFABCHUNKSLOT_CHUNKFLAGS			= 27;

// prefab connection flags
int		CFL_ALLOWROTATEDFIT			= 1;

// prefab chunk flags
int		CHFL_ALLOWSAMEZONEPASSAGE	= 1;


int		numvaluespercubic			= 5;
int		olda_numvaluespercubic		= 4;
int		CUBICSLOT_TYPE					= 0;
int		CUBICSLOT_SHAPE					= 1;
int		CUBICSLOT_ROTATION				= 2;
int		CUBICSLOT_CULLBITS				= 3;
int		CUBICSLOT_HEALTH				= 4;	// not saved in prefabs

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
// below 0 values are for misc stuff not accessable to the editor blocktype tool
int		BLOCKTYPE_EDIT		= -1;

//int		BLOCKTYPE_DMG_20	= -2;
//int		BLOCKTYPE_DMG_40	= -3;
//int		BLOCKTYPE_DMG_60	= -4;
//int		BLOCKTYPE_DMG_80	= -5;

int		BLOCKTYPE_DMG_10	= -2;
int		BLOCKTYPE_DMG_20	= -3;
int		BLOCKTYPE_DMG_30	= -4;
int		BLOCKTYPE_DMG_40	= -5;
int		BLOCKTYPE_DMG_50	= -6;
int		BLOCKTYPE_DMG_60	= -7;
int		BLOCKTYPE_DMG_70	= -8;
int		BLOCKTYPE_DMG_80	= -9;
int		BLOCKTYPE_DMG_90	= -10;

int		BLOCKTYPE_DMG_LOW	= BLOCKTYPE_DMG_10;
int		BLOCKTYPE_DMG_HIGH	= BLOCKTYPE_DMG_90;
float	maxdmghealth			= 90;
float	dmghealthincrementsize	= 10;

// 0 is for an empty block although GetCubicStaus returns -1 for empty cubics (normally returns the blocktype)

// 1 - 100 are reserved for textures types
.int	blocktype;
int		BLOCKTYPE_DIRT		= 1;
int		BLOCKTYPE_BRICK		= 2;
int		BLOCKTYPE_BLOCK		= 3;
int		BLOCKTYPE_SUPPORT	= 4;
int		BLOCKTYPE_GORE		= 5;
int		BLOCKTYPE_STONE		= 6;
int		BLOCKTYPE_METAL		= 7;
int		BLOCKTYPE_METALB	= 8;
int		BLOCKTYPE_METALC	= 9;
int		BLOCKTYPE_WOOD		= 10;
int		BLOCKTYPE_BLUESTONE	= 11;
int		BLOCKTYPE_BLUEMETAL	= 12;
int		BLOCKTYPE_DECMETAL	= 13;
int		numtextureblocktypes = 13;

// 101 - 256 are reserved for object types
// (This can go higher, but SendCubics() and UpdateChunkBuildData() must be edited to transfer more than a byte for this info.)
int		baseobjecttypeid	= 101;
int		BLOCKTYPE_TORCH		= baseobjecttypeid+0;
int		numobjectblocktypes	= 1;

#ifdef SSQC
.int	blockshape;
#endif
.*int	cubic_blockshape;
int		numblockshapes	= 5;
int		BLOCKSHAPE_CUBE		= 1;
int		BLOCKSHAPE_RAMP		= 2;
int		BLOCKSHAPE_WEDGETIP	= 3;
int		BLOCKSHAPE_WEDGE	= 4;
int		BLOCKSHAPE_SLAB		= 5;

#ifdef SSQC
.int	blockrotation;
#endif
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

#ifdef SSQC
.int	blockhealth;
#endif
.*int	cubic_health;

//		CHUNK SENDFLAGS
int		SFL_ISNEW		= 1;
int		SFL_BUILD		= 2;
int		SFL_INITIALIZE	= 4;
int		SFL_DAMAGED		= 8;
int		SFL_UPDATE		= 16;	// this is used, even though it doesn't look like it

//		OBJECT SENDFLAGS
// it doesn't matter if we use the same values as chunks since the only thing that will be shared is SFL_ISNEW
//float	SFL_ISNEW			= 1;	// already defined
int		SFL_MOVE			= 2;
int		SFL_STOP			= 4;
int		SFL_ANIMATE			= 8;
int		SFL_FACE			= 16;

//core starts at 100
//mods should start at 200 ... or w/e
int		EVENT_CUBICHEALTH	= 100;

.int	enttype;
int		ENT_CLUSTER									= 1;
int		ENT_CHUNK									= 2;
int		ENT_CHUNKBLOAT								= 3;
int		ENT_CUBICBBOX								= 4;
int		ENT_INFOEDIT_SELECTION						= 5;
int		ENT_INFOEDIT_SELECTION_GROUPSIZE_EXTEND 	= 6;
int		ENT_MODIFYSIDE_SELECTION					= 7;
int		ENT_OBJ										= 8;

int		STAT_TOOL							= 33;
int		STAT_TOOLSIZE						= 34;
int		STAT_PLAYERCLUSTERID				= 35;
int		STAT_EDITOR_BLOCKTYPE				= 36;
int		STAT_EDITOR_BLOCKSHAPE				= 37;
int		STAT_EDITOR_BLOCKROTATION			= 38;
int		STAT_EDITOR_INFOEDIT				= 39;
int		STAT_EDITOR_EDITCHUNK				= 40;
int		STAT_EDITOR_FILLMODE				= 41;
int		STAT_EDITOR_SIZETOOL				= 42;

int		STAT_EDITOR_CHUNKSIDETYPE_UP		= 43;
int		STAT_EDITOR_CHUNKSIDETYPE_WEST		= 44;
int		STAT_EDITOR_CHUNKSIDETYPE_SOUTH		= 45;
int		STAT_EDITOR_CHUNKSIDETYPE_EAST		= 46;
int		STAT_EDITOR_CHUNKSIDETYPE_NORTH		= 47;
int		STAT_EDITOR_CHUNKSIDETYPE_DOWN		= 48;
int		STAT_EDITOR_CHUNKSIDEFIT_UP			= 49;
int		STAT_EDITOR_CHUNKSIDEFIT_WEST		= 50;
int		STAT_EDITOR_CHUNKSIDEFIT_SOUTH		= 51;
int		STAT_EDITOR_CHUNKSIDEFIT_EAST		= 52;
int		STAT_EDITOR_CHUNKSIDEFIT_NORTH		= 53;
int		STAT_EDITOR_CHUNKSIDEFIT_DOWN		= 54;
int		STAT_EDITOR_CHUNKSIDEFLAGS_UP		= 55;
int		STAT_EDITOR_CHUNKSIDEFLAGS_WEST		= 56;
int		STAT_EDITOR_CHUNKSIDEFLAGS_SOUTH	= 57;
int		STAT_EDITOR_CHUNKSIDEFLAGS_EAST		= 58;
int		STAT_EDITOR_CHUNKSIDEFLAGS_NORTH	= 59;
int		STAT_EDITOR_CHUNKSIDEFLAGS_DOWN		= 60;
int		STAT_EDITOR_CHUNKGROUPSIZE_UP		= 61;
int		STAT_EDITOR_CHUNKGROUPSIZE_WEST		= 62;
int		STAT_EDITOR_CHUNKGROUPSIZE_SOUTH	= 63;
int		STAT_EDITOR_CHUNKGROUPSIZE_EAST		= 64;
int		STAT_EDITOR_CHUNKGROUPSIZE_NORTH	= 65;
int		STAT_EDITOR_CHUNKGROUPSIZE_DOWN		= 66;

int		STAT_EDITOR_CHUNKZONE				= 67;
int		STAT_EDITOR_CHUNKCHANCE				= 68;
int		STAT_EDITOR_CHUNKFLAGS				= 69;

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

int		TOOL_EDITOR_MODIFY		= 110;
int		TOOL_EDITOR_ADD			= 111;
int		TOOL_EDITOR_COPY		= 112;
int		TOOL_EDITOR_PASTE		= 113;
int		TOOL_EDITOR_INFOEDIT	= 114;

int		EDITOR_BLOCKTYPE_INCREASE			= 120;
int		EDITOR_BLOCKTYPE_DECREASE			= 121;
int		EDITOR_BLOCKSHAPE_INCREASE			= 122;
int		EDITOR_BLOCKSHAPE_DECREASE			= 123;
int		EDITOR_BLOCKROTATION_Y_INCREASE		= 124;
int		EDITOR_BLOCKROTATION_Y_DECREASE		= 125;
int		EDITOR_BLOCKROTATION_XZ_INCREASE	= 126;
int		EDITOR_BLOCKROTATION_XZ_DECREASE	= 127;

int		CLIENT_TOGGLELIGHT	= 150;

.int	chunkconnectiontype;
int		numconnectiontypes = 6;
int		CHUNKCONNECTION_GENERATED	= -3;
int		CHUNKCONNECTION_FREE		= -2;
int		CHUNKCONNECTION_EDGE		= -1;
int		CHUNKCONNECTION_CLOSED		= 0;
int		CHUNKCONNECTION_OPENED		= 1;
int		CHUNKCONNECTION_PASSAGE		= 2;
int		CHUNKCONNECTION_ANY			= 3;
int		CHUNKCONNECTION_RANDOM		= 4;
int		CHUNKCONNECTION_REQUIREONE	= 5;

int		tooltracedist		= 15;

.int	cubicmemslot;

int			clusters_allocated;
entity		*cluster_ent;
.*entity	chunk_ent;
.int		bloatlevel;
.int		updateref;

.float	lightradius;
.float	lightbrightness;
.vector	lightcolor;

#ifdef SSQC
.*float		chunk_playerdelay;
#endif

// editor fields
.int		prefabzone;
.int		prefabchance;
.int		prefabchunkflags;

.vector	origin_previous;
.int	origin_previous_set;
.float	physics_maxslidespeed;

.int	faceenemy;
int		FACE_ORIENTYAW		= 1;
int		FACE_LOCALPLAYER	= 2;
int		FACE_NOUPDATE		= 4;

.int	objtype;
int		OBJ_ITEM		= 1;
int		OBJ_GIB			= 2;
int		OBJ_ROCKET		= 3;
int		OBJ_BLOCK		= 4;

void InitGameVariables()
{
//	WORLD SETTINGS

	// changing the following values will break a generated world (re-generate afterward. FIXME: save all unchangeable values to the world.)
// 	worldsize = 11;							// width in clusters. (must be odd. this is set via cvar or by the existing world)
 	worldheight = worldsize;				// height in clusters. (must be odd. - not working, must set to worldsize to not break stuff)
//	clustersize = 1;						// width/height in chunks. (must be odd)
//	chunksize = 13;							// width/height in cubics. (even and ood both work here)

	// changing these values won't break the world, but might affect performance
//	cubicradius = 16;						// quake units of center of cubic to edge (this will scale the world)
	physicssize = 3;						// width of area in cubics to create bbox/bsp ents around player (even and odd both work here. needs to increase if cubic size shrinks and if player size isn't also reduced and vise verca.)
	chunk_sharerange	= 500;				// doesn't do anything yet
	loadsize = 3;							// width of area loaded immediately upon player movement. usually only happens during spawn. (must be odd. even values don't work ...yet...)
//	viewsize = 7;							// width of 1st stage of background cluster loading (must be odd/even if loadsize is odd/even)
//	viewheight = 3;							// height of 1st stage of background cluster loading (must be odd/even if loadsize is odd/even)
	
	// the distant values are being used to load extended elevations at the 2nd background stage rather than trying to draw further out toward the horizon (better up/down view distance)
//	viewsize_distant = 3;					// width of 2nd stage of background cluster loading (must be odd/even if loadsize is odd/even)
//	viewheight_distant = 5;					// height of 2nd stage of background cluster loading (must be odd/even if loadsize is odd/even)
	loadradiusarea = FALSE;					// the cluster load area is a sphere instead of rectangle shape (broken because of layered loading using current rectangle shaped logic)

	// these values are for regulating how many times certain large/heavy loops are allowed to iterate per frame
//	maxcubicupdates	= 200;					// maximum number of cubics that can be sent in a single chunk entity before spawning more entities to relay the data without overloading memory (or something)
//	maxchunksloadedperframe = 12;			// the chunk loading loop in LoadWorldForPlayer and the speed for network updating when sending existing chunks
	maxchunksghostedperframe = 9;			// the chunk ghosting loop in RemoveUnoccupiedClusters (NOT IN USE)
//	chunkremovaldelay = 10;					// how many seconds a chunk should hang around when not occupied, to avoid having to readload too often
	// set these to match the highest values
//	maxviewsize = max(viewsize, viewsize_distant);		
//	maxviewheight = max(viewheight, viewheight_distant);

#ifdef CSQC
	// client
	maxlightradius = chunksize*cubicradius*2*2;	// maximum light radius. this can be any value, but this equation is recommended for performance.
	
#endif

	// do not edit these
	maxclusters = worldsize*worldsize*worldheight;
	maxchunks = pow(worldsize*clustersize, 2)*(worldheight*clustersize);
	numslotsforchunkincluster = numprecubicvaluesinchunk + pow(chunksize, 3)*numvaluespercubic;
	clusterdataslots = numprechunkvaluesincluster+pow(clustersize, 3)*numslotsforchunkincluster;
	worlddim = [worldsize, worldsize, worldheight]*clustersize*chunksize*cubicradius*2;
	dungeondim = dungeonsize*clustersize*chunksize*cubicradius*2;
	clusterdim = '1 1 1'*clustersize*chunksize*cubicradius*2;
	chunkdim = '1 1 1'*chunksize*cubicradius*2;
	loadcenter = '1 1 1'*(loadsize-1)*0.5;
	maxbloatents = ceil(pow(chunksize, 3)/maxcubicupdates)-1;
	
//	viewcenter = ('1 1 0'*(viewsize-1)+'0 0 1'*(viewheight-1))*0.5;
//	viewcenter_distant = ('1 1 0'*(viewsize_distant-1)+'0 0 1'*(viewheight_distant-1))*0.5;
//	maxviewcenter = ('1 1 0'*(maxviewsize-1)+'0 0 1'*(maxviewheight-1))*0.5;
//	clustertablesize = maxviewsize*maxviewsize*maxviewheight;
	
	if(chunksize*0.5 == floor(chunksize*0.5))
		chunksize_iseven = TRUE;
	
	if(physicssize*0.5 == floor(physicssize*0.5))
		physicssize_iseven = TRUE;
	
	if(loadsize*0.5 == floor(loadsize*0.5))
		loadsize_iseven = TRUE;
}

void SetDependentViewValues()
{
	maxviewsize = max(viewsize, viewsize_distant);		
	maxviewheight = max(viewheight, viewheight_distant);
	viewcenter = ('1 1 0'*(viewsize-1)+'0 0 1'*(viewheight-1))*0.5;
	viewcenter_distant = ('1 1 0'*(viewsize_distant-1)+'0 0 1'*(viewheight_distant-1))*0.5;
	maxviewcenter = ('1 1 0'*(maxviewsize-1)+'0 0 1'*(maxviewheight-1))*0.5;
}

int	NonSolidType(int type)
{
	if(type == BLOCKTYPE_TORCH)
		return TRUE;

	return FALSE;
}

int GetFixedRotation(int type, int rotation, int shape)
{
	if(!(NonSolidType(type)))
	if(shape == BLOCKSHAPE_CUBE)
		rotation = 0;
	
	return rotation;
}

/*int GetClusterOccupancyRef(vector ofs)
{
	ofs -= '1 1 1'*clustersize*chunksize*cubicradius;
	ofs *= 1/(clustersize*chunksize*cubicradius*2);
	ofs += ([maxviewsize, maxviewsize, maxviewheight])*0.5;
	return ofs_x*maxviewsize*maxviewsize + ofs_y*maxviewsize + ofs_z;
}*/

int GetClusterRef(vector ofs)
{
	if(ofs_x > worlddim_x*0.5 || ofs_x < worlddim_x*-0.5
	|| ofs_y > worlddim_y*0.5 || ofs_y < worlddim_y*-0.5
	|| ofs_z > worlddim_z*0.5 || ofs_z < worlddim_z*-0.5)
	{
		print("Warning: Looking for cluster id out of world bounds.\n");
		return -1;	
	}
	
	ofs -= '1 1 1'*clustersize*chunksize*cubicradius;
	ofs = ofs/(clustersize*chunksize*cubicradius*2);
	ofs += ([worldsize, worldsize, worldheight])*0.5;
	
	int ref = ofs_x*worldsize*worldsize + ofs_y*worldsize + ofs_z;
	
	if(ref >= maxclusters || ref < 0)
		return -1;
	
	return ref;
}

vector GetClusterOffset(float refid)
{
	vector ofs = '0 0 0';
	ofs_x = floor(refid/(worldsize*worldsize));
	ofs_y = floor((refid-(ofs_x*worldsize*worldsize))/worldsize);
	ofs_z = refid - (ofs_x*worldsize*worldsize) - ofs_y*worldsize;
	ofs += (([worldsize, worldsize, worldheight])*-0.5) + '1 1 1'*0.5;
	ofs = ofs*clustersize*chunksize*cubicradius*2;

	return ofs;
}

int GetChunkOriginRef(vector ofs)
{
	if(ofs_x > worlddim_x*0.5 || ofs_x < worlddim_x*-0.5
	|| ofs_y > worlddim_y*0.5 || ofs_y < worlddim_y*-0.5
	|| ofs_z > worlddim_z*0.5 || ofs_z < worlddim_z*-0.5)
	{
		print("Warning: Looking for chunk id out of world bounds.\n");
		return -1;	
	}	
	
	ofs -= '1 1 1'*chunksize*cubicradius;
	ofs = ofs/(chunksize*cubicradius*2);
	ofs += ([worldsize, worldsize, worldheight])*clustersize*0.5;
	
	float f = ofs_x*pow(worldsize*clustersize, 2) + ofs_y*(worldsize*clustersize) + ofs_z;

	return f;
}

vector GetChunkOrigin(float refid)
{
	vector ofs = '0 0 0';
	ofs_x = floor(refid/pow(worldsize*clustersize, 2));
	ofs_y = floor((refid-(ofs_x*pow(worldsize*clustersize, 2)))/(worldsize*clustersize));
	ofs_z = refid - (ofs_x*(worldsize*clustersize)*(worldsize*clustersize)) - ofs_y*(worldsize*clustersize);
	ofs += (([worldsize*clustersize, worldsize*clustersize, worldheight*clustersize])*-0.5) + '1 1 1'*0.5;
	ofs = ofs*chunksize*cubicradius*2;

	return ofs;
}

int GetChunkRef(vector ofs, string funcname)
{
	if(ofs_x > clusterdim_x*0.5 || ofs_x < clusterdim_x*-0.5
	|| ofs_y > clusterdim_y*0.5 || ofs_y < clusterdim_y*-0.5
	|| ofs_z > clusterdim_z*0.5 || ofs_z < clusterdim_z*-0.5)
	{
		print("Warning: Looking for chunk id out of bounds from cluster. func: ", funcname, "\n");
		return -1;	
	}	
	
	ofs -= '1 1 1'*chunksize*cubicradius;
	ofs = ofs/(chunksize*cubicradius*2);
	ofs += '1 1 1'*clustersize*0.5;
	return ofs_x*clustersize*clustersize + ofs_y*clustersize + ofs_z;
}

vector GetChunkOffset(float refid)
{
	vector ofs = '0 0 0';
	ofs_x = floor(refid/(clustersize*clustersize));
	ofs_y = floor((refid-(ofs_x*clustersize*clustersize))/clustersize);
	ofs_z = refid - (ofs_x*clustersize*clustersize) - ofs_y*clustersize;
	ofs += '-1 -1 -1'*clustersize*0.5 + '1 1 1'*0.5;
	ofs = ofs*chunksize*cubicradius*2;

	return ofs;
}

int GetCubicRef(vector ofs)
{
	if(ofs_x > chunkdim_x*0.5 || ofs_x < chunkdim_x*-0.5
	|| ofs_y > chunkdim_y*0.5 || ofs_y < chunkdim_y*-0.5
	|| ofs_z > chunkdim_z*0.5 || ofs_z < chunkdim_z*-0.5)
	{
		print("Warning: Looking for cubic id out of bounds from chunk.\n");
		return -1;	
	}	
	
	ofs -= '1 1 1'*cubicradius;
	ofs = ofs/(cubicradius*2);
	ofs += '1 1 1'*chunksize*0.5;
	return ofs_x*chunksize*chunksize + ofs_y*chunksize + ofs_z;
}

vector GetCubicOffset(float refid)
{
	vector ofs = '0 0 0';
	ofs_x = floor(refid/(chunksize*chunksize));
	ofs_y = floor((refid-(ofs_x*chunksize*chunksize))/chunksize);
	ofs_z = refid - (ofs_x*chunksize*chunksize) - ofs_y*chunksize;
	ofs += '-1 -1 -1'*chunksize*0.5 + '1 1 1'*0.5;
	ofs = ofs*cubicradius*2;

	return ofs;
}

 // status of solid blocks
int	GetCubicStatus(entity chunk, vector cubicorg, int ignorenonsolids)
{
	if(!chunk)
		return -1;
	
	int memslot = GetCubicRef(cubicorg-chunk.origin);
	int type = chunk.cubic_blocktype[memslot];

	if(type > 0)
	if(!(ignorenonsolids && NonSolidType(type)))
		return memslot;

	return -1;
}

vector GetNearClusterOrg(vector org)
{
	vector clusterorg = '0 0 0';
	float clusterwidth = (clustersize*chunksize*cubicradius*2);
	clusterorg_x = rint(org_x/clusterwidth)*clusterwidth;
	clusterorg_y = rint(org_y/clusterwidth)*clusterwidth;
	clusterorg_z = rint(org_z/clusterwidth)*clusterwidth;
	return clusterorg;
}

vector GetNearChunkOrg(vector org)
{
	vector chunkorg = '0 0 0';
	float chunkwidth = (chunksize*cubicradius*2);
	chunkorg_x = rint(org_x/chunkwidth)*chunkwidth;
	chunkorg_y = rint(org_y/chunkwidth)*chunkwidth;
	chunkorg_z = rint(org_z/chunkwidth)*chunkwidth;	
	return chunkorg;
}


vector GetNearestCubicOrigin(vector org, int centeroffset)
{
	vector cubicorg = '0 0 0';
	
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

string GetToolName(int toolnum)
{
	string s = __NULL__;

	switch(toolnum)
	{
		case TOOL_EDITOR_MODIFY:		s = "Modify";		break;
		case TOOL_EDITOR_ADD:			s = "Add";			break;
		case TOOL_EDITOR_COPY:			s = "Copy/Save";	break;
		case TOOL_EDITOR_PASTE:			s = "Paste/Load";	break;
		case TOOL_EDITOR_INFOEDIT:		s = "Prefab Edit (chunk only)";	break;
	}

	return s;
}

string GetToolSizeName(int toolsize)
{
	string s = __NULL__;

	switch(toolsize)
	{
		case TOOLSIZE_EDITOR_CUBIC:		s = "Block";	break;
		case TOOLSIZE_EDITOR_CHUNK:		s = "Chunk";	break;
		case TOOLSIZE_EDITOR_CLUSTER:	s = "Cluster";	break;
	}

	return s;
}

float GetToolScale(int toolsize)
{
	float toolscale = 0;
	
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

	clusterorg = GetNearClusterOrg(clusterorg);	// incase clusterorg isn't exact

	if(clusterorg_x > worlddim_x*0.5 || clusterorg_x < worlddim_x*-0.5
	|| clusterorg_y > worlddim_y*0.5 || clusterorg_y < worlddim_y*-0.5
	|| clusterorg_z > worlddim_z*0.5 || clusterorg_z < worlddim_z*-0.5)
		return __NULL__;

	int clusterref = GetClusterRef(clusterorg);
	
	if(clusterref == -1)	// for functions that call without checking bounds
		return __NULL__;
		
	entity e = cluster_ent[clusterref];
	
	#ifdef DEBUG
	if(wasfreed(e))
			print("GetClusterForLocation A wasfreed.\n");
	#endif
	
	if(!e)
		return __NULL__;
	
	return e;
}
//#endif

//#ifdef SSQC
entity GetChunkForLocation(entity chunk, vector cubicchunkorg, string funcname) 
{
	if(!clusters_allocated)
		return __NULL__;
	
	if(cubicchunkorg_x > worlddim_x*0.5 || cubicchunkorg_x < worlddim_x*-0.5
	|| cubicchunkorg_y > worlddim_y*0.5 || cubicchunkorg_y < worlddim_y*-0.5
	|| cubicchunkorg_z > worlddim_z*0.5 || cubicchunkorg_z < worlddim_z*-0.5)
		return __NULL__;
	
	cubicchunkorg = GetNearChunkOrg(cubicchunkorg);	// this probably isn't necessary, test it
	
	int clusterref = GetClusterRef(GetNearClusterOrg(cubicchunkorg));
	
	if(clusterref == -1)	// for functions that call without checking bounds
		return __NULL__;
	
	entity cluster = cluster_ent[clusterref];
	
	#ifdef DEBUG
	if(wasfreed(cluster))
		print("GetChunkForLocation A wasfreed.\n");	
	#endif
	
	if(!cluster)
		return __NULL__;
	
	chunk = cluster.chunk_ent[GetChunkRef(cubicchunkorg-cluster.origin, strcat(funcname, " > ", __FUNC__))];
	
	#ifdef DEBUG
	if(wasfreed(chunk))
		print("GetChunkForLocation B wasfreed.\n");	
	#endif
	
	if(!chunk)
		return __NULL__;
	
	return chunk;
}
//#endif

/*#ifdef CSQC
entity GetChunkForLocation(entity chunk, vector cubicchunkorg) //hidefromfunctionlist
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
	int cullmatch = 0, cubicslot = 0;
	vector ofs = '0 0 0', nearcubicorg = '0 0 0', nearchunkorg = '0 0 0';
	entity nearchunk = __NULL__;
	
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
			nearchunk = GetChunkForLocation(__NULL__, nearchunkorg, __FUNC__);
		else
			nearchunk = chunk;
		
		if(!nearchunk)
			continue;
		
		cubicslot = GetCubicStatus(nearchunk, nearcubicorg, FALSE);
		
		if(cubicslot != -1)
			return TRUE;		
	}		
	
	return FALSE;
}

int CubicSharesCulledSide(entity chunk, vector cubicorg)
{
	int cullmatch = 0, cubicslot = 0, cullbits = 0;
	vector ofs = '0 0 0', nearcubicorg = '0 0 0', nearchunkorg = '0 0 0';
	entity nearchunk = __NULL__;
	
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
			nearchunk = GetChunkForLocation(__NULL__, nearchunkorg, __FUNC__);
		else
			nearchunk = chunk;
		
		if(!nearchunk)
			continue;
		
		cubicslot = GetCubicStatus(nearchunk, nearcubicorg, FALSE);
		
		if(cubicslot == -1)
			continue;
		
		cullbits = nearchunk.cubic_cullbits[cubicslot];
		
		if(cullbits & cullmatch)
			return TRUE;
	}
	
	return FALSE;
}

int CubicSharesEdges(vector cubicorg, vector start)	// FIXME: this isn't used anymore
{
	int foundsharededges = 0;
	vector ofs = '0 0 0', nearcubicorg = '0 0 0';
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
			if(GetCubicStatus(GetChunkForLocation(__NULL__, nearcubicorg, __FUNC__), nearcubicorg, FALSE) != -1)
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
	vector ofs = '0 0 0', nearcubicorg = '0 0 0', nearestcubicorg = '0 0 0', offsettostart = '0 0 0', shortestoffset = '0 0 0';
	
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
	entity chunk = __NULL__;
	vector chunkpos = '0 0 0', lastgridpos = '0 0 0';
	
	vector gridpos = GetNearestCubicOrigin(start, chunksize_iseven);
	vector tracedir = normalize(end-start);
	
	int stepX = GetPolarity(tracedir_x)*cubicradius*2;
	int stepY = GetPolarity(tracedir_y)*cubicradius*2;
	int stepZ = GetPolarity(tracedir_z)*cubicradius*2;
	
	float tDeltaX = (cubicradius*2)/PositiveValue(tracedir_x);
	float tDeltaY = (cubicradius*2)/PositiveValue(tracedir_y);
	float tDeltaZ = (cubicradius*2)/PositiveValue(tracedir_z);
	
	int posX = gridpos_x;
	int posY = gridpos_y;
	int posZ = gridpos_z;

	float tMaxX = (PositiveValue((posX + stepX*0.5) - start_x))/PositiveValue(tracedir_x);
	float tMaxY = (PositiveValue((posY + stepY*0.5) - start_y))/PositiveValue(tracedir_y);
	float tMaxZ = (PositiveValue((posZ + stepZ*0.5) - start_z))/PositiveValue(tracedir_z);
	
	float tEndX = PositiveValue(end_x-start_x)/PositiveValue(tracedir_x);
	float tEndY = PositiveValue(end_y-start_y)/PositiveValue(tracedir_y);
	float tEndZ = PositiveValue(end_z-start_z)/PositiveValue(tracedir_z);
	
	float raylendot = (end-start)*(end-start);
	
	while((gridpos-start)*(gridpos-start) < raylendot)
	{
		chunkpos = GetNearChunkOrg(gridpos);
		chunk = GetChunkForLocation(__NULL__, chunkpos, __FUNC__);
	
		if(GetCubicStatus(chunk, gridpos, FALSE) != -1)
		{
			if(getinside)
				return gridpos;
			else
				return lastgridpos;
		}
		
		lastgridpos = gridpos;
		
		if(tMaxX < tMaxY)
		{
			if(tMaxX < tMaxZ)
			{
				posX = posX + stepX;
				tMaxX = tMaxX + tDeltaX;
			}
			else
			{
				posZ = posZ + stepZ;
				tMaxZ = tMaxZ + tDeltaZ;
			}
		}
		else
		{
			if(tMaxY < tMaxZ) {
				posY = posY + stepY;
				tMaxY = tMaxY + tDeltaY;
			}
			else
			{
				posZ = posZ + stepZ;
				tMaxZ = tMaxZ + tDeltaZ;
			}
		}
		
		gridpos = [posX, posY, posZ];
	}
	
	return end;
}

vector TraceCubic2(vector start, vector end, int getinside)
{
	#ifdef SSQC
	int cullbits;
	#endif
	vector cubicorg = '0 0 0';
	vector lastcubicorg = GetNearestCubicOrigin(start, chunksize_iseven);
	entity chunk = __NULL__;
	vector offset = normalize(end-start)*cubicradius;

	for(vector pos = start; (start-pos)*(start-pos) < (start-end)*(start-end); pos = pos+offset)
	{
		cubicorg = GetNearestCubicOrigin(pos, chunksize_iseven);
	
		if(cubicorg != lastcubicorg)
		{
			chunk = GetChunkForLocation(__NULL__, pos, __FUNC__);			
			
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
				
				if(GetCubicStatus(chunk, cubicorg, FALSE) != -1)
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

							if(GetCubicStatus(GetChunkForLocation(__NULL__, cubicorg, __FUNC__), cubicorg, FALSE) == -1)	// check if nearest is located at an empty cubic 
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

int ToolIsOnEdge(vector clusterpos, vector toolpos, int toolsize, int toolid, vector toolmins, vector toolmaxs)
{
	if(toolpos_x + toolmins_x < worlddim_x*-0.5 || toolpos_x + toolmaxs_x > worlddim_x*0.5
	|| toolpos_y + toolmins_y < worlddim_y*-0.5 || toolpos_y + toolmaxs_y > worlddim_y*0.5
	|| toolpos_z + toolmins_z < worlddim_z*-0.5 || toolpos_z + toolmaxs_z > worlddim_z*0.5)
		return TRUE;
		
	if(toolid == TOOL_EDITOR_COPY)
		return FALSE;
	
	vector editsizeA = (('1 1 0'* (viewsize-1)*0.5 + '0 0 1'*(viewheight-1)*0.5) + '1 1 1'*0.5)*clustersize*chunksize*cubicradius*2;
	vector editsizeB = (('1 1 0'* (viewsize_distant-1)*0.5 + '0 0 1'*(viewheight_distant-1)*0.5) + '1 1 1'*0.5)*clustersize*chunksize*cubicradius*2;

	float toolscale = GetToolScale(toolsize);
	editsizeA -= '1 1 1'*toolscale*cubicradius;
	editsizeB -= '1 1 1'*toolscale*cubicradius;

	toolmins += '1 1 1'*cubicradius*2;
	toolmaxs -= '1 1 1'*cubicradius*2;

	if(toolpos_x+toolmins_x <= clusterpos_x - editsizeA_x || toolpos_x + toolmaxs_x >= clusterpos_x + editsizeA_x
	|| toolpos_y+toolmins_y <= clusterpos_y - editsizeA_y || toolpos_y + toolmaxs_y >= clusterpos_y + editsizeA_y
	|| toolpos_z+toolmins_z <= clusterpos_z - editsizeA_z || toolpos_z + toolmaxs_z >= clusterpos_z + editsizeA_z)
	if(toolpos_x+toolmins_x <= clusterpos_x - editsizeB_x || toolpos_x + toolmaxs_x >= clusterpos_x + editsizeB_x
	|| toolpos_y+toolmins_y <= clusterpos_y - editsizeB_y || toolpos_y + toolmaxs_y >= clusterpos_y + editsizeB_y
	|| toolpos_z+toolmins_z <= clusterpos_z - editsizeB_z || toolpos_z + toolmaxs_z >= clusterpos_z + editsizeB_z)		
		return TRUE;
		
	return FALSE;
}

void FreeChunkAllocations(entity chunk)
{
	#ifdef SSQC
	memfree(chunk.chunk_playerdelay);
	#endif
	
	memfree(chunk.cubic_blocktype);		
	memfree(chunk.cubic_blockshape);
	memfree(chunk.cubic_blockrotation);
	memfree(chunk.cubic_cullbits);
	memfree(chunk.cubic_health);		
}