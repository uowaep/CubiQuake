string GetNameForConnectionType(int type)
{
	string s = __NULL__;
	
	switch(type)
	{
		case CHUNKCONNECTION_CLOSED:		s = "CLOSED";		break;
		case CHUNKCONNECTION_OPENED:		s = "OPENED";		break;
		case CHUNKCONNECTION_PASSAGE:		s = "PASSAGE";		break;
		case CHUNKCONNECTION_ANY:			s = "ANY";			break;
		case CHUNKCONNECTION_RANDOM:		s = "RANDOM";		break;
		case CHUNKCONNECTION_REQUIREONE:	s = "REQUIRE ONE";	break;
	}
	
	return s;
}

float Predraw_InfoEditChunkSide()
{
	switch(self.chunkconnectiontype)
	{
		case CHUNKCONNECTION_CLOSED:		self.colormod = '1 0 0';		break;
		case CHUNKCONNECTION_OPENED:		self.colormod = '0 1 0';		break;
		case CHUNKCONNECTION_PASSAGE:		self.colormod = '1 1 0';		break;
		case CHUNKCONNECTION_ANY:			self.colormod = '1 0.5 0.5';	break;
		case CHUNKCONNECTION_RANDOM:		self.colormod = '0 0 1';		break;
		case CHUNKCONNECTION_REQUIREONE:	self.colormod = '0 1 1';		break;
	}
	
	self.colormod = self.colormod*0.8;
	
	if(self.drawextendedbuttons)
	{
		self.infoedit_buttons[4].drawmask = MASK_NORMAL;
		self.infoedit_buttons[4].solid = SOLID_BBOX;
		
		setorigin(self.infoedit_buttons[4], self.origin + view_normal*cubicradius*-3 + view_right*0);
	}
	else
	{
		self.infoedit_buttons[4].drawmask = 0;
		self.infoedit_buttons[4].solid = 0;
	}
	
	return FALSE;
}

float Predraw_InfoEditChunk()
{
	if(self.drawextendedbuttons)
	{
		self.infoedit_buttons[4].drawmask = MASK_NORMAL;
		self.infoedit_buttons[4].solid = SOLID_BBOX;
		
		setorigin(self.infoedit_buttons[4], self.origin + view_normal*cubicradius*-3 + view_right*0);
	}
	else
	{
		self.infoedit_buttons[4].drawmask = 0;
		self.infoedit_buttons[4].solid = 0;
	}
	
	return FALSE;
}

entity EditorButton(entity e, vector org, int bttntype, float bttnscale, vector bttncolor, int sidenum)
{
	if(!e)
		e = spawn();
	
	e.buttontype = bttntype;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = bttnscale;
	setsize(e, '-1 -1 -1'*cubicradius*bttnscale, '1 1 1'*cubicradius*bttnscale);
	setorigin(e, org);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
	e.colormod = bttncolor;
	e.chunksidenum = sidenum;

	return e;
}

entity InfoEditButton(entity e, vector org, int bttntype, float bttnscale, vector bttncolor, int sidenum)
{
	e = EditorButton(e, org, bttntype, bttnscale, bttncolor, sidenum);
	e.enttype = ENT_INFOEDIT_SELECTION;
	InfoEditChunkSideChain_Add(e);
	
	return e;
}

entity ModifySideButton(entity e, vector org, int bttntype, float bttnscale, vector bttncolor, int sidenum)
{
	e = EditorButton(e, org, bttntype, bttnscale, bttncolor, sidenum);
	e.enttype = ENT_MODIFYSIDE_SELECTION;
	
	return e;
}

void UpdateModifySideButtonOrgs()
{
	entity e = __NULL__;
	
	if(!modifyside_selection_side[0])
		return;
	if(!cubeselector)
		return;
	
	for(int count = 0; count < 7; count++)
	{
		e = modifyside_selection_side[count];
		setorigin(e, cubeselector.origin + e.tooldimoffset);
	}
}

void SpawnModifySide(vector org, int sidenum, vector ofs)
{
	entity e = modifyside_selection_side[sidenum];
	
	if(!e)
	{
		e = spawn();
		modifyside_selection_side[sidenum] = e;
		e.alpha = 0.6;
	}
	
	e.polarityvec = ofs;
	e.tooldimoffset = ofs*2*cubicradius;
	
	ModifySideButton(e, org + e.tooldimoffset, BTTN_MODIFYSIDE_SIZE, 0.5, '0 0 0', sidenum);
}

void InitializeModifySides(vector org)
{
	SpawnModifySide(org, 0, VECOFS_U);
	SpawnModifySide(org, 1, VECOFS_W);
	SpawnModifySide(org, 2, VECOFS_S);
	SpawnModifySide(org, 3, VECOFS_E);
	SpawnModifySide(org, 4, VECOFS_N);
	SpawnModifySide(org, 5, VECOFS_D);
	SpawnModifySide(org, 6, '0 0 0');
	modifyside_selection_side[6].colormod = '1 0 0';
	
	editor_selection_mins_x = modifyside_selection_side[1].tooldimoffset_x;
	editor_selection_mins_y = modifyside_selection_side[2].tooldimoffset_y;
	editor_selection_mins_z = modifyside_selection_side[5].tooldimoffset_z;
	editor_selection_maxs_x = modifyside_selection_side[3].tooldimoffset_x;
	editor_selection_maxs_y = modifyside_selection_side[4].tooldimoffset_y;
	editor_selection_maxs_z = modifyside_selection_side[0].tooldimoffset_z;	
}

/*void RemoveModifySides()
{
	entity e;
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		e = modifyside_selection_side[sidecount];
		Remove(e);
		modifyside_selection_side[sidecount] = __NULL__;
	}
}*/

void BuildFacesForPlacementTool()
{
	vector sel_mins = '0 0 0', sel_maxs = '0 0 0', pos = '0 0 0';
	int numcubicsinselection = 0;
	
	sel_maxs_z = editor_selection_maxs_z/(cubicradius*2);
	sel_mins_x = (editor_selection_mins_x+cubicradius*2)/(cubicradius*2);
	sel_mins_y = (editor_selection_mins_y+cubicradius*2)/(cubicradius*2);
	sel_maxs_x = editor_selection_maxs_x/(cubicradius*2);
	sel_maxs_y = editor_selection_maxs_y/(cubicradius*2);
	sel_mins_z = (editor_selection_mins_z+cubicradius*2)/(cubicradius*2);
	
	for(pos_x = sel_mins_x; pos_x < sel_maxs_x; pos_x++)
		for(pos_y = sel_mins_y; pos_y < sel_maxs_y; pos_y++)
			for(pos_z = sel_mins_z; pos_z < sel_maxs_z; pos_z++)
			{
				if(pos_x == sel_mins_x || pos_x == sel_maxs_x-1
				|| pos_y == sel_mins_y || pos_y == sel_maxs_y-1
				|| pos_z == sel_mins_z || pos_z == sel_maxs_z-1)
					numcubicsinselection++;
			}

	for(pos_x = sel_mins_x; pos_x < sel_maxs_x; pos_x++)
		for(pos_y = sel_mins_y; pos_y < sel_maxs_y; pos_y++)
			for(pos_z = sel_mins_z; pos_z < sel_maxs_z; pos_z++)
			{
				if(pos_x == sel_mins_x || pos_x == sel_maxs_x-1
				|| pos_y == sel_mins_y || pos_y == sel_maxs_y-1
				|| pos_z == sel_mins_z || pos_z == sel_maxs_z-1)
					BuildFacesForShape(cubeselector, editor_cubicshape, editor_cubicrotation, 0, cubeselector.origin+pos*cubicradius*2, numcubicsinselection, 1); // FIXME set cullbits to hide internal faces
			}									
}

void RebuildSelectionFaces()
{
	entity nexte = __NULL__;
	for(entity facegroup = cubeselector.list_facegroupchain; facegroup; facegroup = nexte)
	{
		nexte = facegroup.facegroupchain;
		RemoveFaceGroup(cubeselector, facegroup);
	}
	
	if(editor_tool == TOOL_EDITOR_MODIFY)
		BuildFaces_Custom(cubeselector, cubeselector.origin, TRUE, 1);
	else
		BuildFacesForPlacementTool();	
}


void Editor_ModifySide()
{
	int count = 0;

	if(editor_infoedit || editor_toolsize > TOOLSIZE_EDITOR_CUBIC)
		return;
	
	int maxselectionsize = 2197; // 13*13*13
	
	if(!editor_sizetool //player_input[INPUT_TOOLDIM] == 0 
	|| player_input[INPUT_ATTACK] == 0)
	{
		if(modifyside_drag)
			localcmd("cmd cq_setselectionedge ", vtos(modifyside_drag.polarityvec), " ", vtos(modifyside_drag.origin-modifyside_selection_side[6].origin), "\n");
		
		modifyside_drag = __NULL__;
	}

	if(!modifyside_selection_side[0])
		InitializeModifySides(cubeselector.origin);	

	// handle hude/draw
//	if(player_input[INPUT_TOOLDIM] < 1 || !editor_tool)
	if(!editor_sizetool || !editor_tool)		
	{
		for(count = 0; count < 7; count++)
		{
			modifyside_selection_side[count].solid = SOLID_NOT;
			modifyside_selection_side[count].drawmask = FALSE;
		}
		cubeselector.drawmask = FALSE;
	}
	else
	{
		for(count = 0; count < 7; count++)
		{
			modifyside_selection_side[count].solid = SOLID_BBOX;
			modifyside_selection_side[count].drawmask = MASK_NORMAL;
		}
	}

//	if(player_input[INPUT_TOOLDIM] > 0)
	if(editor_sizetool)		
	if(player_input[INPUT_ATTACK] == 1)
	{
		makevectors(view_ang);

		self.dimension_hit = 255&~1;
		traceline(view_org, view_org + v_forward*cubicradius*2*chunksize*clustersize*max(maxviewsize, maxviewheight), MOVE_NORMAL, self);
		self.dimension_hit = 255;
		
		if(trace_ent)
		{
			if(trace_ent.enttype == ENT_MODIFYSIDE_SELECTION)
			{
				if(trace_ent.polarityvec == '0 0 0')	// reset size
				{
					InitializeModifySides(cubeselector.origin);
					RebuildSelectionFaces();
					localcmd("cmd cq_resetsetselectionedge\n");
					return;
				}
				else									// grab side
					modifyside_drag = trace_ent;
			}
		}
	}
	else
	if(player_input[INPUT_ATTACK] == 2)	
	if(modifyside_drag)	// modifying size
	{
		vector sel_size;
		float dist = vlen(modifyside_drag.origin-view_org);
		makevectors(view_ang);
		vector org = view_org + v_forward*dist;
		org = GetNearestCubicOrigin(org, chunksize_iseven);
		
		sel_size_x = (editor_selection_maxs_x - editor_selection_mins_x)/(cubicradius*2) - 1;
		sel_size_y = (editor_selection_maxs_y - editor_selection_mins_y)/(cubicradius*2) - 1;
		sel_size_z = (editor_selection_maxs_z - editor_selection_mins_z)/(cubicradius*2) - 1;
		
	//	print(vtos(sel_size), " A\n");
		
		vector dragorg = modifyside_drag.origin;
		if(modifyside_drag.polarityvec_x > 0)
		{
			sel_size_x = (org_x - modifyside_selection_side[1].origin_x)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;
			
			dragorg_x = max(cubeselector.origin_x+cubicradius*2, org_x);//bound(cubeselector.origin_x+cubicradius*2, org_x, cubeselector.origin_x+cubicradius*2*maxselectionsize);
			editor_selection_maxs_x = dragorg_x - cubeselector.origin_x;
		}
		else
		if(modifyside_drag.polarityvec_x < 0)
		{
			sel_size_x = (modifyside_selection_side[3].origin_x - org_x)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;
			
			dragorg_x = min(cubeselector.origin_x-cubicradius*2, org_x);//bound(cubeselector.origin_x-cubicradius*2*maxselectionsize, org_x, cubeselector.origin_x-cubicradius*2);
			editor_selection_mins_x = dragorg_x - cubeselector.origin_x;
		}
		else			
		if(modifyside_drag.polarityvec_y > 0)
		{
			sel_size_y = (org_y - modifyside_selection_side[2].origin_y)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;			
			
			dragorg_y = max(cubeselector.origin_y+cubicradius*2, org_y);//bound(cubeselector.origin_y+cubicradius*2, org_y, cubeselector.origin_y+cubicradius*2*maxselectionsize);
			editor_selection_maxs_y = dragorg_y - cubeselector.origin_y;
		}
		else
		if(modifyside_drag.polarityvec_y < 0)
		{
			sel_size_y = (modifyside_selection_side[4].origin_y - org_y)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;			
			
			dragorg_y = min(cubeselector.origin_y-cubicradius*2, org_y);//bound(cubeselector.origin_y-cubicradius*2*maxselectionsize, org_y, cubeselector.origin_y+cubicradius*2);
			editor_selection_mins_y = dragorg_y - cubeselector.origin_y;
		}
		else
		if(modifyside_drag.polarityvec_z > 0)
		{
			sel_size_z = (org_z - modifyside_selection_side[5].origin_z)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;				
			
			dragorg_z = max(cubeselector.origin_z+cubicradius*2, org_z);//bound(cubeselector.origin_z+cubicradius*2, org_z, cubeselector.origin_z+cubicradius*2*maxselectionsize);
			editor_selection_maxs_z = dragorg_z - cubeselector.origin_z;
		}
		else
		if(modifyside_drag.polarityvec_z < 0)
		{
			sel_size_z = (modifyside_selection_side[0].origin_z - org_z)/(cubicradius*2) - 1;
			if(sel_size_x * sel_size_y * sel_size_z > maxselectionsize)
				return;				
			
			dragorg_z = min(cubeselector.origin_z-cubicradius*2, org_z);//bound(cubeselector.origin_z-cubicradius*2*maxselectionsize, org_z, cubeselector.origin_z-cubicradius*2);
			editor_selection_mins_z = dragorg_z - cubeselector.origin_z;
		}
		
		if(dragorg != modifyside_drag.origin)
		{
			hudstring_editor_totalcubics = strcat("Cubics: ", itos(sel_size_x * sel_size_y * sel_size_z), "/", itos(maxselectionsize));
			setorigin(modifyside_drag, dragorg);
			modifyside_drag.tooldimoffset = dragorg - cubeselector.origin;
			RebuildSelectionFaces();
		}
	}
}

void SpawnInfoEditChunkSide(vector org, int sidenum, vector ofs)
{
	entity e = spawn();
	e.infoedit_buttons = memalloc(sizeof(entity)*numinfoeditbuttons);
	e.predraw = Predraw_InfoEditChunkSide;
	InfoEditButton(e, org + ofs*(chunksize+1.5)*cubicradius, BTTN_INFOEDIT_CHUNKSIDETYPE, 1, '0 0 0', sidenum);
	infoedit_selection_side[sidenum] = e;
	
	entity mainsidebutton = e;
	
	vector buttoncolor = '1 0.6 0';
	
	e = InfoEditButton(__NULL__, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, cubicradius*3], BTTN_INFOEDIT_FITNUM_INCREASE, 0.3, buttoncolor, sidenum);
	infoedit_selection_side[sidenum].infoedit_buttons[0] = e;
	
	e =	InfoEditButton(__NULL__, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, cubicradius*2], BTTN_INFOEDIT_FITNUM_DECREASE, 0.3, buttoncolor, sidenum);
	infoedit_selection_side[sidenum].infoedit_buttons[1] = e;	

	buttoncolor = '0.5 0.5 0.5';
	
	e = InfoEditButton(__NULL__, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, -cubicradius*2], BTTN_INFOEDIT_GROUPSIZE_EXPAND, 0.3, buttoncolor, sidenum);
	infoedit_selection_side[sidenum].infoedit_buttons[2] = e;
	
	e =	InfoEditButton(__NULL__, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, -cubicradius*3], BTTN_INFOEDIT_GROUPSIZE_SHRINK, 0.3, buttoncolor, sidenum);
	infoedit_selection_side[sidenum].infoedit_buttons[3] = e;

	buttoncolor = '0.5 0.5 0.5';
	
	e =	InfoEditButton(__NULL__, org + ofs*(chunksize+1.5)*cubicradius, BTTN_INFOEDIT_ALLOWROTATEDFIT, 0.2, buttoncolor, sidenum);
	infoedit_selection_side[sidenum].infoedit_buttons[4] = e;
	e.parentbutton = mainsidebutton;
	
/*	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_CHUNKSIDETYPE;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
	setorigin(e, org + ofs*(chunksize+1.5)*cubicradius);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;
	e.predraw = Predraw_InfoEditChunkSide;
	infoedit_selection_side[sidenum] = e;
	e.chunksidenum = sidenum;
	InfoEditChunkSideChain_Add(e);
	
	vector buttoncolor = '1 0.6 0';
	
	e = spawn();
	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_FITNUM_INCREASE;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = 0.3;
	setsize(e, '-1 -1 -1'*cubicradius*0.5, '1 1 1'*cubicradius*0.5);
	setorigin(e, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, cubicradius*3]);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
	e.colormod = buttoncolor;
	infoedit_selection_side[sidenum].infoedit_buttons[0] = e;
	e.chunksidenum = sidenum;
	InfoEditChunkSideChain_Add(e);	
	
	e = spawn();
	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_FITNUM_DECREASE;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = 0.3;
	setsize(e, '-1 -1 -1'*cubicradius*0.5, '1 1 1'*cubicradius*0.5);
	setorigin(e, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, cubicradius*2]);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
	e.colormod = buttoncolor;
	infoedit_selection_side[sidenum].infoedit_buttons[1] = e;
	e.chunksidenum = sidenum;
	InfoEditChunkSideChain_Add(e);	

	buttoncolor = '0.5 0.5 0.5';

	e = spawn();
	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_GROUPSIZE_EXPAND;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = 0.3;
	setsize(e, '-1 -1 -1'*cubicradius*0.5, '1 1 1'*cubicradius*0.5);
	setorigin(e, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, -cubicradius*2]);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
	e.colormod = buttoncolor;
	infoedit_selection_side[sidenum].infoedit_buttons[2] = e;
	e.chunksidenum = sidenum;
	InfoEditChunkSideChain_Add(e);	
	
	e = spawn();
	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_GROUPSIZE_SHRINK;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = 0.3;
	setsize(e, '-1 -1 -1'*cubicradius*0.5, '1 1 1'*cubicradius*0.5);
	setorigin(e, org + ofs*(chunksize+1.5)*cubicradius + [0, 0, -cubicradius*3]);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
	e.colormod = buttoncolor;
	infoedit_selection_side[sidenum].infoedit_buttons[3] = e;
	e.chunksidenum = sidenum;
	InfoEditChunkSideChain_Add(e);	*/
	
}

void SpawnInfoEditChunk(vector org)
{
//	entity e = spawn();
//	infoedit_selection_chunk = e;
	
//	e.infoedit_buttons = memalloc(sizeof(entity)*numinfoeditbuttons);
//	e.predraw = Predraw_InfoEditChunkSide;

/*	e.enttype = ENT_INFOEDIT_SELECTION;
	e.buttontype = BTTN_INFOEDIT_CHUNK;	
	setmodel(e, "models/editor/cubeselector.mdl");
	e.solid = SOLID_BBOX;
	e.scale = 1;
	setsize(e, '-1 -1 -1'*cubicradius*e.scale, '1 1 1'*cubicradius*e.scale);
	setorigin(e, org);
	e.drawmask = MASK_NORMAL;
	e.renderflags = RF_DEPTHHACK;	
//	e.colormod = bttncolor;
	InfoEditChunkSideChain_Add(e);*/
	
	entity e = spawn();
	e.infoedit_buttons = memalloc(sizeof(entity)*numinfoeditbuttons);
	e.predraw = Predraw_InfoEditChunk;
	InfoEditButton(e, org+'0 0 0', BTTN_INFOEDIT_CHUNK, 1, '0 0 0', 0);
	infoedit_selection_chunk = e;	
	
	entity mainsidebutton = e;
	
	vector buttoncolor = '1 0.6 0';
	
	e = InfoEditButton(__NULL__, org + [0, 0, cubicradius*3], BTTN_INFOEDIT_CHUNKZONE_INCREASE, 0.3, buttoncolor, 0);
	mainsidebutton.infoedit_buttons[0] = e;
	
	e =	InfoEditButton(__NULL__, org + [0, 0, cubicradius*2], BTTN_INFOEDIT_CHUNKZONE_DECREASE, 0.3, buttoncolor, 0);
	mainsidebutton.infoedit_buttons[1] = e;

	buttoncolor = '0.5 0.5 0.5';
	
	e = InfoEditButton(__NULL__, org + [0, 0, -cubicradius*2], BTTN_INFOEDIT_CHUNKCHANCE_INCREASE, 0.3, buttoncolor, 0);
	mainsidebutton.infoedit_buttons[2] = e;
	
	e =	InfoEditButton(__NULL__, org + [0, 0, -cubicradius*3], BTTN_INFOEDIT_CHUNKCHANCE_DECREASE, 0.3, buttoncolor, 0);
	mainsidebutton.infoedit_buttons[3] = e;
	
	buttoncolor = '0.5 0.5 0.5';
	
	e =	InfoEditButton(__NULL__, org, BTTN_INFOEDIT_ALLOWSAMEZONEPASSAGE, 0.2, buttoncolor, 0);
	mainsidebutton.infoedit_buttons[4] = e;
	e.parentbutton = mainsidebutton;
}

void SpawnInfoEditChunkSides()
{
	vector org = GetChunkOrigin(editor_editchunk);
	
	SpawnInfoEditChunk(org);
	
	SpawnInfoEditChunkSide(org, 0, VECOFS_U);
	SpawnInfoEditChunkSide(org, 1, VECOFS_W);
	SpawnInfoEditChunkSide(org, 2, VECOFS_S);
	SpawnInfoEditChunkSide(org, 3, VECOFS_E);
	SpawnInfoEditChunkSide(org, 4, VECOFS_N);
	SpawnInfoEditChunkSide(org, 5, VECOFS_D);
}

void RemoveInfoEditChunkSides()
{
	entity e = __NULL__;
	int count = 0;
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		e = infoedit_selection_side[sidecount];
		InfoEditChunkSideChain_Remove(e);
		
		for(count = 0; count < numinfoeditbuttons; count++)
		{
			if(!e.infoedit_buttons[count])
				break;
			InfoEditChunkSideChain_Remove(e.infoedit_buttons[count]);
			Remove(e.infoedit_buttons[count]);
		}
		
		memfree(e.infoedit_buttons);
		Remove(e);
		infoedit_selection_side[sidecount] = __NULL__;
	}

	InfoEditChunkSideChain_Remove(infoedit_selection_chunk);
	for(count = 0; count < numinfoeditbuttons; count++)
	{
		if(!infoedit_selection_chunk.infoedit_buttons[count])
			break;		
		InfoEditChunkSideChain_Remove(infoedit_selection_chunk.infoedit_buttons[count]);
		Remove(infoedit_selection_chunk.infoedit_buttons[count]);
	}
	memfree(infoedit_selection_chunk.infoedit_buttons);
	Remove(infoedit_selection_chunk);
	infoedit_selection_chunk = __NULL__;
}

void CycleInfoEditChunkSideType(entity e)
{
	e.chunkconnectiontype++;

	if(e.chunkconnectiontype >= numconnectiontypes)
		e.chunkconnectiontype = CHUNKCONNECTION_CLOSED;

//	hudstring_editor_chunkconnectiontype[e.chunksidenum] = GetNameForConnectionType(e.chunkconnectiontype);
	localcmd("cmd cq_setchunkconnection ", itos(e.chunksidenum), " ", itos(e.chunkconnectiontype), "\n");
}

void IncreaseFitNum(entity e)
{
	infoedit_selection_side[e.chunksidenum].chunkconnectionfit++;
	hudstring_editor_chunkconnectionfit[e.chunksidenum] = itos(infoedit_selection_side[e.chunksidenum].chunkconnectionfit);
	localcmd("cmd cq_setchunkconnectionfit ", itos(e.chunksidenum), " ", itos(infoedit_selection_side[e.chunksidenum].chunkconnectionfit), "\n");
}


void DecreaseFitNum(entity e)
{
	if(!infoedit_selection_side[e.chunksidenum].chunkconnectionfit)
		return;
	
	infoedit_selection_side[e.chunksidenum].chunkconnectionfit--;
	hudstring_editor_chunkconnectionfit[e.chunksidenum] = itos(infoedit_selection_side[e.chunksidenum].chunkconnectionfit);
	localcmd("cmd cq_setchunkconnectionfit ", itos(e.chunksidenum), " ", itos(infoedit_selection_side[e.chunksidenum].chunkconnectionfit), "\n");
}


void ExpandGroupSize(entity e)
{
	infoedit_selection_side[e.chunksidenum].chunkgroupsize++;
	hudstring_editor_chunkgroupsize[e.chunksidenum] = itos(infoedit_selection_side[e.chunksidenum].chunkgroupsize);
	localcmd("cmd cq_setchunkgroupsize ", itos(e.chunksidenum), " ", itos(infoedit_selection_side[e.chunksidenum].chunkgroupsize), "\n");
}

void ShrinkGroupSize(entity e)
{
	if(!infoedit_selection_side[e.chunksidenum].chunkgroupsize)
		return;
	
	infoedit_selection_side[e.chunksidenum].chunkgroupsize--;
	hudstring_editor_chunkgroupsize[e.chunksidenum] = itos(infoedit_selection_side[e.chunksidenum].chunkgroupsize);	
	localcmd("cmd cq_setchunkgroupsize ", itos(e.chunksidenum), " ", itos(infoedit_selection_side[e.chunksidenum].chunkgroupsize), "\n");
}

string GetConnectionFlagsString(int field)
{
	string s = __NULL__;
	if(field & CFL_ALLOWROTATEDFIT)
		s = "TRUE";
	else
		s = "FALSE";
	return strcat("Allow Rotated Fit: ", s);	
}

string GetChunkFlagsString(int field)
{
	string s = __NULL__;
	if(field & CHFL_ALLOWSAMEZONEPASSAGE)
		s = "TRUE";
	else
		s = "FALSE";
	return strcat("Allow Same Zone Passage: ", s);	
}

void ToggleConnectionFlag(entity e, int flag)
{
	int field = infoedit_selection_side[e.chunksidenum].chunkconnectionflags;
	
	if(field & flag)
		field = field - (field & flag);
	else
		field = field | flag;
	
	infoedit_selection_side[e.chunksidenum].chunkconnectionflags = field;
	hudstring_editor_chunkconnectionflags[e.chunksidenum] = GetConnectionFlagsString(field);
	localcmd("cmd cq_setchunkconnectionflags ", itos(e.chunksidenum), " ", itos(field), "\n");
}

void ToggleChunkFlag(entity e, int flag)
{
	int field = infoedit_selection_chunk.prefabchunkflags;
	
	if(field & flag)
		field = field - (field & flag);
	else
		field = field | flag;
	
	infoedit_selection_chunk.prefabchunkflags = field;
	hudstring_editor_prefabchunkflags = GetChunkFlagsString(field);
	localcmd("cmd cq_setchunkflags ", itos(field), "\n");
}

void IncreaseZoneNum(entity e)
{
	infoedit_selection_chunk.prefabzone++;
	hudstring_editor_prefabzone = itos(infoedit_selection_chunk.prefabzone);
	localcmd("cmd cq_setchunkzone ", itos(infoedit_selection_chunk.prefabzone), "\n");
}


void DecreaseZoneNum(entity e)
{
	if(!infoedit_selection_chunk.prefabzone)
		return;
	
	infoedit_selection_chunk.prefabzone--;
	hudstring_editor_prefabzone = itos(infoedit_selection_chunk.prefabzone);
	localcmd("cmd cq_setchunkzone ", itos(infoedit_selection_chunk.prefabzone), "\n");
}

void IncreaseGenChance(entity e)
{
	if(infoedit_selection_chunk.prefabchance == 100)
		return;

	infoedit_selection_chunk.prefabchance++;
	hudstring_editor_prefabchance = itos(infoedit_selection_chunk.prefabchance);
	localcmd("cmd cq_setchunkchance ", itos(infoedit_selection_chunk.prefabchance), "\n");
}


void DecreaseGenChance(entity e)
{
	if(!infoedit_selection_chunk.prefabchance)
		return;
	
	infoedit_selection_chunk.prefabchance--;
	hudstring_editor_prefabchance = itos(infoedit_selection_chunk.prefabchance);
	localcmd("cmd cq_setchunkchance ", itos(infoedit_selection_chunk.prefabchance), "\n");
}

void Editor_InfoEdit()
{
	if(infoedit_selection_side[0])
	if(!editor_infoedit)
		RemoveInfoEditChunkSides();
	
	if(!editor_infoedit)
		return;	
	
	if(!infoedit_selection_side[0])
		SpawnInfoEditChunkSides();

	infoedit_selection_side[0].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_UP);
	infoedit_selection_side[1].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_WEST);
	infoedit_selection_side[2].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_SOUTH);
	infoedit_selection_side[3].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_EAST);
	infoedit_selection_side[4].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_NORTH);
	infoedit_selection_side[5].chunkconnectiontype = getstati(STAT_EDITOR_CHUNKSIDETYPE_DOWN);
	
	infoedit_selection_side[0].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_UP);
	infoedit_selection_side[1].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_WEST);
	infoedit_selection_side[2].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_SOUTH);
	infoedit_selection_side[3].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_EAST);
	infoedit_selection_side[4].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_NORTH);
	infoedit_selection_side[5].chunkconnectionfit = getstati(STAT_EDITOR_CHUNKSIDEFIT_DOWN);
	
	infoedit_selection_side[0].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_UP);
	infoedit_selection_side[1].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_WEST);
	infoedit_selection_side[2].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_SOUTH);
	infoedit_selection_side[3].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_EAST);
	infoedit_selection_side[4].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_NORTH);
	infoedit_selection_side[5].chunkconnectionflags = getstati(STAT_EDITOR_CHUNKSIDEFLAGS_DOWN);	
	
	infoedit_selection_side[0].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_UP);
	infoedit_selection_side[1].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_WEST);
	infoedit_selection_side[2].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_SOUTH);
	infoedit_selection_side[3].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_EAST);
	infoedit_selection_side[4].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_NORTH);
	infoedit_selection_side[5].chunkgroupsize = getstati(STAT_EDITOR_CHUNKGROUPSIZE_DOWN);
	
	infoedit_selection_chunk.prefabzone = getstati(STAT_EDITOR_CHUNKZONE);
	infoedit_selection_chunk.prefabchance = getstati(STAT_EDITOR_CHUNKCHANCE);
	infoedit_selection_chunk.prefabchunkflags = getstati(STAT_EDITOR_CHUNKFLAGS);
		
	if(editor_editchunk != editor_editchunk_old)
	{
		for(int count = 0; count < 6; count++)
		{
			hudstring_editor_chunkconnectionfit[count] = itos(infoedit_selection_side[count].chunkconnectionfit);	
			hudstring_editor_chunkconnectionflags[count] = GetConnectionFlagsString(infoedit_selection_side[count].chunkconnectionflags);
			hudstring_editor_chunkgroupsize[count] = itos(infoedit_selection_side[count].chunkgroupsize);
		}
		
		hudstring_editor_prefabzone = itos(infoedit_selection_chunk.prefabzone);
		hudstring_editor_prefabchance = itos(infoedit_selection_chunk.prefabchance);
		hudstring_editor_prefabchunkflags = GetChunkFlagsString(infoedit_selection_chunk.prefabchunkflags);
	}
	
	makevectors(view_ang);
	
	self.dimension_hit = 255&~1;
	traceline(view_org, view_org + v_forward*cubicradius*2*(tooltracedist*2), MOVE_NORMAL, self);
	self.dimension_hit = 255;

	if(trace_ent)
	{
		if(trace_ent.enttype == ENT_INFOEDIT_SELECTION)
			trace_ent.drawextendedbuttons = TRUE;
		
		if(trace_ent.parentbutton.enttype == ENT_INFOEDIT_SELECTION)
			trace_ent.parentbutton.drawextendedbuttons = TRUE;
		
		if(player_input[INPUT_ATTACK] == 1) // lmb
		{
			if(trace_ent.enttype == ENT_INFOEDIT_SELECTION)
			{	
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKSIDETYPE)
					CycleInfoEditChunkSideType(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_FITNUM_INCREASE)
					IncreaseFitNum(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_FITNUM_DECREASE)
					DecreaseFitNum(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_GROUPSIZE_EXPAND)
					ExpandGroupSize(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_GROUPSIZE_SHRINK)
					ShrinkGroupSize(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKZONE_INCREASE)
					IncreaseZoneNum(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKZONE_DECREASE)
					DecreaseZoneNum(trace_ent);				
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKCHANCE_INCREASE)
					IncreaseGenChance(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKCHANCE_DECREASE)
					DecreaseGenChance(trace_ent);
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_ALLOWSAMEZONEPASSAGE)
					ToggleChunkFlag(trace_ent, CHFL_ALLOWSAMEZONEPASSAGE);				
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_ALLOWROTATEDFIT)
					ToggleConnectionFlag(trace_ent, CFL_ALLOWROTATEDFIT);				
			}
		}
		else
		if(player_input[INPUT_BUTTON1] == 1) // rmb
		{
			if(trace_ent.enttype == ENT_INFOEDIT_SELECTION)
			{
			//	infoedit_selection_side[trace_ent.chunksidenum].chunkconnectionfit = editor_connectionfit;
				if(trace_ent.buttontype == BTTN_INFOEDIT_FITNUM_INCREASE || trace_ent.buttontype == BTTN_INFOEDIT_FITNUM_DECREASE)
					localcmd("cmd cq_setchunkconnectionfit ", itos(trace_ent.chunksidenum), " ", itos(editor_connectionfit), "\n");
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKZONE_INCREASE || trace_ent.buttontype == BTTN_INFOEDIT_CHUNKZONE_DECREASE)
					localcmd("cmd cq_setchunkzone ", itos(editor_chunkzone), "\n");
				else
				if(trace_ent.buttontype == BTTN_INFOEDIT_CHUNKCHANCE_INCREASE || trace_ent.buttontype == BTTN_INFOEDIT_CHUNKCHANCE_DECREASE)
					localcmd("cmd cq_setchunkchance ", itos(editor_chunkchance), "\n");
			}
		}
	}
}

void SetToolColorForState(int toolonedge, vector defaultcolor)
{
	if(toolonedge)
		cubeselector.lightcolor = '2 0 0';
	else
		cubeselector.lightcolor = defaultcolor;	
}

void UpdateCubicInterface()
{
	if(!client_initialized)
		return;

	editor_tool = getstati(STAT_TOOL);	
	editor_infoedit = getstati(STAT_EDITOR_INFOEDIT);
	editor_editchunk = getstati(STAT_EDITOR_EDITCHUNK);
	editor_fillmode = getstati(STAT_EDITOR_FILLMODE);
	editor_toolsize = getstati(STAT_TOOLSIZE);
	int playerclusterid = getstati(STAT_PLAYERCLUSTERID);
	float toolscale = GetToolScale(editor_toolsize);
	editor_cubictype = getstati(STAT_EDITOR_BLOCKTYPE);	
	editor_cubicshape = getstati(STAT_EDITOR_BLOCKSHAPE);
	editor_cubicrotation = getstati(STAT_EDITOR_BLOCKROTATION);
	editor_sizetool = getstati(STAT_EDITOR_SIZETOOL);
	int toolonedge;
	entity facegroup, nexte;
	vector cubicpos, clusterpos;
	vector org = '0 0 0';
//	int	drawingnonsolid = FALSE;

//print(ftos(editor_tool), "\n");

	if(editor_tool != editor_tool_old || !hudstring_editor_tool)
		hudstring_editor_tool = strcat("Tool:", GetToolName(editor_tool));
	
	if(editor_toolsize != editor_toolsize_old || !hudstring_editor_toolsize)
		hudstring_editor_toolsize = strcat("Size:", GetToolSizeName(editor_toolsize));
	
	if(editor_cubictype != editor_cubictype_old || !hudstring_editor_cubictype)
		hudstring_editor_cubictype = strcat("Type:", itos(editor_cubictype));
	
	if(editor_cubicshape != editor_cubicshape_old || !hudstring_editor_cubicshape)
		hudstring_editor_cubicshape = strcat("Shape:", itos(editor_cubicshape));
	
	if(editor_cubicrotation != editor_cubicrotation_old || !hudstring_editor_cubicrotation)
		hudstring_editor_cubicrotation = strcat("Rotation:", itos(editor_cubicrotation));
	
	Editor_InfoEdit();
	Editor_ModifySide();

//	if(player_input[INPUT_TOOLDIM] < 1)
	if(!editor_sizetool)	
	{
		if(!editor_infoedit && editor_tool >= TOOL_EDITOR_MODIFY && editor_tool <= TOOL_EDITOR_INFOEDIT)
		{
			int getinside = FALSE;
			if(editor_tool == TOOL_EDITOR_MODIFY || editor_tool == TOOL_EDITOR_COPY || editor_tool == TOOL_EDITOR_INFOEDIT)
				getinside = TRUE;
			
			makevectors(view_ang);

			cubicpos = TraceCubic(view_org, view_org + v_forward*cubicradius*2*tooltracedist*((editor_toolsize > TOOLSIZE_EDITOR_CUBIC)*1+1), getinside);

			switch(editor_toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(cubicpos, chunksize_iseven);	break;
				case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(cubicpos);							break;
				case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(cubicpos);							break;
			}
			
	//		print(vtos(org), " : ", vtos(cubeselector.origin), "\n");
			
			clusterpos = GetClusterOffset(playerclusterid);
			toolonedge = ToolIsOnEdge(clusterpos, org, editor_toolsize, editor_tool, editor_selection_mins, editor_selection_maxs);
			
/*				if(getinside && toolscale > 1)
			{
				if(cubeselector.blocktype)
					setmodel(cubeselector, "models/editor/cubeselector.mdl");

				setorigin(cubeselector, org);
				UpdateModifySideButtonOrgs();

				cubeselector.scale = toolscale;
				cubeselector.drawmask = MASK_NORMAL;
				cubeselector.alpha = 0.4;
				cubeselector.blocktype = 0;
			}
			else*/
			if(!getinside && numobjectblocktypes && editor_cubictype >= baseobjecttypeid && editor_tool == TOOL_EDITOR_ADD) // placing object
			{	// we just run this every frame because it doesn't need to rebuild anything
				if(cubeselector.blocktype != editor_cubictype)
					SetModelForCubicObject(cubeselector, editor_cubictype, FALSE);

				setorigin(cubeselector, org);
				UpdateModifySideButtonOrgs();

				cubeselector.scale = 1;
				cubeselector.drawmask = MASK_NORMAL;
				cubeselector.alpha = 0.6;
				cubeselector.blocktype = editor_cubictype;
				
				if(editor_toolsize > TOOLSIZE_EDITOR_CUBIC)
					cubeselector.scale = 4;
				
				if(toolonedge || editor_toolsize > TOOLSIZE_EDITOR_CUBIC)
					cubeselector.colormod = '1 0 0';
				else
					cubeselector.colormod = '0 0 0';
				
			//	drawingnonsolid = TRUE;
			}			
			else
			if(playerclusterid != playerclusterid_old
			|| editor_tool != editor_tool_old
			|| editor_fillmode != editor_fillmode_old
			|| editor_cubictype != editor_cubictype_old
			|| editor_cubicshape != editor_cubicshape_old
			|| editor_cubicrotation != editor_cubicrotation_old
			|| (!editor_sizetool && org != editor_selectororg_old))			
//			|| (!player_input[INPUT_TOOLDIM] && org != editor_selectororg_old))
			{
				for(facegroup = cubeselector.list_facegroupchain; facegroup; facegroup = nexte)
				{
					nexte = facegroup.facegroupchain;
					RemoveFaceGroup(cubeselector, facegroup);
				}
				
				setorigin(cubeselector, org);
				UpdateModifySideButtonOrgs();
				
				cubeselector.drawmask = FALSE;	// cubeselector acts as the typegroup entity

				if(getinside || (editor_tool == TOOL_EDITOR_PASTE && editor_toolsize >= TOOLSIZE_EDITOR_CHUNK))
				{
					cubeselector.alpha = 0.3;
					cubeselector.blocktype = BLOCKTYPE_EDIT;
					
					if(editor_tool == TOOL_EDITOR_MODIFY)
						SetToolColorForState(toolonedge, '1 1 0');
					else
					if(editor_tool == TOOL_EDITOR_COPY)
						SetToolColorForState(toolonedge, '0 1 0');
					else
					if(editor_tool == TOOL_EDITOR_PASTE)
						SetToolColorForState(toolonedge, '1 0 1');
					else
					if(editor_tool == TOOL_EDITOR_INFOEDIT)
						SetToolColorForState(toolonedge, '0 0 1');
					
					if((numobjectblocktypes && editor_cubictype >= baseobjecttypeid) || toolscale > 1)
						BuildFaces_Custom(cubeselector, org, FALSE, toolscale);
					else
						BuildFaces_Custom(cubeselector, org, TRUE, 1);
				}
				else
				{
					cubeselector.alpha = 1;
					cubeselector.blocktype = editor_cubictype;
					SetToolColorForState(toolonedge, '2 2 2');
					
					if(toolscale == 1)
						BuildFacesForPlacementTool();
					else
						BuildFacesForShape(cubeselector, editor_cubicshape, editor_cubicrotation, 0, cubeselector.origin, 1, toolscale+0.01);
				}
				
				editor_selectororg_old = org;
			}
		}
		else
			cubeselector.drawmask = FALSE;
	}
	
	playerclusterid_old = playerclusterid;
	editor_tool_old = editor_tool;
	editor_toolsize_old = editor_toolsize;
	editor_fillmode_old = editor_fillmode;
	editor_cubictype_old = editor_cubictype;
	editor_cubicshape_old = editor_cubicshape;
	editor_cubicrotation_old = editor_cubicrotation;
	editor_editchunk_old = editor_editchunk;
}

void DrawSelectorFaces()
{
	if(!editor_infoedit)
	if(editor_tool)
	if(cubeselector.blocktype)
	if(!cubeselector.drawmask)
	for(entity facegroup = cubeselector.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
		DrawFaceGroup(facegroup);	
}

void InitializeCubicInterface()
{
	cubeselector = spawn();
	setmodel(cubeselector, "models/editor/cubeselector.mdl");
	cubeselector.lightcolor = '2 2 2';
	cubeselector.renderflags = RF_ADDITIVE;
	editor_chunkchance = 100;
}