// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("worlds");	
	registercommand("resetview");
	registercommand("filename");
	
	SharedPrecaches();
	InitializeCubicInterface();	
	InitializeClientLight();
}

// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown()
{
}

// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
float CSQC_ConsoleCommand(string strMessage)
{
	float nReturn;
		nReturn = TRUE;
		
	// Tokenize String
	tokenize(strMessage);
	
	// Acquire Command
	string strCmd;
		strCmd = argv(0);
	
	switch(strCmd)
	{
		case "worlds":				nReturn = FALSE;	ListWorlds();					break;	// this would be better if it worked while not already in a world (menuqc)
		case "toggleclientlight":	nReturn = FALSE;	ClientToggleLight();			break;
		case "resetview":			nReturn = FALSE;	localcmd(strcat("cmd resetview ", cvar_string("adminpass"), "\n"));	break;
		case "filename":			nReturn = FALSE;	localcmd(strcat("cmd filename ", argv(1), "\n"));	break;
		default:					nReturn = FALSE;	break;
	}
	
	return nReturn;
}

// CSQC_InputEvent : Used to perform actions based on any key pressed or released by the client.
// Return value should be 1 if CSQC handled the key press, otherwise return 0 to have the key passed to the engine.
float CSQC_InputEvent(float evtype, float scanx, float chary, float devid)
{
	float bSkipKey = FALSE;
//	print(ftos(evtype), ", ", ftos(scanx), ", ", ftos(chary), ", ", ftos(devid), "\n");
	return bSkipKey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS

//void CSQC_Ent_Spawn(float entnum){}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void CSQC_Ent_Update(float bIsNewEntity)
{
	// NOTE: self may be world here if CSQC_Ent_Spawn is defined
	
	float i;//, spawned;
	
	
/*	if(self == world)
	if(i == ENT_CHUNK)
	{
		if(list_ghostchunkchain)
		{
			self = list_ghostchunkchain;
			GhostChunkChain_Remove(self);
		}
	}
	
	if(self == world)
	{
		self = spawn();
		spawned = TRUE;
	}*/
	
	i = readbyte();
	
	self.isshared = TRUE;

	switch(i)
	{
		case ENT_CHUNK:			UpdateChunk();		break;
	}
}

// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
	self.isshared = TRUE;
	Remove(self);
}

// CSQC_Parse_StuffCmd : Provides the stuffcmd string in the first parameter that the server provided.  To execute standard behavior, simply execute localcmd with the string.
void CSQC_Parse_StuffCmd(string strMessage)
{	
	int nReturn = TRUE;

	if(nReturn)
		localcmd(strMessage);
}

// CSQC_Parse_Print : Provides the print string in the first parameter that the server provided.  To execute standard behavior, simply execute print with the string.
void CSQC_Parse_Print(string printmsg, float printlvl)
{
	print(printmsg);
}

// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.  To execute standard behavior, simply execute cprint with the string.
float CSQC_Parse_CenterPrint(string strMessage)
{
	cprint(strMessage);
	
	return TRUE;
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float CSQC_Parse_TempEntity()
{
	local float bHandled;
		bHandled  = TRUE;
	// Acquire TE ID
	local float nTEID;
		nTEID = readbyte();
		
	switch(nTEID)
	{
		//case TE_GUNSHOT:
		//	Do something cool with TE_GUNSHOT!
		//	break;
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = FALSE;
			break;
	}
		
	return bHandled;
}