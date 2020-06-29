void ClientKill() {}
void ClientConnect(optional float csqcactive) {}

void SetNewParms()		{}

int playersavingallclustersbeforemapchange;	// this variable name isn't ridiculous for no reason
void SetChangeParms()	// is this the only place to catch map change events?
{	
	if(!playersavingallclustersbeforemapchange)
	{
		playersavingallclustersbeforemapchange = TRUE;
		clustersavetime = 0;
		SaveModifiedClusterFiles(TRUE);
	}
}	

void ClientDisconnect()
{
	// code here
	
	// end code
	
	if(self.loadingbackgroundchunks)
		numplayersloadingfiles-=1;
	
	if(self.worldloaded)
		UnloadWorldForPlayer(self, self.playerclusterorg, TRUE);
	
	PlayerChain_Remove(self);				// removes player from linked list
	
	// save the world! (this can be removed, test it after it's all working first)
	if(!list_playerchain)
	{
		clustersavetime = 0;
		SaveModifiedClusterFiles(TRUE);
	}
}

/*void SV_RunClientCommand()
{
	print(vtos(input_movevalues), "\n");
	runstandardplayerphysics(self);
}*/

void PlayerPreThink()
{
	// Train rides!
	if(self.flags & FL_ONGROUND)
	if(self.groundentity)
	if(self.groundentity.velocity != '0 0 0')
	{

		// might want to try tracing at least 1 unit
		vector targetorg = self.origin+[self.groundentity.realvelocity_x, self.groundentity.realvelocity_y, 0]*frametime;
		self.velocity_z = max(self.velocity_z, self.groundentity.velocity_z);
		
		
		tracebox(self.origin, self.mins, self.maxs, targetorg, MOVE_NORMAL, self);
		if(trace_fraction == 1)
			setorigin(self, targetorg);
		else
		{
			vector ofs = targetorg-self.origin;
			makevectors(ofs);
			targetorg = self.origin + v_forward*vlen(ofs)*trace_fraction;
			setorigin(self, targetorg);
		}
	}
	
	Player_CubiQuakeControls();
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
