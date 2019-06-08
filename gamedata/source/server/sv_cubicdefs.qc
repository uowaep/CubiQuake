.int		cs_worldsize;

.int		averagetype;
.int		occupantcount;
.int		worldloaded;
.int		loadingchunks;
.int		loadingbackgroundchunks;
.int		backgroundloadtime;
.int		backgroundunloadtime;
.int		visingchunks;
.vector		lastbackgroundqueuepos;
.vector		lastdistantbackgroundqueuepos;
int			numplayersloadingfiles;
.vector		playerclusterorg;
.int		playerclusterid;
.vector		client_initialized;

.*int	loadcluster_cluster_data;
.float	loadcluster_file;
.int	stagger_loadcluster_chunkid;
.entity	stagger_removeunoccupiedclusters_ghostchunk;

.int		tool;
.int		toolsize;
.int		editor_blocktype;
.int		editor_blockshape;
.int		editor_blockrotation;