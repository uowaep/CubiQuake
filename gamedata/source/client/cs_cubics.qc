.*trisoup_simple_vert_t 	verts;
.*int 	vertex_indexes;
.int	numvertexes;
.int	numtrisets;
.string	texturename;
.int	blocktype;
.int	faces;
int		client_initialized;

int FACE_TOP	= 1;
int	FACE_SIDE	= 30; // FACE_SIDE is multiple bits containing the WEST, SOUTH, EAST. and NORTH bits. (2+4+8+16) These correspond with the CULLBITS_ bits.
int	FACE_BOTTOM	= 32;

string GetTextureForTypeFace(float type, float facebit)
{
	string tex;
	
	switch(type)
	{
		case BLOCKTYPE_DIRT:	tex = "dirt";	break;
		case BLOCKTYPE_BRICK:	tex = "brick";	break;
		case BLOCKTYPE_BLOCK:	tex = "block";	break;
	}
	
//	tex = strcat("cubics/", tex);
	
	switch(facebit)
	{
		case FACE_TOP:		tex = strcat(tex, "_top");		break;
		case FACE_SIDE:		tex = strcat(tex, "_side");		break;
		case FACE_BOTTOM:	tex = strcat(tex, "_bottom");	break;
	}

	return tex;
}

entity GetFaceGroup(entity typegroup, int facebit)
{
	entity facegroup;
	for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
		if(facegroup.faces & facebit)
			break;
	
	return facegroup;
}

entity GetTypeGroup(entity chunk, int type)
{
	entity typegroup;
	for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
		if(typegroup.blocktype == type)
			break;
		
	return typegroup;
}

vector RotateVertOFS(vector vertofs, int rotation)
{
	vector ang = vectoangles(vertofs);

	if(rotation >= BLOCKROTATION_UPSIDEDOWN_E)
		rotation -= BLOCKROTATION_UPSIDEDOWN_E;
	else
	if(rotation >= BLOCKROTATION_SIDE_E)
		rotation -= BLOCKROTATION_SIDE_E;

	ang_y += rotation*90;
	
	ang_x*=-1;
	makevectors(ang);
	vertofs = v_forward*vlen(vertofs);
	return vertofs;
}

void SetFaceValues(vector cubicpos, vector vertofs, entity typegroup, int facebit, int facegroupsize, vector texturecoords)
{
	int vertspercubic, trianglespercubic;
	
	vector vertpos = cubicpos + vertofs*cubicradius;
	entity facegroup = GetFaceGroup(typegroup, facebit);

	if(!facegroup)
	{
		facegroup = spawn();
		if(FACE_SIDE & facebit)
			facebit = FACE_SIDE;
		
		switch(facebit)
		{
			case FACE_TOP:		vertspercubic = 4;	trianglespercubic = 6;	break;
			case FACE_SIDE:		vertspercubic = 16;	trianglespercubic = 24;	break;
			case FACE_BOTTOM:	vertspercubic = 4;	trianglespercubic = 6;	break;
		}
		
		facegroup.faces = facebit;
		facegroup.verts = memalloc(sizeof(trisoup_simple_vert_t)*(facegroupsize*vertspercubic)); // vertexes
		facegroup.vertex_indexes = memalloc(sizeof(int)*(facegroupsize*trianglespercubic)); // triangles
		facegroup.texturename = GetTextureForTypeFace(typegroup.blocktype, facebit);
		FaceGroupChain_Add(typegroup, facegroup);
	}
	
	facegroup.verts[facegroup.numvertexes].xyz	= (vec3) {vertpos_x, vertpos_y, vertpos_z};	// vert coords
	facegroup.verts[facegroup.numvertexes].st	= (vec2) {texturecoords_x, texturecoords_y};	// texture coords
	facegroup.verts[facegroup.numvertexes].rgba	= (vec4) {1, 1, 1, 1};	// color and alpha

	facegroup.numvertexes++;	
}

void SetVertexIndexes(int numvertsforface, entity typegroup, int facebit)
{
	entity facegroup = GetFaceGroup(typegroup, facebit);
	int numindexes = facegroup.numvertexindexes;
	
	vector tri1_verts = '0 1 2' + '1 1 1'*facegroup.numtrisets;
	facegroup.vertex_indexes[numindexes] = tri1_verts_x;	numindexes++;
	facegroup.vertex_indexes[numindexes] = tri1_verts_y;	numindexes++;
	facegroup.vertex_indexes[numindexes] = tri1_verts_z;	numindexes++;
	
	if(numvertsforface == 4)
	{
		vector tri2_verts = '2 1 3' + '1 1 1'*facegroup.numtrisets;
		facegroup.vertex_indexes[numindexes] = tri2_verts_x;	numindexes++;
		facegroup.vertex_indexes[numindexes] = tri2_verts_y;	numindexes++;
		facegroup.vertex_indexes[numindexes] = tri2_verts_z;	numindexes++;
	}
	
	facegroup.numtrisets += numvertsforface;
	facegroup.numvertexindexes = numindexes;	
}

int SwapCullBits(int cullbits, int cb_u, int cb_w, int cb_s, int cb_e, int cb_n, int cb_d)
{
	return	(((cullbits & cb_u)>0)*CULLBITS_U) |
			(((cullbits & cb_w)>0)*CULLBITS_W) |
			(((cullbits & cb_s)>0)*CULLBITS_S) |
			(((cullbits & cb_e)>0)*CULLBITS_E) |
			(((cullbits & cb_n)>0)*CULLBITS_N) |
			(((cullbits & cb_d)>0)*CULLBITS_D);
}

int RotateCullBits(int cullbits, int rotation)
{
	rotation = ((rotation/4)-floor(rotation/4))*4;
	
	switch(rotation)
	{
		case BLOCKROTATION_E:				break;	// default
		case BLOCKROTATION_N:				cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_S, CULLBITS_E, CULLBITS_N, CULLBITS_W, CULLBITS_D);	break;
		case BLOCKROTATION_W:				cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_E, CULLBITS_N, CULLBITS_W, CULLBITS_S, CULLBITS_D);	break;
		case BLOCKROTATION_S:				cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_N, CULLBITS_W, CULLBITS_S, CULLBITS_E, CULLBITS_D);	break;
		
		case BLOCKROTATION_SIDE_E:			cullbits = SwapCullBits(cullbits, CULLBITS_N, CULLBITS_W, CULLBITS_U, CULLBITS_E, CULLBITS_D, CULLBITS_S);	break;
		case BLOCKROTATION_SIDE_N:			cullbits = SwapCullBits(cullbits, CULLBITS_W, CULLBITS_S, CULLBITS_U, CULLBITS_N, CULLBITS_D, CULLBITS_E);	break;
		case BLOCKROTATION_SIDE_W:			cullbits = SwapCullBits(cullbits, CULLBITS_S, CULLBITS_E, CULLBITS_U, CULLBITS_W, CULLBITS_D, CULLBITS_N);	break;
		case BLOCKROTATION_SIDE_S:			cullbits = SwapCullBits(cullbits, CULLBITS_E, CULLBITS_N, CULLBITS_U, CULLBITS_S, CULLBITS_D, CULLBITS_W);	break;
		
		case BLOCKROTATION_UPSIDEDOWN_E:	cullbits = SwapCullBits(cullbits, CULLBITS_D, CULLBITS_W, CULLBITS_N, CULLBITS_E, CULLBITS_S, CULLBITS_U);	break;
		case BLOCKROTATION_UPSIDEDOWN_N:	cullbits = SwapCullBits(cullbits, CULLBITS_D, CULLBITS_S, CULLBITS_W, CULLBITS_N, CULLBITS_E, CULLBITS_U);	break;
		case BLOCKROTATION_UPSIDEDOWN_W:	cullbits = SwapCullBits(cullbits, CULLBITS_D, CULLBITS_E, CULLBITS_S, CULLBITS_W, CULLBITS_N, CULLBITS_U);	break;
		case BLOCKROTATION_UPSIDEDOWN_S:	cullbits = SwapCullBits(cullbits, CULLBITS_D, CULLBITS_N, CULLBITS_E, CULLBITS_S, CULLBITS_W, CULLBITS_U);	break;
	}
	
	return cullbits;
}

/////////////
// CUBE START

void BuildFaces_Cube(entity typegroup, int cullbits, vector cubicpos, int facegroupsize)
{
	int facecount, facebit, count;
	vector vertofs, texturecoords;
	vector rgb = '0 0 0';
	
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
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords);
		}

		SetVertexIndexes(4, typegroup, facebit);
	}	
}

// CUBE END
///////////

/////////////
// RAMP START

void BuildFaces_Ramp(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texvertofs, texturecoords;
	vector rgb = '0 0 0';
	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_N | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(facecount == 1) // skip west face
			continue;

		if(facecount == 0)	// check multiple culls to not draw top face
		{
			if((cullbits & subbits) == subbits)
				continue;
		}
		else		
		if(cullbits & facebit)
			continue;

		switch(facecount)
		{
			case 0:	numvertsforface = 4;	break;
			case 2:	numvertsforface = 3;	break;
			case 3:	numvertsforface = 4;	break;
			case 4:	numvertsforface = 3;	break;
			case 5:	numvertsforface = 4;	break;
		}
		
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

			if(facecount == 0 || facecount == 5)
			{
				texvertofs = [rint(vertofs_x), rint(vertofs_y), 0];
				if(texvertofs == VECOFS_NW)	texturecoords = '0 0 0';	else
				if(texvertofs == VECOFS_NE)	texturecoords = '1 0 0';	else
				if(texvertofs == VECOFS_SW)	texturecoords = '0 1 0';	else
				if(texvertofs == VECOFS_SE)	texturecoords = '1 1 0';
			}
			else
			if(facecount == 3)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '0 1 0';	else
				if(count == 3)	texturecoords = '1 1 0';
			}
			else
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
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Ramp_Sideways(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texvertofs, texturecoords;
	vector rgb = '0 0 0';
	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_U | CULLBITS_W | CULLBITS_D | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(facecount == 1) // skip west face
			continue;

		if(facecount == 2)	// check multiple culls to not draw south face
		{
			if((cullbits & subbits) == subbits)
				continue;
		}
		else		
		if(cullbits & facebit)
			continue;

		switch(facecount)
		{
			case 0:	numvertsforface = 3;	break;	// up
			case 2:	numvertsforface = 4;	break;	// south
			case 3:	numvertsforface = 4;	break;	// east
			case 4:	numvertsforface = 4;	break;	// north
			case 5:	numvertsforface = 3;	break;	// down
		}
		
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

			if(facecount == 0 || facecount == 5)
			{
				texvertofs = [rint(vertofs_x), rint(vertofs_y), 0];
				if(texvertofs == VECOFS_NW)	texturecoords = '0 0 0';	else
				if(texvertofs == VECOFS_NE)	texturecoords = '1 0 0';	else
				if(texvertofs == VECOFS_SW)	texturecoords = '0 1 0';	else
				if(texvertofs == VECOFS_SE)	texturecoords = '1 1 0';
			}
			else
			if(facecount == 2 || facecount == 3 || facecount == 4)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '0 1 0';	else
				if(count == 3)	texturecoords = '1 1 0';
			}
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

void BuildFaces_Ramp_UpsideDown(entity typegroup, int rotation, int cullbits, vector cubicpos, int facegroupsize)
{
	int facecount, facebit, count, numvertsforface;
	vector vertofs, texvertofs, texturecoords;
	vector rgb = '0 0 0';
	cullbits = RotateCullBits(cullbits, rotation);
	int subbits = CULLBITS_D | CULLBITS_W | CULLBITS_N | CULLBITS_S;
	
	for(facecount = 0; facecount < 6; facecount++)
	{
		facebit = bitshift(1, facecount);

		if(facecount == 1) // skip west face
			continue;

		if(facecount == 5)	// check multiple culls to not draw bottom face
		{
			if((cullbits & subbits) == subbits)
				continue;
		}
		else		
		if(cullbits & facebit)
			continue;

		switch(facecount)
		{
			case 0:	numvertsforface = 4;	break;
			case 2:	numvertsforface = 3;	break;
			case 3:	numvertsforface = 4;	break;
			case 4:	numvertsforface = 3;	break;
			case 5:	numvertsforface = 4;	break;
		}
		
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

			if(facecount == 0 || facecount == 5)
			{
				texvertofs = [rint(vertofs_x), rint(vertofs_y), 0];
				if(texvertofs == VECOFS_NW)	texturecoords = '0 0 0';	else
				if(texvertofs == VECOFS_NE)	texturecoords = '1 0 0';	else
				if(texvertofs == VECOFS_SW)	texturecoords = '0 1 0';	else
				if(texvertofs == VECOFS_SE)	texturecoords = '1 1 0';
			}
			else
			if(facecount == 3)
			{
				if(count == 0)	texturecoords = '0 0 0';	else
				if(count == 1)	texturecoords = '1 0 0';	else
				if(count == 2)	texturecoords = '0 1 0';	else
				if(count == 3)	texturecoords = '1 1 0';
			}
			else
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
			
			SetFaceValues(cubicpos, vertofs, typegroup, facebit, facegroupsize, texturecoords);
		}

		SetVertexIndexes(numvertsforface, typegroup, facebit);
	}	
}

// RAMP END
///////////

void BuildFacesForShape(entity typegroup, int blockshape, int blockrotation, int cullbits, vector cubicposition, int numchunkcubics)
{
	switch(blockshape)
	{
		case BLOCKSHAPE_CUBE:	BuildFaces_Cube(typegroup, cullbits, cubicposition, numchunkcubics);	break;
		case BLOCKSHAPE_RAMP:	if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Ramp(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
								if(blockrotation <= BLOCKROTATION_SIDE_S)		BuildFaces_Ramp_Sideways(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
								if(blockrotation <= BLOCKROTATION_UPSIDEDOWN_S)	BuildFaces_Ramp_UpsideDown(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	break;
	}
}

void BuildChunkFaces(entity chunk)
{
	entity typegroup;
	int blockshape, blockrotation, cullbits, cubiccount, numchunkcubics;
	vector cubicposition;
	int builtcount, type;

	numchunkcubics = chunk.numvisiblecubics;

	for(cubiccount = 0; builtcount < numchunkcubics; cubiccount++)
	{
		type = chunk.cubic_blocktype[cubiccount];
		
		if(!type)
			continue;
		
		typegroup = GetTypeGroup(chunk, type);
		blockshape = chunk.cubic_blockshape[cubiccount];
		blockrotation = chunk.cubic_blockrotation[cubiccount];
		cullbits = chunk.cubic_cullbits[cubiccount];
		cubicposition = chunk.origin + GetCubicOffset(cubiccount);
		
		BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, numchunkcubics);
		
		builtcount++;
	}
}

void CreateTypeGroup(entity chunk, float type)
{
	entity typegroup = spawn();
	typegroup.blocktype = type;
	TypeGroupChain_Add(chunk, typegroup);	
}

void RemoveFaceGroup(entity typegroup, entity facegroup)
{
	memfree(facegroup.verts);
	memfree(facegroup.vertex_indexes);
	FaceGroupChain_Remove(typegroup, facegroup);
	Remove(facegroup);
}

void RemoveTypeGroup(entity chunk, entity typegroup)
{
	entity nexte;
	
	for(entity facegroup = typegroup.list_facegroupchain; facegroup; facegroup = nexte)
	{
		nexte = facegroup.facegroupchain;
		RemoveFaceGroup(typegroup, facegroup);
	}

	TypeGroupChain_Remove(chunk, typegroup);	
	Remove(typegroup);
}

void BuildLowDetailChunkFaces(entity chunk)
{
	entity typegroup;
	
	for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
		if(typegroup.blocktype == BLOCKTYPE_DIRT)
			break;
		
	if(!typegroup)
		CreateTypeGroup(chunk, BLOCKTYPE_DIRT);
	
	BuildChunkFaces(chunk);
}

void ClearChunkValues(entity chunk)
{
	entity nexte;

	memfree(chunk.cubic_blocktype);
	memfree(chunk.cubic_blockshape);
	memfree(chunk.cubic_blockrotation);
	memfree(chunk.cubic_cullbits);
	
	for(entity typegroup = chunk.list_typegroupchain; typegroup; typegroup = nexte)
	{
		nexte = typegroup.typegroupchain;
		RemoveTypeGroup(chunk, typegroup);
	}	
}

void UpdateChunk()
{
	float sendflags = readlong();
	int i, memslot, type;
	vector org;
	entity typegroup;
	
	if(sendflags & SFL_ISNEW)
	{
		if(!client_initialized)
		{
			worldsize = readlong();
			InitGameVariables();
			client_initialized = TRUE;
		}
		
		i = readlong();
		org = GetChunkOrigin(i);
		self.flags = FL_FINDABLE_NONSOLID;
		setorigin(self, org);
		self.enttype = ENT_CHUNK;
		
		ChunkChain_Add(self);
	}

	if(sendflags & SFL_BUILD)
	{
		ClearChunkValues(self);
		
		self.numvisiblecubics = readshort();
		
		self.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
		self.cubic_blockshape = memalloc(sizeof(int)*pow(chunksize, 3));
		self.cubic_blockrotation = memalloc(sizeof(int)*pow(chunksize, 3));		
		self.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
		
		for(float count = 0; count < self.numvisiblecubics; count++)
		{
			memslot = readshort();
			type = readbyte();
			self.cubic_blocktype[memslot] = type;
			self.cubic_blockshape[memslot] = readbyte();
			self.cubic_blockrotation[memslot] = readbyte();
			self.cubic_cullbits[memslot] = readbyte();
			
			for(typegroup = self.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
				if(typegroup.blocktype == type)
					break;
				
			if(!typegroup)
				CreateTypeGroup(self, type);
		}
		
	//	if(self.numvisiblecubics > 0) // shouldn't be zero if this ent shared...
			BuildChunkFaces(self);
	/*	else
		if(self.numvisiblecubics < 0)
		{
			memslot = GetCubicRef('0 0 0');
			self.cubic_blocktype[memslot] = BLOCKTYPE_DIRT;
			BuildLowDetailChunkFaces(self);
		}*/
	}
}

void DrawFaceGroup(entity facegroup)
{
	addtrisoup_simple(facegroup.texturename, 0, facegroup.verts, facegroup.vertex_indexes, facegroup.numvertexindexes);
}

void DrawChunks()
{
	entity typegroup, facegroup;
	
	for(entity e = list_chunkchain; e; e = e.chunkchain)
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(facegroup);
}