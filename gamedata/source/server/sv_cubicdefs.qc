//vector		debug_trace_start;
//vector		debug_trace_end;

//.float		button3;

//.int		cs_worldsize;

//.int		averagetype;
int			numnetworkents;
.*entity	cluster_playerlist;

.int		damaged;
.int		occupantcount;
.int		worldloaded;
.int		loadingchunks;
.int		loadingbackgroundchunks;
.int		backgroundloadtime;
int			backgroundunloadtime;
.int		visingchunks;
.vector		lastbackgroundqueuepos;
.vector		lastdistantbackgroundqueuepos;	// this is more for setting the vertical draw area than distant chunks (should rename it)
int			numplayersloadingfiles;
.vector		playerclusterorg;
.int		playerclusterid;
.vector		client_initialized;
.int		viewreset;
.int		waitingtospawn;

.*int		loadcluster_cluster_data;
.float		loadcluster_file;
.int		stagger_loadcluster_chunkid;
entity		stagger_removeunoccupiedclusters_ghostchunk;


.int		maxviewsize_prev;
.int		maxviewheight_prev;
.vector		maxviewcenter_prev;

.int		tool;
.int		toolsize;
.int		editor_blocktype;
.int		editor_blockshape;
.int		editor_blockrotation;
.int		editor_infoedit;
.int		editor_editchunk;
.int		editor_fillmode;
.vector		editor_selection_mins;
.vector		editor_selection_maxs;
.int		editor_sizetool;

.entity	used;
.entity	user;

vector		ambientlight;

int			maxplayers;

.int		button0_down;
.int		button1_down;

vector		lasteditorvaluesorg;

.float		removetime;

.*entity	networkbloat;
.int		networkbloat_allocated;
.int		bloatSendFlags;

int			autocvar_cq_maxchunksloadedperframe;
float		autocvar_cq_chunksave_interval;
int			autocvar_cq_chunksave_numperinterval;
float		chunkremovaldelay;

float		clustersavetime;


// generation
.int		infoedit_chunksidedata[numsideinfoslots];	// using an array instead of pointers so we can send this info to csqc as stats
.string		prefabfilename;
.*int		prefabdata;
.*int		prefabdata_temp;
.int		lookingforconnections;
.vector		genorg;
int			worldgen_fillpos;
int			worldgen_filled;
.int		genrotation;
.int		genzone;
int			genstep;
int			genpaused;
int			numrandomtextureblocktypes = 3;
int			numzones = 2;	// FIXME make this dynamic
entity		prefab_zonefill[numzones];
int			gen_type;
int			GEN_TYPE_FLAT			= 0;
int			GEN_TYPE_WASTELAND		= 1;
int			GEN_TYPE_PREFAB			= 2;

//string*		zonelist;
//int			numzones;
int			numchunkssincepassage;
int			truncatearea;
int			truncateareapos;
int			chunksperpassage;
int			gen_expandfit;
int			gen_searchingforspace;
int			lineargeneration;

//int GetZoneIDForName(string zonename);

.vector		lastsolidcubicorigin;
.int		collisioncount;
.int		physicssolidsset;
void LeaveSolidCubics(entity e, vector org);

.int		ignoreworldbounds;
.int		removepastworldbounds;

// prediction
.vector		realvelocity;

//movetype_bounceslide
float	autocvar_sv_maxvelocity;
float	autocvar_sv_gravity;

.int	slide;
.float	groundfriction;
//float	slidevel_max = 120;
int		MOVETYPE_BOUNCESLIDE	= 64;
.int	bsflags;

int		BSFLAG_NOBOUNCE			= 1;
int		BSFLAG_CLIMB			= 2;
int		BSFLAG_NOGRAVITY		= 4;

.vector	pushvelocity;
.float	bs_tracepadding;