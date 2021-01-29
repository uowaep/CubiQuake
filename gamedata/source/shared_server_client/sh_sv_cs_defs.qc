// VERSION
int		cq_version		= 222;
string	cubic_revision	= "cubiquake r222";
int		oldfileversion	= 174;

// hack for traceline
entity	IGNORE_NOTHING;

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
int		r155_numprefabgenvaluesinchunk	= 27;
int		r174_numprefabgenvaluesinchunk	= 28;
int		r177_numprefabgenvaluesinchunk	= 28;
int		numprefabgenvaluesinchunk		= numsideinfoslots+4;

int		PREFABCHUNKSLOT_CHUNKSIDETYPE_0		= 0;	// 0-5
int		PREFABCHUNKSLOT_CONNECTIONFIT_0		= 6;	// 6-11
int		PREFABCHUNKSLOT_CONNECTIONFLAGS_0	= 12;	// 12-17
int		PREFABCHUNKSLOT_GROUPSIZE_0			= 18;	// 18-23

//		^ numsideinfoslots+4;
int		PREFABCHUNKSLOT_ZONE				= 24;
int		PREFABCHUNKSLOT_CHANCE				= 25;
int		PREFABCHUNKSLOT_VERSION				= 26;	// was chunkflags, but chunkflags could only have been 0 or 1 - r161
int		PREFABCHUNKSLOT_CHUNKFLAGS			= 27;

// prefab connection flags
int		CFL_ALLOWROTATEDFIT			= 1;

// prefab chunk flags
int		CHFL_ALLOWSAMEZONEPASSAGE	= 1;

int		r155_numvaluespercubic			= 4;
int		r174_numvaluespercubic			= 5;
int		r177_numvaluespercubic			= 6;
int		numvaluespercubic				= 6;

int		CUBICSLOT_TYPE					= 0;
int		CUBICSLOT_SHAPE					= 1;
int		CUBICSLOT_ROTATION				= 2;
int		CUBICSLOT_CULLBITS				= 3;
int		CUBICSLOT_HEALTH				= 4;	// not saved in prefabs
int		CUBICSLOT_FLAGS					= 5;

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
#ifndef CQ_ISMOD
int		numobjectblocktypes	= 1;
#endif

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

#ifdef SSQC
.int	blockflags;	// FIXME: change name of client field to use this
#endif
.*int	cubic_flags;
int		CUBICFLAG_ON	= 1;

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
int		EVENT_CUBICFLAGS	= 101;

.int	enttype;
int		ENT_CLUSTER									= 1;
int		ENT_CHUNK									= 2;
int		ENT_CHUNKBLOAT								= 3;
int		ENT_CUBICBBOX								= 4;
int		ENT_INFOEDIT_SELECTION						= 5;
int		ENT_INFOEDIT_SELECTION_GROUPSIZE_EXTEND 	= 6;
int		ENT_MODIFYSIDE_SELECTION					= 7;
int		ENT_OBJ										= 8;
int		ENT_CUBICOBJ								= 9;

int		STAT_OBJECT_PLACEMENTTYPE			= 32;

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
int		TOOLSIZE_EDITOR_CUBIC	= 100;	// impulses also
int		TOOLSIZE_EDITOR_CHUNK	= 101;
int		TOOLSIZE_EDITOR_CLUSTER	= 102;

int		TOOL_EDITOR_MODIFY		= 110;	// impulses also
int		TOOL_EDITOR_ADD			= 111;
int		TOOL_EDITOR_COPY		= 112;
int		TOOL_EDITOR_PASTE		= 113;
int		TOOL_EDITOR_INFOEDIT	= 114;

int		EDITOR_BLOCKTYPE_INCREASE			= 120;	// impulses also
int		EDITOR_BLOCKTYPE_DECREASE			= 121;
int		EDITOR_BLOCKSHAPE_INCREASE			= 122;
int		EDITOR_BLOCKSHAPE_DECREASE			= 123;
int		EDITOR_BLOCKROTATION_Y_INCREASE		= 124;
int		EDITOR_BLOCKROTATION_Y_DECREASE		= 125;
int		EDITOR_BLOCKROTATION_XZ_INCREASE	= 126;
int		EDITOR_BLOCKROTATION_XZ_DECREASE	= 127;

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

int		tooltracedist		= 15;	// this is distance in cubics halved, increases based on tool size also
int		playertracedist		= 96;	// distancein qu

.int	cubicmemslot;

.int		networkentnum;

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
//int		FACE_NOUPDATE		= 4;

.int	objtype;
int		OBJ_ITEM		= 1;
int		OBJ_GIB			= 2;
int		OBJ_ROCKET		= 3;
int		OBJ_BLOCK		= 4;

int		ITEM_TORCH			= 1;