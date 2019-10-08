void ClientKill() {}
void ClientConnect(optional float csqcactive) {}
	
void ClientDisconnect()
{
	// code here
	
	// end code
	
	PlayerChain_Remove(self);				// removes player from linked list
}

void PlayerPreThink()
{
	Player_WorldInterface();
	Player_CubiQuakeControls();
	
	// code here
	
	// end code
	
	self.impulse = 0;
}
	
void PlayerPostThink()	{}

void PutClientInServer()
{
	// code here
	
	self.health = self.max_health = 100;
	self.solid = SOLID_SLIDEBOX;
	self.flags = FL_CLIENT;
	self.view_ofs = '0 0 22';
	setmodel(self, "models/player/player.mdl");
	setsize(self, '-8 -8 -24', '8 8 26');
	setorigin(self, '0 0 128');

	//end code

	if(world_initialized == 3)					// allows new player to move/fall only if the world is done generating
		self.movetype = MOVETYPE_WALK;
	self.toolsize = TOOLSIZE_EDITOR_CUBIC;		// sets default tool size
	self.editor_blocktype = 1;					// sets default editor block type
	self.editor_blockshape = BLOCKSHAPE_CUBE;	// default editor block shape
	PlayerChain_Add(self);						// adds the player to a linked list
}
