// server orientation
vector	view_org;
vector	view_ang;

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

// cluster fields
.*int	chunk_flags;
int		CHFL_TRIGGERSTATICLIGHTS	= 1;

// faces
int FACE_TOP	= 1;
int	FACE_SIDE	= 30; // FACE_SIDE is multiple bits containing the WEST, SOUTH, EAST. and NORTH bits. (2+4+8+16) These correspond with the CULLBITS_ bits.
int	FACE_BOTTOM	= 32;

// chunk loading
vector	playerchunkorg;
vector	chunkloadofs;
int		setchunkloadofs;
int		client_hasmoved;

// lights
entity	clientlight;
int		clientlight_state;

int		ambientlightset;
int		relightstatic;
int		relightdynamic;
float	static_relighttime;
float	dynamic_relighttime;
.int	islit;