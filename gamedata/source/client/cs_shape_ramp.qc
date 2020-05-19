/////////////
// RAMP START

int SkipFace_Ramp(int facecount, int facebit, int cullbits, int subbits, int rampface, int emptyface)
{
	if(facecount == emptyface) // skip empty face
		return TRUE;

	if(facecount == rampface)	// check multiple culls to not draw ramp face
	{
		if((cullbits & subbits) == subbits)
			return TRUE;
	}
	else
	if(facecount < 6)
	if(cullbits & facebit)
		return TRUE;

	return FALSE;
}

void BuildFaces_Ramp(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 0, 1))
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
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Ramp_CW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S;
	
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
	
			vertofs = RotateVertOFS(vertofs, rotation);
			texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Ramp_UD(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 5, 1))
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
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

// RAMP END
///////////