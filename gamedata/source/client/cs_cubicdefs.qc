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
.*vector	verts_ambientrgb;
.*vector	verts_staticrgb;
.int	numvertexes;
.int	numtrisets;
//.int	settingvertex;
//.int	settingnumtrisets;
//.int	settingindex;

.int	numchunks;
.string	texturename;
.int	faces;
.int	chunkinitialized;
.int	chunkid;
.entity	parentchunk;
.float	recentsendflags;
.int	numdamagedcubics;
.int	allocsize_verts;
.int	allocsize_indexes;
.int	markedforremoval;
.int	drawingdamage;
.entity	typegroupent;

int		DRAWLIST_CHUNK	= 0;
int		DRAWLIST_DMG	= 1;
int		DRAWLIST_EDIT	= 3;

int		buildfacesforframe;
int		facesbuiltforframe;

int		FACEBUILD_NEAR	= 1;
int		FACEBUILD_FAR	= 2;
int		FACEBUILD_DMG	= 4;


// cluster fields
.*int	chunk_flags;
int		CHFL_TRIGGERSTATICLIGHTS	= 1;

// faces
int FACE_TOP	= 1;

int FACE_WEST	= 2;
int FACE_SOUTH	= 4;
int FACE_EAST	= 8;
int FACE_NORTH	= 16;

int	FACE_SIDE	= 30; // FACE_SIDE is multiple bits containing the WEST, SOUTH, EAST. and NORTH bits. (2+4+8+16) These correspond with the CULLBITS_ bits.
int	FACE_BOTTOM	= 32;

int	FACE_ALL	= 64;	// doesn't work the same as FACE_SIDE. this is just a bit

.int	queuedforfacebuild;
float	autocvar_cq_bgload_dist;

int		autocvar_cq_framesperfacebuild;
int		autocvar_cq_maxfacegroupsperbuild;

int		autocvar_cq_maxcubicsperbuild;
int		numcubicsbuiltforframe;
int		buildchunkfaces_builtcount;
int		buildchunkfaces_cubiccount;

int		autocvar_cq_maxdamagecubicsperbuild;
int		numdamagecubicsbuiltforframe;
int		buildchunkdamagefaces_builtcount;
int		buildchunkdamagefaces_cubiccount;
//entity	buildaltface_chunk;

// chunk loading
.int	findnetworkbloatent;
.int	firstmemslot;
.float	lastupdatetime;

// lights
float	autocvar_cq_lights_static_updateinterval;
float	autocvar_cq_lights_dynamic_updateinterval;
float	autocvar_cq_clientlightradius;
float	autocvar_cq_lights_radiance;
vector	autocvar_cq_ambientlight;
float	autocvar_cq_ambientlight_radiance;
float	autocvar_cq_ambientlight_darknessratio;
int		autocvar_cq_lights_models;
int		cq_lights_models_old;

entity	clientlight;
int		clientlight_state;

int		ambientlightset;
vector	ambientlight_modified;
vector	ambientlight_position;
int		relightstatic;
int		relightdynamic;
float	static_relighttime;
float	dynamic_relighttime;
.int	islit;
.int	resetlights;
.int	staticlno;
.vector	staticrgb;
entity	vwepmodel;		// lights refers to this to know when to use the player's location for face origin reference

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


// interface
vector	mousepos;
int		mouseposinitialized;


// prediction / orientation
.float	movetime;
.vector	movementcorrection;
.vector	sharedorigin;
.int	obj_roll;


// objects

.int	ob_shape;
.int	ob_rotation;
.int	ob_health;

void ReadAnimation(entity e);