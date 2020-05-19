/////////////
// CUBE START

void BuildFaces_Cube(entity typegroup, int cullbits, vector cubicpos, int facegroupsize, float facescale)
{
	int facecount, facebit, count;
	vector vertofs, texturecoords;

	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(cullbits)
		if(cullbits & facebit)
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
			
			switch(count)
			{
				case 0:	texturecoords = '0 0 0';	break;
				case 1:	texturecoords = '1 0 0';	break;
				case 2:	texturecoords = '0 1 0';	break;
				case 3:	texturecoords = '1 1 0';	break;
			}
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords, facescale);
		}

		SetVertexIndexes(4, typegroup, facebit);
	}	
}

// CUBE END
///////////