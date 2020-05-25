//////////////////
// WEDGE TIP START

void BuildFaces_WedgeTip(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_E;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 0, 1))	// the ramp function works the same as a wedge tip would
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,0,3,4,3,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_DNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 2:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSE; break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_DNW; else if(count == 2) vertofs = VECOFS_DNE; break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			if(vertofs_z == 1)
				vertofs_z = 0;	// this seems like an easy way to do terrain possibly (need ramp/wedgetip corners also)
			
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 2)
			{
				if(count == 0)	texturecoords = '0 1 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '1 1 0';	
			}
			else
			if(facecount == 4)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 1 0';	else
				if(count == 2)	texturecoords = '0 1 0';					
			}
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			if(facecount >= 1 && facecount <= 4)
			if(texturecoords_y == 0)
				texturecoords_y = 0.5;
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_WedgeTip_CW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S | CULLBITS_E;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 2, 1))
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 3,0,4,4,4,3);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USE; break;	// TOP
				case 2:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DNW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DNW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNE; break;	// BOTTOM
			}
	
			if(vertofs_y == -1)
				vertofs_y = 0;
	
			vertofs = RotateVertOFS(vertofs, rotation);
			texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			if(facecount == 0 && count == 2)
			{
				if(rotation == BLOCKROTATION_CW_E)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_CW_N)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_CW_W)
					texturecoords = '0 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CW_S)
					texturecoords = '0.5 1 0';
			}
			else
			if(facecount == 5 && count == 1)
			{
				if(rotation == BLOCKROTATION_CW_E)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_CW_N)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_CW_W)
					texturecoords = '0 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CW_S)
					texturecoords = '0.5 0 0';
			}				
			else
			if(facecount == 3)
			{
				if(texturecoords_x == 0)
					texturecoords_x = 0.5;
			}
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_WedgeTip_UD(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_E;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 5, 1))	// the ramp function works the same as a wedge tip would
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,0,3,4,3,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSE; break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_UNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			if(vertofs_z == -1)
				vertofs_z = 0;	// this seems like an easy way to do terrain possibly (need ramp/wedgetip corners also)
			
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 2)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '1 1 0';	
			}
			else
			if(facecount == 4)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '0 1 0';					
			}
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			if(facecount >= 1 && facecount <= 4)
			if(texturecoords_y == 1)
				texturecoords_y = 0.5;
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_WedgeTip_CCW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S | CULLBITS_E;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 4, 1))
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 3,0,4,4,4,3);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USE; break;	// TOP
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DSW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNE; break;	// BOTTOM
			}
	
			if(vertofs_y == 1)
				vertofs_y = 0;
	
			vertofs = RotateVertOFS(vertofs, rotation);
			texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			if(facecount == 0 && count == 1)
			{
				if(rotation == BLOCKROTATION_CCW_E)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_CCW_N)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_CCW_W)
					texturecoords = '0 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CCW_S)
					texturecoords = '0.5 1 0';
			}
			else
			if(facecount == 5 && count == 2)
			{
				if(rotation == BLOCKROTATION_CCW_E)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_CCW_N)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_CCW_W)
					texturecoords = '0 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CCW_S)
					texturecoords = '0.5 0 0';
			}				
			else
			if(facecount == 3)
			{
				if(texturecoords_x == 1)
					texturecoords_x = 0.5;
			}
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}
	
void BuildFaces_WedgeTip_FW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_E | CULLBITS_N | CULLBITS_S | CULLBITS_D;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 3, 0))	// the ramp function works the same as a wedge tip would
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 0,4,3,4,3,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DSW;	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DSW; break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_DNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNW; break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			if(vertofs_x == 1)
				vertofs_x = 0;
			
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 2)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '0.5 1 0';	else
				if(count == 2)	texturecoords = '0 1 0';	
			}
			else
			if(facecount == 4)
			{
				if(count == 0)	texturecoords = '0.5 1 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '1 1 0';					
			}
			else
			if(facecount == 5)
			{
				if(rotation == BLOCKROTATION_FW_E)
				{	if(count == 0) texturecoords = '0 0 0'; else if(count == 1) texturecoords = '0.5 0 0'; else if(count == 2) texturecoords = '0 1 0'; else if(count == 3) texturecoords = '0.5 1 0';	}
				else
				if(rotation == BLOCKROTATION_FW_N)
				{	if(count == 0) texturecoords = '1 0 0'; else if(count == 1) texturecoords = '1 0.5 0'; else if(count == 2) texturecoords = '0 0 0'; else if(count == 3) texturecoords = '0 0.5 0';	}
				else
				if(rotation == BLOCKROTATION_FW_W)
				{	if(count == 0) texturecoords = '1 1 0'; else if(count == 1) texturecoords = '0.5 1 0'; else if(count == 2) texturecoords = '1 0 0'; else if(count == 3) texturecoords = '0.5 0 0';	}
				else
				if(rotation == BLOCKROTATION_FW_S)
				{	if(count == 0) texturecoords = '0 1 0'; else if(count == 1) texturecoords = '0 0.5 0'; else if(count == 2) texturecoords = '1 1 0'; else if(count == 3) texturecoords = '1 0.5 0';	}
			}
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_WedgeTip_BW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, numvertsforface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_D;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 1, 5))	// the ramp function works the same as a wedge tip would
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,3,4,3,0);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DSE;	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSE; break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; break;	// NORTH
			}
	
			if(vertofs_x == -1)
				vertofs_x = 0;
			
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 2)
			{
				if(count == 0)	texturecoords = '0.5 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '1 1 0';	
			}
			else
			if(facecount == 4)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '0.5 0 0';	else
				if(count == 2)	texturecoords = '0 1 0';					
			}
			else
			if(facecount == 0)
			{
				if(rotation == BLOCKROTATION_BW_E)
				{	if(count == 0) texturecoords = '0.5 0 0'; else if(count == 1) texturecoords = '1 0 0'; else if(count == 2) texturecoords = '0.5 1 0'; else if(count == 3) texturecoords = '1 1 0';	}
				else
				if(rotation == BLOCKROTATION_BW_N)
				{	if(count == 0) texturecoords = '1 0 0'; else if(count == 1) texturecoords = '1 0.5 0'; else if(count == 2) texturecoords = '0 0 0'; else if(count == 3) texturecoords = '0 0.5 0';	}
				else
				if(rotation == BLOCKROTATION_BW_W)
				{	if(count == 0) texturecoords = '0.5 1 0'; else if(count == 1) texturecoords = '0 1 0'; else if(count == 2) texturecoords = '0.5 0 0'; else if(count == 3) texturecoords = '0 0 0';	}
				else
				if(rotation == BLOCKROTATION_BW_S)
				{	if(count == 0) texturecoords = '0 1 0'; else if(count == 1) texturecoords = '0 0.5 0'; else if(count == 2) texturecoords = '1 1 0'; else if(count == 3) texturecoords = '1 0.5 0';	}
			}
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

// WEDGE TIP END
////////////////