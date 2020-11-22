void CleanUp_Remove (entity e)
{
	if(!e)
	{
		print("Warning: Trying to remove null entity.\n");
		return;
	}
	
	ProjectileChain_Remove(e);
	UnusedCubicBBoxChain_Remove(e);
	UnoccupiedClusterChain_Remove(e);
	
	if(e.enttype == ENT_CHUNK)
	{
		entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(e.origin));
		SaveChunkQueueChain_Remove(cluster, e);
		
		while(e.list_cubicobjchain)
			Remove(e.list_cubicobjchain);
	}
	
	if(e.parentchunk)
	{
		if(e.enttype == ENT_CUBICBBOX)
			CubicBBoxChain_Remove(e.parentchunk, e);
		
		if(e.enttype == ENT_CHUNKBLOAT)
			e.parentchunk.networkbloat[e.bloatlevel-1] = __NULL__;
	}
	
	if(e.networkbloat_allocated)
	{
		for(int count = 0; count < maxbloatents; count++)
		{
			if(!e.networkbloat[count])
				continue;
			
			Remove(e.networkbloat[count]);
			e.networkbloat[count] = __NULL__;		
			
		}
		
		memfree(e.networkbloat);
	}	
	
	if(e.enttype == ENT_CUBICOBJ)
	{
	//	entity chunk = GetChunkForLocation(__NULL__, e.origin, __FUNC__);
		if(e.parentchunk)
			CubicObjChain_Remove(e.parentchunk, e);
		else
			print("Missing parentchunk on removed cubic object. SSQC\n");
	}
	
	LeaveSolidCubics(e, e.lastsolidcubicorigin);
	e.physicssolidsset = FALSE;
	
	SetNumVisibleCubicsChain_Remove(e);
	NetworkBloatUpdateChain_Remove(e);
	
	BlockObjectRemoveChain_Remove(e);
	BlockObjectChain_Remove(e);	
	ObjChain_Remove(e);
}

void Remove(entity e)
{
	CleanUp_Remove(e);
	remove(e);
}

void SendAnimation(entity e)
{
	WriteByte(MSG_ENTITY, e.beginframe);
	WriteByte(MSG_ENTITY, e.finalframe);
	WriteByte(MSG_ENTITY, e.loopframes);
	WriteShort(MSG_ENTITY, e.anim_frameduration);	
}

void LockBlockObject(entity e);
void SaveModifiedClusterFiles(int saveall);
void SetLoadDistanceValues();
void SetAmbientLight();
void UninitializePlayers();
void SetSelectionEdge(vector polarity, vector offset);
void InitializeSelectionEdge();
void SetChunkSendFlags(entity chunk, float sendflags);

int ParseClientCommand_Wrap_Post(string s, int returnvalue)
{
	return returnvalue;	
}

void SV_ParseClientCommand (string s)
{
	string c, t;
	entity chunk;
	
	int sidenum;
	float file = 0;
	
	tokenize(s);
	c = argv(0);

// GAME COMMANDS

/*	if(c == "quit")	// make sure everything saves
	{
		clustersavetime = 0;
		SaveModifiedClusterFiles(TRUE);
	//	file = fopen("test.txt", FILE_WRITE);
	//	fputs(file, "saving?\n");
	//	fclose(file);
	}
	else*/
	if(c == "cq_initialized")
		self.client_initialized = TRUE;
	else
	if(c == "cq_resendchunk")
	{
		dprint("Resending chunk.\n");
		chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(stoi(argv(1))), __FUNC__);
		SetChunkSendFlags(chunk, SFL_BUILD);
	}
	else
	if(c == "cq_setselectionedge")
		SetSelectionEdge(stov(argv(1)), stov(argv(2)));
	else
	if(c == "cq_resetsetselectionedge")
		InitializeSelectionEdge();
	else		
	if(c == "cq_resetview") // FIXME: this breaks some things...
	{
		if(argv(1) == cvar_string("cq_adminpass"))
		{
			SetLoadDistanceValues();
			SetAmbientLight();
			UninitializePlayers();
			sprint(self, "Warning. This is buggy. You should probably restart the map if anything doesn't load correctly past this point.\n");
		}
		else
			sprint(self, "Wrong adminpass.\n");
	}
	else
	if(c == "cq_filename")
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
	if(c == "cq_setchunkzone")
	{
		if(self.editor_infoedit)
		{		
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.prefabzone = stoi(argv(1));
			self.prefabzone = chunk.prefabzone;
		}
	}
	else		
	if(c == "cq_setchunkchance")
	{
		if(self.editor_infoedit)
		{
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.prefabchance = stoi(argv(1));
			self.prefabchance = chunk.prefabchance;
		}
	}
	else		
	if(c == "cq_setchunkflags")
	{
		if(self.editor_infoedit)
		{
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.prefabchunkflags = stoi(argv(1));
			self.prefabchunkflags = chunk.prefabchunkflags;
		}
	}	
	else
	if(c == "cq_setchunkconnection")
	{
		if(self.editor_infoedit)
		{
			sidenum = stoi(argv(1));
			int connectiontype = stoi(argv(2));
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.infoedit_chunksidedata[sidenum] = connectiontype;
			self.infoedit_chunksidedata[sidenum] = connectiontype;
		}
	}
	else
	if(c == "cq_setchunkconnectionfit")
	{
		if(self.editor_infoedit)
		{
			sidenum = stoi(argv(1));
			int connectionfit = stoi(argv(2));
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidenum] = connectionfit;
			self.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+sidenum] = connectionfit;
			sprint(self, "Side ", itos(sidenum), " set to fit id: ", itos(connectionfit), "\n");
		}			
	}
	else
	if(c == "cq_setchunkconnectionflags")
	{
		if(self.editor_infoedit)
		{
			sidenum = stoi(argv(1));
			int connectionflags = stoi(argv(2));
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+sidenum] = connectionflags;
			self.infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+sidenum] = connectionflags;
		//	sprint(self, "Side ", itos(sidenum), " connection flags set to: ", itos(connectionflags), "\n");
		}			
	}
	else		
	if(c == "cq_setchunkgroupsize")
	{
		if(self.editor_infoedit)
		{
			sidenum = stoi(argv(1));
			int groupsize = stoi(argv(2));
			chunk = GetChunkForLocation(__NULL__, GetChunkOrigin(self.editor_editchunk), __FUNC__);
			chunk.infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+sidenum] = groupsize;
			self.infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+sidenum] = groupsize;
		//	sprint(self, "Side ", itos(sidenum), " set to group size: ", itos(groupsize), "\n");
		}			
	}	
	else
	if(!ParseClientCommand_Wrap_Post(s, FALSE))
		clientcommand(self, s);
}