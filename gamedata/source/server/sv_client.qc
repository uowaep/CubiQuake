.int		button0_down;

void ClientKill() {}
	
void ClientConnect(optional float csqcactive) {}
	
void ClientDisconnect()
{
	PlayerChain_Remove(self);
}

void Player_WorldInterface()
{
	if(world_initialized < 3)
		return;

	// CHECK WORLD BOUNDS
	if(self.origin_x >= worlddim_x*0.5 || self.origin_x <= worlddim_x*-0.5
	|| self.origin_y >= worlddim_y*0.5 || self.origin_y <= worlddim_y*-0.5
	|| self.origin_z >= worlddim_z*0.5 || self.origin_z <= worlddim_z*-0.5)
		return;		
	
	float loadwidth = clustersize*chunksize*cubicradius*1.2;
	float loadheight = clustersize*chunksize*cubicradius*1.2;
	
	if(self.origin_x > self.playerclusterorg_x + loadwidth || self.origin_x < self.playerclusterorg_x - loadwidth
	|| self.origin_y > self.playerclusterorg_y + loadwidth || self.origin_y < self.playerclusterorg_y - loadwidth
	|| self.origin_z > self.playerclusterorg_z + loadheight || self.origin_z < self.playerclusterorg_z - loadheight
	|| !self.worldloaded)
	{
		if(!(self.loadingchunks || self.loadingbackgroundchunks))
			numplayersloadingfiles++;
		
		self.loadingchunks = TRUE;
		self.loadingbackgroundchunks = TRUE;
		
		if(self.worldloaded)
			UnloadWorldForPlayer(self.playerclusterorg);
		
		vector newclusterorg = GetNearClusterOrg(self.origin);
		SetClusterOccupancyForPlayer(newclusterorg);
		self.playerclusterorg = newclusterorg;
		self.playerclusterid = GetClusterRef(self.playerclusterorg);
		
		RemoveUnoccupiedClusters();
	}
	
	if(self.loadingchunks)
	{
		self.loadingchunks = LoadWorldForPlayer(self.playerclusterorg, loadsize, loadsize, loadcenter, pow(loadsize, 3), FALSE, 0, 0, 0);
		self.worldloaded = TRUE;
	}
	else
	if(self.loadingbackgroundchunks == 1)
	{
		if(!LoadWorldForPlayer(self.playerclusterorg, viewsize, viewheight, viewcenter, 1, TRUE, loadsize, loadsize, 20))
			self.loadingbackgroundchunks = 2;
	}
	else
	if(self.loadingbackgroundchunks == 2)
	{
		if(!LoadWorldForPlayer(self.playerclusterorg, viewsize_distant, viewheight_distant, viewcenter_distant, 1, TRUE, viewsize, viewheight, 60))
		{
			self.loadingbackgroundchunks = FALSE;
			numplayersloadingfiles -= 1;
		}
	}

	if(self.physicssolidsset)
		LeaveSolidCubics(self.lastsolidcubicorigin);
	
	SetSolidCubics(self.origin);	// fixme adjust search size for lag spikes in both functions
	self.physicssolidsset = TRUE;
	self.lastsolidcubicorigin = self.origin;
	
	RemoveUnusedCubicBBoxes();
}

void PlayerPreThink()
{
	vector org = '0 0 0';
	vector targetpos = '0 0 0';
	
	Player_WorldInterface();

	if(self.impulse == TOOLSIZE_EDITOR_CUBIC)
		self.toolsize = TOOLSIZE_EDITOR_CUBIC;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CHUNK)
		self.toolsize = TOOLSIZE_EDITOR_CHUNK;
	else
	if(self.impulse == TOOLSIZE_EDITOR_CLUSTER)
		self.toolsize = TOOLSIZE_EDITOR_CLUSTER;
	else
	if(self.impulse == TOOL_EDITOR_REMOVE)
		self.tool = TOOL_EDITOR_REMOVE;
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
	if(self.impulse)
		self.tool = 0;
	
	if(self.button0)
	{
		if(self.button0_down < 2)
			self.button0_down++;
	}
	else
		self.button0_down = FALSE;

	if(self.tool >= TOOL_EDITOR_REMOVE && self.tool <= TOOL_EDITOR_PASTE)	
	if(self.button0_down == 1)
	if(!self.loadingchunks)
	if(!self.loadingbackgroundchunks)
	{
		int getinside = FALSE;
		
		if(self.tool == TOOL_EDITOR_REMOVE || self.tool == TOOL_EDITOR_COPY)
			getinside = TRUE;
		
		makevectors(self.v_angle);
		targetpos = self.origin+self.view_ofs+v_forward*cubicradius*2*20;
		vector tracepos = TraceCubic(self.origin+self.view_ofs, targetpos, getinside);

		switch(self.toolsize)
		{
			case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(tracepos, chunksize_iseven);	break;
			case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(tracepos);							break;
			case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(tracepos);							break;
		}

		if(!ToolIsOnEdge(self.playerclusterorg, org))
		if(self.tool == TOOL_EDITOR_ADD)
		{
			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		AddCubic(GetNearestCubicOrigin(tracepos, chunksize_iseven), BLOCKTYPE_BRICK);	break;
				case TOOLSIZE_EDITOR_CHUNK:		AddChunk(GetNearChunkOrg(tracepos), BLOCKTYPE_BRICK);							break;
				case TOOLSIZE_EDITOR_CLUSTER:	AddCluster(GetNearClusterOrg(tracepos), BLOCKTYPE_BRICK);						break;
			}
		}
		else
		if(self.tool == TOOL_EDITOR_REMOVE)
		{
			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		entity chunk = GetChunkForLocation(__NULL__, GetNearChunkOrg(tracepos));
												vector cubicorg = GetNearestCubicOrigin(tracepos, chunksize_iseven);
												RemoveCubic(chunk, cubicorg);												break;
				case TOOLSIZE_EDITOR_CHUNK:		RemoveChunk(GetNearChunkOrg(tracepos));											break;
				case TOOLSIZE_EDITOR_CLUSTER:	RemoveCluster(GetNearClusterOrg(tracepos));										break;
			}		
		}
		else
		if(self.tool == TOOL_EDITOR_COPY)
		{
			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:																						break;
				case TOOLSIZE_EDITOR_CHUNK:		SavePrefab_Chunk(GetNearChunkOrg(tracepos));									break;
				case TOOLSIZE_EDITOR_CLUSTER:	SavePrefab_Cluster(GetNearClusterOrg(tracepos));								break;
			}		
		}
		else
		if(self.tool == TOOL_EDITOR_PASTE)
		{
			switch(self.toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:																						break;
				case TOOLSIZE_EDITOR_CHUNK:		LoadPrefab_Chunk(GetNearChunkOrg(tracepos));									break;
				case TOOLSIZE_EDITOR_CLUSTER:	LoadPrefab_Cluster(GetNearClusterOrg(tracepos));								break;
			}		
		}
	}
	
	self.impulse = 0;
}
	
void PlayerPostThink()
{

}
	


void PutClientInServer()
{
	self.health = self.max_health = 100;
	self.solid = SOLID_SLIDEBOX;
	
	if(world_initialized == 3)
		self.movetype = MOVETYPE_WALK;
	
	self.flags = FL_CLIENT;
	self.view_ofs = '0 0 22';
	setmodel(self, "models/player/player.mdl");
	setsize(self, '-12 -12 -24', '12 12 26');
	setorigin(self, '0 0 128');
	self.angles = '0 0 0';
//	self.fixangle = TRUE;

	self.toolsize = TOOLSIZE_EDITOR_CUBIC;

	PlayerChain_Add(self);
}
