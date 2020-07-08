// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	// FIXME need to find a way to set csqc cubic values here, intead of upon arrival of the first network entity.
	// do not reference anything in InitGameVariables here.
	
	registercommand("cq_worlds");	
	registercommand("cq_resetview");
	registercommand("cq_reinitializeclient");
	registercommand("cq_filename");
	registercommand("cq_zone");
	registercommand("cq_chance");
	registercommand("cq_fit");
	registercommand("cq_getchunkref");
	
	SharedPrecaches();
	InitializeClientSettings();
	InitializeCubicInterface();	
	InitializeClientLight();
	InitializeStrings();
	
	print("You have entered the world.\n");
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
		case "cq_worlds":				nReturn = TRUE;	ListWorlds();					break;	// this would be better if it worked while not already in a world (menuqc)
		case "cq_toggleclientlight":	nReturn = TRUE;	ClientToggleLight();			break;
		case "cq_resetview":			nReturn = TRUE;	localcmd(strcat("cmd cq_resetview ", cvar_string("cq_adminpass"), "\n"));	break;
		case "cq_reinitializeclient":	nReturn = TRUE;	InitializeClientSettings();	print("Client Settings reinitialized.\n");		break;
		case "cq_filename":				nReturn = TRUE;	localcmd(strcat("cmd cq_filename ", argv(1), "\n"));	break;
		case "cq_zone":					nReturn = TRUE;	if(argv(1)) editor_chunkzone = stoi(argv(1));	print("Zone is: ", itos(editor_chunkzone), "\n");	break;
		case "cq_chance":				nReturn = TRUE;	if(argv(1)) editor_chunkchance = stoi(argv(1));	print("Chance is: ", itos(editor_chunkchance), "\n");	break;		
		case "cq_fit":					nReturn = TRUE;	if(argv(1)) editor_connectionfit = stoi(argv(1));	print("Fit is: ", itos(editor_connectionfit), "\n");	break;
		case "cq_getchunkref":			nReturn = TRUE;	print(ftos(GetChunkOriginRef(GetNearChunkOrg(view_org))), "\n");	break;
		default:						nReturn = FALSE;	break;
	}
	
	return nReturn;
}

int SetInputID_Wrap_Prior(string bind, int inputid, float evtype, float scankey, int returnvalue)
{
	if(inputid >= 0)
	{
		if(evtype == 0)
		{
			if(player_input[inputid] == 0)
				player_input[inputid] = 1;
		}
		else
		if(evtype == 1)
			player_input[inputid] = FALSE;
	}
	
	return returnvalue;
}

// CSQC_InputEvent : Used to perform actions based on any key pressed or released by the client.
// Return value should be 1 if CSQC handled the key press, otherwise return 0 to have the key passed to the engine.
float CSQC_InputEvent(float evtype, float scanx, float chary, float devid)
{
	int inputid = -1;
	int bSkipKey = FALSE;
	
//	print(ftos(evtype), ", ", ftos(scanx), ", ", ftos(chary), ", ", ftos(devid), "\n");

	if(evtype == 0 || evtype == 1)
	{
		string bind = getkeybind(scanx);

		switch(bind)
		{
			case "+attack":			inputid = INPUT_ATTACK;		break;
			case "impulse 99":		inputid = INPUT_BUTTON1;	break;
			case "+speed":			inputid = INPUT_SPEED;		break;	// this isn't doing anything
	//		case "impulse 98":		inputid = INPUT_TOOLDIM;	break;
	
			case "impulse 22":		eprint(GetChunkForLocation(__NULL__, view_org, __FUNC__));	 break;
		}

		bSkipKey = SetInputID_Wrap_Prior(bind, inputid, evtype, scanx, FALSE);	
	}
	else
	if(evtype == 3)	// 2 is software mouse 3 is hardware
		mousepos = [scanx, chary, 0];
	
	return bSkipKey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS

//void CSQC_Ent_Spawn(float entnum){}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void Ent_Update_Wrap(float bIsNewEntity, int i) {}
void CSQC_Ent_Update(float bIsNewEntity)
{
	// NOTE: self may be world here if CSQC_Ent_Spawn is defined
	
	int i = readbyte();

	switch(i)
	{
		case ENT_CHUNK:			UpdateChunk();			break;
		case ENT_CHUNKBLOAT:	UpdateChunkBloat();		break;
		case ENT_OBJ:			UpdateObj(bIsNewEntity);		break;
	}
	
	Ent_Update_Wrap(bIsNewEntity, i);
}

// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
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
void Parse_Event_Wrap(int i) {}
void CSQC_Parse_Event()
{
	// Acquire TE ID
	local float nTEID;
		nTEID = readbyte();
		
	switch(nTEID)
	{
		// going to try to just update the shared ent's existing data w/o updating the shared ent. the actual chunk shared ents are big and clunky and span multiple ents. better not to update them unless updating geometry is required. still need to include health on initial chunk send though.
		
		case EVENT_CUBICHEALTH:		UpdateCubicHealth();		break;		
		case EVENT_CUBICFLAGS:		UpdateCubicFlags();			break;		
	}
	
	Parse_Event_Wrap(nTEID);
}