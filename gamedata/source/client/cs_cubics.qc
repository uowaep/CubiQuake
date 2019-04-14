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

void BuildChunkFaces(entity chunk)
{
	entity typegroup, facegroup;
	int cullbits, facebit, numverts, numindexes, count, cubiccount, facecount, vertspercubic, trianglespercubic, numchunkcubics;
	vector cubicpos, vertofs, vertpos, texturecoords, tri1_verts, tri2_verts;
	float blockscale;
	vector rgb = '0 0 0';
	float cubicalpha = 0;
	int builtcount, type;
	
	if(chunk.numvisiblecubics < 0)
	{
		numchunkcubics = 1;
		blockscale = 6;
	}
	else
	{
		numchunkcubics = chunk.numvisiblecubics;
		blockscale = 1;
	}
	
	for(cubiccount = 0; builtcount < numchunkcubics; cubiccount++)
	{
		type = chunk.cubic_blocktype[cubiccount];
		
		if(!type)
			continue;
		
		typegroup = GetTypeGroup(chunk, type);
		cullbits = chunk.cubic_cullbits[cubiccount];
		cubicpos = chunk.origin + GetCubicOffset(cubiccount);
		
		for(facecount = 0; facecount < 6; facecount++)
		{
			facebit = bitshift(1, facecount);

			if(cullbits)
			if(cullbits & facebit)
				continue;

		//	if(buildfacebits)
		//	if(!(buildfacebits & facebit))
		//		continue;
			
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
				
				vertpos = cubicpos + vertofs*cubicradius*blockscale;
			
				facegroup = GetFaceGroup(typegroup, facebit);
			
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
					facegroup.verts = memalloc(sizeof(trisoup_simple_vert_t)*(numchunkcubics*vertspercubic)); // vertexes
					facegroup.vertex_indexes = memalloc(sizeof(int)*(numchunkcubics*trianglespercubic)); // triangles
					facegroup.texturename = GetTextureForTypeFace(typegroup.blocktype, facebit);
					FaceGroupChain_Add(typegroup, facegroup);
				}
				
				numverts = facegroup.numvertexes;
			//	facegroup.verts[numverts].xyz[0] = vertpos_x;	facegroup.verts[numverts].xyz[1] = vertpos_y;	facegroup.verts[numverts].xyz[2] = vertpos_z;	// vert coords
			//	facegroup.verts[numverts].st[0] = texturecoords_x; facegroup.verts[numverts].st[1] = texturecoords_y;	// texture coords
				
				facegroup.verts[numverts].xyz	= (vec3) {vertpos_x, vertpos_y, vertpos_z};	// vert coords
				facegroup.verts[numverts].st	= (vec2) {texturecoords_x, texturecoords_y};	// texture coords
				facegroup.verts[numverts].rgba	= (vec4) {rgb_x, rgb_y, rgb_z, cubicalpha};	// color and alpha

				facegroup.numvertexes++;
			}
		}
		
		for(facecount = 0; facecount < 6; facecount++)	// triangles
		{
			facebit = bitshift(1, facecount);
			
			if(cullbits)
			if(cullbits & facebit)
				continue;
			
		//	if(!(buildfacebits & facebit))
		//		continue;
			
			facegroup = GetFaceGroup(typegroup, facebit);
			
			tri1_verts = '0 1 2' + '1 1 1'*facegroup.numtrisets;
			tri2_verts = '2 1 3' + '1 1 1'*facegroup.numtrisets;
			
			numindexes = facegroup.numvertexindexes;
			facegroup.vertex_indexes[numindexes] = tri1_verts_x;	numindexes++;
			facegroup.vertex_indexes[numindexes] = tri1_verts_y;	numindexes++;
			facegroup.vertex_indexes[numindexes] = tri1_verts_z;	numindexes++;
			facegroup.vertex_indexes[numindexes] = tri2_verts_x;	numindexes++;
			facegroup.vertex_indexes[numindexes] = tri2_verts_y;	numindexes++;
			facegroup.vertex_indexes[numindexes] = tri2_verts_z;	numindexes++;
			
			facegroup.numtrisets += 4;
			facegroup.numvertexindexes = numindexes;
		}
		
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
		self.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
		
		for(float count = 0; count < self.numvisiblecubics; count++)
		{
			memslot = readshort();
			type = readbyte();
			self.cubic_blocktype[memslot] = type;
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
//	R_BeginPolygon(facegroup.texturename, 0, false);
	addtrisoup_simple(facegroup.texturename, 0, facegroup.verts, facegroup.vertex_indexes, facegroup.numvertexindexes);
//	R_EndPolygon();	
}

void DrawChunks()
{
	entity typegroup, facegroup;
	
	for(entity e = list_chunkchain; e; e = e.chunkchain)
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(facegroup);
}