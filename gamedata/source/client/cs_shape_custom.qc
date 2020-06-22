void BuildFaces_Custom(entity typegroup, vector cubicpos, int usecustom, float facescale, int listid)
{
	int facecount = 0, facebit = 0, count = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0', sel_mins = '0 0 0', sel_maxs = '0 0 0';

	float bufferthickness = 0.02;
	
	if(usecustom)
	{
		sel_maxs_z = editor_selection_maxs_z/cubicradius - 1 + bufferthickness;
		sel_mins_x = editor_selection_mins_x/cubicradius + 1 + bufferthickness*-1;
		sel_mins_y = editor_selection_mins_y/cubicradius + 1 + bufferthickness*-1;
		sel_maxs_x = editor_selection_maxs_x/cubicradius - 1 + bufferthickness;
		sel_maxs_y = editor_selection_maxs_y/cubicradius - 1 + bufferthickness;
		sel_mins_z = editor_selection_mins_z/cubicradius + 1 + bufferthickness*-1;
	}
	else
	{
		sel_maxs_z = 1*facescale + bufferthickness;
		sel_mins_x = -1*facescale + bufferthickness*-1;
		sel_mins_y = -1*facescale + bufferthickness*-1;
		sel_maxs_x = 1*facescale + bufferthickness;
		sel_maxs_y = 1*facescale + bufferthickness;
		sel_mins_z = -1*facescale + bufferthickness*-1;
	}
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		for(count = 0; count < 4; count++)	// vertexes
		{
			switch(facecount)
			{
				// TOP
				case 0:	if(count == 0) vertofs = [sel_mins_x, sel_maxs_y, sel_maxs_z];	//UNW
					else if(count == 1) vertofs = [sel_maxs_x, sel_maxs_y, sel_maxs_z];	//UNE
					else if(count == 2) vertofs = [sel_mins_x, sel_mins_y, sel_maxs_z];	//USW
					else if(count == 3) vertofs = [sel_maxs_x, sel_mins_y, sel_maxs_z];	//USE
					break;
				
				// WEST
				case 1:	if(count == 0) vertofs = [sel_mins_x, sel_maxs_y, sel_maxs_z];	//UNW
					else if(count == 1) vertofs = [sel_mins_x, sel_mins_y, sel_maxs_z];	//USW
					else if(count == 2) vertofs = [sel_mins_x, sel_maxs_y, sel_mins_z];	//DNW
					else if(count == 3) vertofs = [sel_mins_x, sel_mins_y, sel_mins_z];	//DSW
					break;	
				
				// SOUTH
				case 2:	if(count == 0) vertofs = [sel_mins_x, sel_mins_y, sel_maxs_z];	//USW
					else if(count == 1) vertofs = [sel_maxs_x, sel_mins_y, sel_maxs_z];	//USE
					else if(count == 2) vertofs = [sel_mins_x, sel_mins_y, sel_mins_z];	//DSW
					else if(count == 3) vertofs = [sel_maxs_x, sel_mins_y, sel_mins_z];	//DSE
					break;	
				
				// EAST
				case 3:	if(count == 0) vertofs = [sel_maxs_x, sel_mins_y, sel_maxs_z];	//USE
					else if(count == 1) vertofs = [sel_maxs_x, sel_maxs_y, sel_maxs_z];	//UNE
					else if(count == 2) vertofs = [sel_maxs_x, sel_mins_y, sel_mins_z];	//DSE
					else if(count == 3) vertofs = [sel_maxs_x, sel_maxs_y, sel_mins_z];	//DNE
					break;	
				
				// NORTH
				case 4:	if(count == 0) vertofs = [sel_maxs_x, sel_maxs_y, sel_maxs_z];	//UNE
					else if(count == 1) vertofs = [sel_mins_x, sel_maxs_y, sel_maxs_z];	//UNW
					else if(count == 2) vertofs = [sel_maxs_x, sel_maxs_y, sel_mins_z];	//DNE
					else if(count == 3) vertofs = [sel_mins_x, sel_maxs_y, sel_mins_z];	// DNW
					break;
				
				// BOTTOM
				case 5:	if(count == 0) vertofs = [sel_mins_x, sel_mins_y, sel_mins_z];	//DSW
					else if(count == 1) vertofs = [sel_maxs_x, sel_mins_y, sel_mins_z];	//DSE
					else if(count == 2) vertofs = [sel_mins_x, sel_maxs_y, sel_mins_z];	// DNW
					else if(count == 3) vertofs = [sel_maxs_x, sel_maxs_y, sel_mins_z];	//DNE
					break;	
			}
			
			switch(count)
			{
				case 0:	texturecoords = '0 0 0';	break;
				case 1:	texturecoords = '1 0 0';	break;
				case 2:	texturecoords = '0 1 0';	break;
				case 3:	texturecoords = '1 1 0';	break;
			}
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, 1, texturecoords, 1, listid);
		}

		SetVertexIndexes(4, typegroup, facebit);
	}	
}