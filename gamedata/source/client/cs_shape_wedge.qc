//////////////////
// WEDGE START

void BuildFaces_Wedge(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 0, -1))	// the ramp function works for wedges
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = '-1 1 0'; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = '-1 -1 0'; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = '-1 1 0'; else if(count == 1) vertofs = '-1 -1 0'; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DSW;	break;	// WEST
				case 2:	if(count == 0) vertofs = '-1 -1 0'; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = '-1 1 0'; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DNW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 1 && count == 0)
				texturecoords = '0 0.5 0';
			else
			if(facecount == 1 && count == 1)
				texturecoords = '1 0.5 0';	
			else
			if(facecount == 2 && count == 0)
				texturecoords = '0 0.5 0';
			else
			if(facecount == 4 &&  count == 1)
				texturecoords = '1 0.5 0';
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Wedge_CW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 2, -1))
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = '-1 0 1'; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = '-1 0 1'; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = '-1 0 -1';	break;	// WEST
				case 2:	if(count == 0) vertofs = '-1 0 1'; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = '-1 0 -1'; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DNW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = '-1 0 -1'; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);
			
			if(facecount == 0 && count == 2)
			{
				if(rotation == BLOCKROTATION_CW_E)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_CW_N)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_CW_W)
					texturecoords = '1 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CW_S)
					texturecoords = '0.5 0 0';
			}
			else
			if(facecount == 5 &&  count == 0)
			{
				if(rotation == BLOCKROTATION_CW_E)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_CW_N)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_CW_W)
					texturecoords = '1 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CW_S)
					texturecoords = '0.5 1 0';
			}
			else
			if(facecount == 1 && count == 1)
				texturecoords = '0.5 0 0';
			else
			if(facecount == 1 && count == 3)
				texturecoords = '0.5 1 0';	
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Wedge_UD(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 5, -1))	// the ramp function works for wedges
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = '-1 1 0'; else if(count == 3) vertofs = '-1 -1 0';	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = '-1 -1 0'; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = '-1 1 0';	break;	// NORTH
				case 5:	if(count == 0) vertofs = '-1 -1 0'; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = '-1 1 0'; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 1 && count == 2)
				texturecoords = '0 0.5 0';
			else
			if(facecount == 1 && count == 3)
				texturecoords = '1 0.5 0';	
			else
			if(facecount == 2 && count == 2)
				texturecoords = '0 0.5 0';
			else
			if(facecount == 4 &&  count == 3)
				texturecoords = '1 0.5 0';
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Wedge_CCW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_N;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 4, -1))
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = '-1 0 1'; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = '-1 0 1'; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = '-1 0 -1'; else if(count == 3) vertofs = VECOFS_DSW;	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = '-1 0 1'; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = '-1 0 -1';	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = '-1 0 -1'; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);
			
			if(facecount == 0 && count == 0)
			{
				if(rotation == BLOCKROTATION_CCW_E)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_CCW_N)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_CCW_W)
					texturecoords = '1 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CCW_S)
					texturecoords = '0.5 0 0';
			}
			else
			if(facecount == 5 &&  count == 2)
			{
				if(rotation == BLOCKROTATION_CCW_E)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_CCW_N)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_CCW_W)
					texturecoords = '1 0.5 0';			
				else
				if(rotation == BLOCKROTATION_CCW_S)
					texturecoords = '0.5 1 0';
			}
			else
			if(facecount == 1 && count == 0)
				texturecoords = '0.5 0 0';
			else
			if(facecount == 1 && count == 2)
				texturecoords = '0.5 1 0';	
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Wedge_FW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_E | CULLBITS_N | CULLBITS_S;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 3, -1))	// the ramp function works for wedges
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = '0 1 1'; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = '0 -1 1';	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DSW;	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = '0 -1 1'; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = '0 -1 1'; else if(count == 1) vertofs = '0 1 1'; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = '0 1 1'; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DNW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 0 && count == 1)
			{
				if(rotation == BLOCKROTATION_FW_E)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_FW_N)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_FW_W)
					texturecoords = '0.5 1 0';			
				else
				if(rotation == BLOCKROTATION_FW_S)
					texturecoords = '1 0.5 0';
			}
			else
			if(facecount == 0 && count == 3)
			{
				if(rotation == BLOCKROTATION_FW_E)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_FW_N)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_FW_W)
					texturecoords = '0.5 0 0';			
				else
				if(rotation == BLOCKROTATION_FW_S)
					texturecoords = '0 0.5 0';
			}
			else
			if(facecount == 2 && count == 1)
				texturecoords = '0.5 0 0';
			else
			if(facecount == 4 && count == 0)
				texturecoords = '0.5 0 0';			
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Wedge_BW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texturecoords;

	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S;	// ramp face needs to check these sides for culling
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, 1, -1))	// the ramp function works for wedges
			continue;

		numvertsforface = GetNumVertsForFace(facecount, 4,4,4,4,4,4);
		
		for(count = 0; count < numvertsforface; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = '0 1 -1'; else if(count == 3) vertofs = '0 -1 -1';	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = '0 -1 -1'; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = '0 1 -1';	break;	// NORTH
				case 5:	if(count == 0) vertofs = '0 -1 -1'; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = '0 1 -1'; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
	
			vertofs = RotateVertOFS(vertofs, rotation);

			if(facecount == 5 && count == 0)
			{
				if(rotation == BLOCKROTATION_BW_E)
					texturecoords = '0.5 0 0';
				else
				if(rotation == BLOCKROTATION_BW_N)
					texturecoords = '1 0.5 0';
				else
				if(rotation == BLOCKROTATION_BW_W)
					texturecoords = '0.5 1 0';			
				else
				if(rotation == BLOCKROTATION_BW_S)
					texturecoords = '0 0.5 0';
			}
			else
			if(facecount == 5 && count == 2)
			{
				if(rotation == BLOCKROTATION_BW_E)
					texturecoords = '0.5 1 0';
				else
				if(rotation == BLOCKROTATION_BW_N)
					texturecoords = '0 0.5 0';
				else
				if(rotation == BLOCKROTATION_BW_W)
					texturecoords = '0.5 0 0';			
				else
				if(rotation == BLOCKROTATION_BW_S)
					texturecoords = '1 0.5 0';
			}
			else
			if(facecount == 2 && count == 2)
				texturecoords = '0.5 1 0';
			else
			if(facecount == 4 && count == 3)
				texturecoords = '0.5 1 0';			
			else
				texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

// WEDGE END
////////////