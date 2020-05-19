// view orientation
vector	view_size;
vector	view_org;
vector	view_ang;
vector	view_normal;
vector	view_right;
vector	view_point;

// client values
int		client_initialized;
	
// cubics/chunks
.*trisoup_simple_vert_t 	verts;
.*int 	vertex_indexes;
.*vector	verts_staticrgb;
.int	numvertexes;
.int	numtrisets;
.int	numchunks;
.string	texturename;
.int	blocktype;
.int	faces;
.int	chunkinitialized;
.int	chunkid;
.entity	parentchunk;
.float	recentsendflags;

// cluster fields
.*int	chunk_flags;
int		CHFL_TRIGGERSTATICLIGHTS	= 1;

// faces
int FACE_TOP	= 1;
int	FACE_SIDE	= 30; // FACE_SIDE is multiple bits containing the WEST, SOUTH, EAST. and NORTH bits. (2+4+8+16) These correspond with the CULLBITS_ bits.
int	FACE_BOTTOM	= 32;

.int	queuedforfacebuild;
float	autocvar_cq_bgload_dist;

int		autocvar_cq_maxcubicsperbuild;
int		autocvar_cq_maxfacegroupsperbuild;
int		autocvar_cq_framesperfacebuild;
int		numcubicsbuiltforframe;
int		buildchunkfaces_builtcount;
int		buildchunkfaces_cubiccount;
entity	buildchunkfaces_chunk;


// chunk loading
.int	findnetworkbloatent;
.int	firstmemslot;
.float	lastupdatetime;

// lights
float	autocvar_cq_lights_static_updateinterval;
float	autocvar_cq_lights_dynamic_updateinterval;
float	autocvar_cq_clientlightradius;

entity	clientlight;
int		clientlight_state;

int		ambientlightset;
int		relightstatic;
int		relightdynamic;
float	static_relighttime;
float	dynamic_relighttime;
.int	islit;
.int	resetlights;

// editor
entity	cubeselector;
//float	updatehudtooltime;

int		editor_infoedit;
int		editor_editchunk;
int		editor_editchunk_old;
int		editor_fillmode;
int		editor_tool;
int		editor_toolsize;
int		editor_cubictype;
int		editor_cubicshape;
int		editor_cubicrotation;
int		editor_sizetool;

int		playerclusterid_old;
int		editor_tool_old;
int		editor_toolsize_old;
int		editor_fillmode_old;
int		editor_cubictype_old;
int		editor_cubicshape_old;
int		editor_cubicrotation_old;
vector	editor_selectororg_old;
.vector	tooldimoffset;
vector	editor_selection_mins;
vector	editor_selection_maxs;

entity	infoedit_selection_side[6];
entity	infoedit_selection_chunk;
.int	chunksidenum;
int		editor_chunkzone;
int		editor_chunkchance;
int		editor_connectionfit;
.int	chunkconnectionfit;
.int	chunkgroupsize;
.int	chunkconnectionflags;
entity	modifyside_selection_side[7];
entity	modifyside_drag;
.vector	polarityvec;

int	numinfoeditbuttons = 5;
.*entity	infoedit_buttons;
.int	drawextendedbuttons;
.entity	parentbutton;

.int	buttontype;
int BTTN_INFOEDIT_CHUNKSIDETYPE			= 1;
int BTTN_INFOEDIT_FITNUM_INCREASE		= 2;
int BTTN_INFOEDIT_FITNUM_DECREASE		= 3;
int BTTN_INFOEDIT_GROUPSIZE_EXPAND		= 4;
int BTTN_INFOEDIT_GROUPSIZE_SHRINK		= 5;
int BTTN_INFOEDIT_ALLOWROTATEDFIT		= 6;
int BTTN_INFOEDIT_CHUNK					= 7;
int BTTN_INFOEDIT_CHUNKZONE_INCREASE	= 8;
int BTTN_INFOEDIT_CHUNKZONE_DECREASE	= 9;
int BTTN_INFOEDIT_CHUNKCHANCE_INCREASE	= 10;
int BTTN_INFOEDIT_CHUNKCHANCE_DECREASE	= 11;
int	BTTN_INFOEDIT_ALLOWSAMEZONEPASSAGE	= 12;
int	BTTN_MODIFYSIDE_SIZE				= 13;