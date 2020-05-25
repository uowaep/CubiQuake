/////////////
// SLAB START

void BuildFaces_Slab_Universal(entity typegroup, int rotation, int cullbits, int subbits, vector cubicpos, int facegroupsize, int rotationtype, float facescale)
{
	int facecount = 0, facebit = 0, count = 0, rampface = 0;
	vector vertofs = '0 0 0', texturecoords = '0 0 0';

	cullbits = RotateCullBits(cullbits, rotation);
//	subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_E;	// ramp face needs to check these sides for culling
	
	if(rotationtype == 0)
		rampface = 0;
	else
	if(rotationtype == 1)
		rampface = 2;
	else
	if(rotationtype == 2)
		rampface = 5;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(SkipFace_Ramp(facecount, facebit, cullbits, subbits, rampface, -1))	// the ramp function works the same as a wedge tip would
			continue;

		for(count = 0; count < 4; count++)	// vertexes
		{
			switch(facecount)
			{
				case 0:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_USW; else if(count == 3) vertofs = VECOFS_USE;	break;	// TOP
				case 1:	if(count == 0) vertofs = VECOFS_UNW; else if(count == 1) vertofs = VECOFS_USW; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DSW;	break;	// WEST
				case 2:	if(count == 0) vertofs = VECOFS_USW; else if(count == 1) vertofs = VECOFS_USE; else if(count == 2) vertofs = VECOFS_DSW; else if(count == 3) vertofs = VECOFS_DSE;	break;	// SOUTH
				case 3:	if(count == 0) vertofs = VECOFS_USE; else if(count == 1) vertofs = VECOFS_UNE; else if(count == 2) vertofs = VECOFS_DSE; else if(count == 3) vertofs = VECOFS_DNE;	break;	// EAST
				case 4:	if(count == 0) vertofs = VECOFS_UNE; else if(count == 1) vertofs = VECOFS_UNW; else if(count == 2) vertofs = VECOFS_DNE; else if(count == 3) vertofs = VECOFS_DNW;	break;	// NORTH
				case 5:	if(count == 0) vertofs = VECOFS_DSW; else if(count == 1) vertofs = VECOFS_DSE; else if(count == 2) vertofs = VECOFS_DNW; else if(count == 3) vertofs = VECOFS_DNE;	break;	// BOTTOM
			}
			
			if(rotationtype == 0)			// default
			{
				if(vertofs_z == 1)
					vertofs_z = 0;
			}
			else
			if(rotationtype == 1)			// clockwise (x axis)
			{
				if(vertofs_y == -1)
					vertofs_y = 0;
			}
			else
			if(rotationtype == 2)			// upside down
			{
				if(vertofs_z == -1)
					vertofs_z = 0;
			}			
			
			vertofs = RotateVertOFS(vertofs, rotation);
			texturecoords = SetDefaultTextureCoordsForFace(facecount, count, vertofs);

			if(rotationtype == 0)			// default
			{
				if(facecount >= 1 && facecount <= 4)
				if(texturecoords_y == 0)
					texturecoords_y = 0.5;
			}
			else
			if(rotationtype == 1)			// clockwise (x axis)
			{
				if(facecount == 0)
				{
					if(rotation == BLOCKROTATION_CW_E)
					{
						if(count == 0)
							texturecoords = '0 0 0';
						else
						if(count == 1)
							texturecoords = '1 0 0';
						else
						if(count == 2)
							texturecoords = '0 0.5 0';
						else
						if(count == 3)
							texturecoords = '1 0.5 0';
					}
					else
					if(rotation == BLOCKROTATION_CW_N)
					{
						if(count == 0)
							texturecoords = '0 1 0';
						else
						if(count == 1)
							texturecoords = '0 0 0';
						else
						if(count == 2)
							texturecoords = '0.5 1 0';
						else
						if(count == 3)
							texturecoords = '0.5 0 0';
					}
					else					
					if(rotation == BLOCKROTATION_CW_W)
					{
						if(count == 0)
							texturecoords = '1 1 0';
						else
						if(count == 1)
							texturecoords = '0 1 0';
						else
						if(count == 2)
							texturecoords = '1 0.5 0';
						else
						if(count == 3)
							texturecoords = '0 0.5 0';
					}
					else				
					if(rotation == BLOCKROTATION_CW_S)
					{
						if(count == 0)
							texturecoords = '1 0 0';
						else
						if(count == 1)
							texturecoords = '1 1 0';
						else
						if(count == 2)
							texturecoords = '0.5 0 0';
						else
						if(count == 3)
							texturecoords = '0.5 1 0';
					}
				}
				else
				if(facecount == 5)
				{
					if(rotation == BLOCKROTATION_CW_E)
					{
						if(count == 0)
							texturecoords = '0 0.5 0';
						else
						if(count == 1)
							texturecoords = '1 0.5 0';
						else
						if(count == 2)
							texturecoords = '0 1 0';
						else
						if(count == 3)
							texturecoords = '1 1 0';	
					}
					else
					if(rotation == BLOCKROTATION_CW_N)
					{
						if(count == 2)
							texturecoords = '0 0 0';
						else
						if(count == 3)
							texturecoords = '0 1 0';
						else
						if(count == 0)
							texturecoords = '0.5 0 0';
						else
						if(count == 1)
							texturecoords = '0.5 1 0';
					}
					else					
					if(rotation == BLOCKROTATION_CW_W)
					{
						if(count == 0)
							texturecoords = '1 0.5 0';
						else
						if(count == 1)
							texturecoords = '0 0.5 0';
						else
						if(count == 2)
							texturecoords = '1 0 0';
						else
						if(count == 3)
							texturecoords = '0 0 0';
					}
					else				
					if(rotation == BLOCKROTATION_CW_S)
					{
						if(count == 0)
							texturecoords = '0.5 1 0';
						else
						if(count == 1)
							texturecoords = '0.5 0 0';
						else
						if(count == 2)
							texturecoords = '1 1 0';
						else
						if(count == 3)
							texturecoords = '1 0 0';
					}
				}
				else					
				if(facecount == 1)
				{
					if(texturecoords_x == 1)
						texturecoords_x = 0.5;
				}
				else
				if(facecount == 3)
				{
					if(texturecoords_x == 0)
						texturecoords_x = 0.5;
				}
			}
			else
			if(rotationtype == 2)			// upside down
			{
				if(facecount >= 1 && facecount <= 4)
				if(texturecoords_y == 1)
					texturecoords_y = 0.5;
			}
		
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(4, typegroup, facebit);
	}	
}

void BuildFaces_Slab(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	BuildFaces_Slab_Universal(typegroup, rotation, cullbits, CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_E, cubicpos, facegroupsize, 0, facescale);
}

void BuildFaces_Slab_CW(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	BuildFaces_Slab_Universal(typegroup, rotation, cullbits, CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S | CULLBITS_E, cubicpos, facegroupsize, 1, facescale);
}

void BuildFaces_Slab_UD(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	BuildFaces_Slab_Universal(typegroup, rotation, cullbits, CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S | CULLBITS_E, cubicpos, facegroupsize, 2, facescale);
}

// SLAB END
///////////