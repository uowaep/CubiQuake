void R_DrawFace(vector pos, vector face_forward, vector face_right, vector face_up) // this isn't used for anything. it's just here.
{
	string imgname = "textures/block.tga";
	float alpha_ratio = 1;
	vector rgb = '1 1 1';
	
	float facedepth = 1;
	face_forward*=facedepth;
	face_right*=facedepth;
	face_up*=facedepth;
	pos += face_forward*-1;
	
	R_BeginPolygon(imgname, 0, FALSE);
	R_PolygonVertex(pos + face_right*-1 + face_up, '0 0 0', rgb, alpha_ratio);	
	R_PolygonVertex(pos + face_right + face_up, '1 0 0', rgb, alpha_ratio);
	R_PolygonVertex(pos + face_right + face_up*-1, '1 1 0', rgb, alpha_ratio);
	R_PolygonVertex(pos + face_right*-1 + face_up*-1, '0 1 0', rgb, alpha_ratio);	
	R_EndPolygon();	
}

// CSQC_UpdateView - Called every rendered frame on the client.  Useful for HUD drawing operations.
void CSQC_UpdateView(float vwidth, float vheight, float notmenu)
{
	// ALWAYS Clear Current Scene First
	clearscene();

	view_org = getproperty(VF_ORIGIN);
	view_ang = getproperty(VF_ANGLES);
	
	setorigin(clientlight, view_org);	// client light entity origin update
	AddLights();

	UpdateCubicInterface();
	
	DrawChunks();
		
	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 1);
	// Draw the Engine Status Bar (the default Quake HUD)
//	setproperty(VF_DRAWENGINESBAR, 0);

	// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
	addentities(MASK_NORMAL | MASK_ENGINE);

	renderscene();
	
	string s = strcat("cubiquake r", itos(cubic_revision));
	drawstring([vwidth-(strlen(s)*8+2), 2, 0], s, '8 8 0', '1 1 1', 1, 0);
}