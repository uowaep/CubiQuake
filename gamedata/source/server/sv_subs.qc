void Remove(entity e)
{
	ProjectileChain_Remove(e);
	UnusedCubicBBoxChain_Remove(e);
	UnoccupiedClusterChain_Remove(e);
	
	while(e.list_cubicbboxchain)
		Remove(e.list_cubicbboxchain);
	
	if(e.parentchunk)
		CubicBBoxChain_Remove(e.parentchunk, e);
		
	remove(e);
}

void SetLoadDistanceValues();
void SetAmbientLight();
void UninitializePlayers();

void SV_ParseClientCommand (string s) =
{
	local string c, t;
	
	tokenize(s);
	c = argv(0);

// GAME COMMANDS

	if(c == "initialized")
		self.client_initialized = TRUE;
	else
	if(c == "resetview")
	{
		if(argv(1) == cvar_string("adminpass"))
		{
			SetLoadDistanceValues();
			SetAmbientLight();
			UninitializePlayers();
		}
		else
			sprint(self, "Wrong adminpass.\n");
	}
	else
	if(c == "filename")
	{
		t = argv(1);
		
		if(t)
		{
			self.prefabfilename = t;
			sprint(self, "Filename set to: \"", self.prefabfilename, "\"\n");
		}
		else
			sprint(self, "Filename is currently set to: \"", self.prefabfilename, "\"\n");
	}
	else
		clientcommand(self, s);
}