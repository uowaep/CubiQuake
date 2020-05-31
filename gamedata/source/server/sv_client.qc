void ClientKill() {}
void ClientConnect(optional float csqcactive) {}
	
void ClientDisconnect()
{
	// code here
	
	// end code
	
	if(self.loadingbackgroundchunks)
		numplayersloadingfiles-=1;
	
	if(self.worldloaded)
		UnloadWorldForPlayer(self, self.playerclusterorg, TRUE);
	
	PlayerChain_Remove(self);				// removes player from linked list
}

void PlayerPreThink()
{
	Player_CubiQuakeControls();
//	print(vtos(self.origin), "\n");
	// code here
	
	
//	sprint(self, vtos(GetNearChunkOrg(self.origin)), "\n");
	
	
	// end code
	
	self.impulse = 0;
}
	
void PlayerPostThink()	{}

void PutClientInServer()
{
	// code here
	
	self.health = self.max_health = 100;
	self.solid = SOLID_SLIDEBOX;	// FIXME: player should be nonsolid until free of collision objects
	self.flags = FL_CLIENT;
	self.view_ofs = '0 0 22';
	setmodel(self, "models/player/player.mdl");
	setsize(self, '-8 -8 -24', '8 8 26');
	setorigin(self, '0 0 0');

	//end code

	self.movetype = 0;							// don't let the player move until chunks are loaded
	self.waitingtospawn = TRUE;
	self.toolsize = TOOLSIZE_EDITOR_CUBIC;		// sets default tool size
	self.editor_blocktype = 1;					// sets default editor block type
	self.editor_blockshape = BLOCKSHAPE_CUBE;	// default editor block shape
	InitializeSelectionEdge();					// sets default editor selection size
	PlayerChain_Add(self);						// adds the player to a linked list
}
