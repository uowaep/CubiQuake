void DrawHud2D(float vwidth)
{
	string s;
	float rightpanewidth = 100;
	float hudalpha = 0.7;
	
	s = cubic_revision;
	drawstring([vwidth-rightpanewidth, 2, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
	
	if(editor_tool)
	{
		s = hudstring_editor_tool;
		drawstring([(vwidth)*0.5, 2, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
		s = hudstring_editor_toolsize;
		drawstring([(vwidth)*0.5, 2+8+2, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
		
		s = hudstring_editor_cubictype;
		drawstring([(vwidth-rightpanewidth), 12+8+2, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
		s = hudstring_editor_cubicshape;
		drawstring([(vwidth-rightpanewidth), 12+(8+2)*2, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
		s = hudstring_editor_cubicrotation;
		drawstring([(vwidth-rightpanewidth), 12+(8+2)*3, 0], s, '6 6 0', '1 1 1', hudalpha, 0);	
		
		s = hudstring_editor_totalcubics;
		drawstring([(vwidth-rightpanewidth), 12+(8+2)*5, 0], s, '6 6 0', '1 1 1', hudalpha, 0);
		
		for(entity e = list_infoeditchunksidechain; e; e = e.infoeditchunksidechain)
		{
			if(e.enttype == ENT_INFOEDIT_SELECTION)
			if(e.buttontype == BTTN_INFOEDIT_CHUNKSIDETYPE)
			{
				s = hudstring_editor_chunkconnectionfit[e.chunksidenum];
				drawstring(project(e.origin+[0, 0, cubicradius*2.5])-('8 8 0')*0.5, s, '8 8 0', '1 1 1', hudalpha, 0);

				if(e.drawextendedbuttons)
				{
					s = "(Connection Fit ID#)";
					drawstring(project(e.origin+[0, 0, cubicradius*2.5])-('6 6 0')*0.5 + '0 10 0', s, '6 6 0', '1 1 1', hudalpha, 0);
				}
				
				s = hudstring_editor_chunkgroupsize[e.chunksidenum];				
				drawstring(project(e.origin+[0, 0, cubicradius*-2.5])-('8 8 0')*0.5, s, '8 8 0', '1 1 1', hudalpha, 0);

				if(e.drawextendedbuttons)
				{
					s = "(Chunk Group Size Bounds)";
					drawstring(project(e.origin+[0, 0, cubicradius*-2.5])-('6 6 0')*0.5 + '0 10 0', s, '6 6 0', '1 1 1', hudalpha, 0);
				}
			
				s = GetNameForConnectionType(e.chunkconnectiontype);//hudstring_editor_chunkconnectiontype[e.chunksidenum];
				drawstring(project(e.origin)-('6 6 0')*0.5, s, '6 6 0', '0 0 0', hudalpha, 0);
				
				if(e.drawextendedbuttons)
				{
					s = hudstring_editor_chunkconnectionflags[e.chunksidenum];
					drawstring(project(e.infoedit_buttons[4].origin)+'10 0 0' - '0 6 0'*0.5, s, '6 6 0', '1 1 1', hudalpha, 0);
				}
			}
			else
			if(e.buttontype == BTTN_INFOEDIT_CHUNK)
			{
				s = hudstring_editor_prefabzone;
				drawstring(project(e.origin+[0, 0, cubicradius*2.5])-('8 8 0')*0.5, s, '8 8 0', '1 1 1', hudalpha, 0);

				if(e.drawextendedbuttons)
				{
					s = "(Prefab Zone ID#)";
					drawstring(project(e.origin+[0, 0, cubicradius*2.5])-('6 6 0')*0.5 + '0 10 0', s, '6 6 0', '1 1 1', hudalpha, 0);
				}
				
				s = hudstring_editor_prefabchance;				
				drawstring(project(e.origin+[0, 0, cubicradius*-2.5])-('8 8 0')*0.5, s, '8 8 0', '1 1 1', hudalpha, 0);

				if(e.drawextendedbuttons)
				{
					s = "(Generation Chance %)";
					drawstring(project(e.origin+[0, 0, cubicradius*-2.5])-('6 6 0')*0.5 + '0 10 0', s, '6 6 0', '1 1 1', hudalpha, 0);
				}

				if(e.drawextendedbuttons)
				{
					s = hudstring_editor_prefabchunkflags;				
					drawstring(project(e.origin)+'10 0 0' - '0 6 0'*0.5, s, '6 6 0', '1 1 1', hudalpha, 0);
				}				
			}
			
			e.drawextendedbuttons = FALSE;
		}
	}
}

// CSQC_UpdateView - Called every rendered frame on the client.  Useful for HUD drawing operations.
void CSQC_UpdateView(float vwidth, float vheight, float notmenu)
{
	// ALWAYS Clear Current Scene First
	clearscene();

	view_size  = [vwidth, vheight, 0];
	view_org = getproperty(VF_ORIGIN);
	view_ang = getproperty(VF_ANGLES);
	makevectors(view_ang);
	view_normal = v_forward;
	view_right = v_right;
	float mindist = getproperty(VF_MINDIST);
	view_point = view_org + v_forward*mindist;
	
	setorigin(clientlight, view_org);	// client light entity origin update

	UpdateCubicInterface();
	
	if(editor_fillmode)
		DrawSelectorFaces();
	
	UpdateFaceQueuesForPlayerPosition();
	BuildNearQueuedFaces();
	BuildQueuedFaces();
	AddLights();	
	DrawChunks();
	
	if(!editor_fillmode)
		DrawSelectorFaces();

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 1);

	// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
	addentities(MASK_NORMAL | MASK_ENGINE);

	renderscene();
	
	DrawGrids();
	DrawHud2D(vwidth);

	IncreaseInputStates();
}