string GetTextureForTypeFace(float type, float facebit)
{
	string tex;
	
	switch(type)
	{
		case BLOCKTYPE_EDIT:			tex = "edit";				break;
		case BLOCKTYPE_DIRT:		if(facebit == FACE_TOP) tex = "dirt_top";		if(facebit == FACE_SIDE) tex = "dirt_side";			if(facebit == FACE_BOTTOM) tex = "dirt_bottom";			break;
		case BLOCKTYPE_BRICK:		if(facebit == FACE_TOP) tex = "city4_6_top";	if(facebit == FACE_SIDE) tex = "city4_6_side";		if(facebit == FACE_BOTTOM) tex = "city4_6_bottom";		break;
		case BLOCKTYPE_BLOCK:		if(facebit == FACE_TOP) tex = "bricka2_top";	if(facebit == FACE_SIDE) tex = "bricka2_side";		if(facebit == FACE_BOTTOM) tex = "bricka2_bottom";		break;
		case BLOCKTYPE_SUPPORT:		if(facebit == FACE_TOP) tex = "mmetal1_2_top";	if(facebit == FACE_SIDE) tex = "mmetal1_2_side";	if(facebit == FACE_BOTTOM) tex = "mmetal1_2_bottom";	break;
		case BLOCKTYPE_GORE:		if(facebit == FACE_TOP) tex = "exit02_2_top";	if(facebit == FACE_SIDE) tex = "exit02_2_side";		if(facebit == FACE_BOTTOM) tex = "exit02_2_bottom";		break;
		case BLOCKTYPE_STONE:		if(facebit == FACE_TOP) tex = "metal4_top";		if(facebit == FACE_SIDE) tex = "metal4_side";		if(facebit == FACE_BOTTOM) tex = "metal4_bottom";		break;
		case BLOCKTYPE_METAL:		if(facebit == FACE_TOP) tex = "metal5_3_top";	if(facebit == FACE_SIDE) tex = "metal5_3_side";		if(facebit == FACE_BOTTOM) tex = "metal5_3_bottom";		break;
		case BLOCKTYPE_METALB:		if(facebit == FACE_TOP) tex = "cop_top";		if(facebit == FACE_SIDE) tex = "cop_side";			if(facebit == FACE_BOTTOM) tex = "cop_bottom";			break;
		case BLOCKTYPE_METALC:		if(facebit == FACE_TOP) tex = "cop1_3_top";		if(facebit == FACE_SIDE) tex = "cop1_3_side";		if(facebit == FACE_BOTTOM) tex = "cop1_3_bottom";		break;
		case BLOCKTYPE_WOOD:		if(facebit == FACE_TOP) tex = "wizwood1_3_top";	if(facebit == FACE_SIDE) tex = "wizwood1_3_side";	if(facebit == FACE_BOTTOM) tex = "wizwood1_3_bottom";	break;
		case BLOCKTYPE_BLUESTONE:	if(facebit == FACE_TOP) tex = "bluestone_top";	if(facebit == FACE_SIDE) tex = "bluestone_side";	if(facebit == FACE_BOTTOM) tex = "bluestone_bottom";	break;
		case BLOCKTYPE_BLUEMETAL:	if(facebit == FACE_TOP) tex = "wiz1_1_top";		if(facebit == FACE_SIDE) tex = "wiz1_1_side";		if(facebit == FACE_BOTTOM) tex = "wiz1_1_bottom";		break;
		case BLOCKTYPE_DECMETAL:	if(facebit == FACE_TOP) tex = "m5_top";			if(facebit == FACE_SIDE) tex = "m5_side";			if(facebit == FACE_BOTTOM) tex = "m5_bottom";			break;
	}

/*	if(type > 0)
	switch(facebit)
	{
		case FACE_TOP:		tex = strcat(tex, "_top");		break;
		case FACE_SIDE:		tex = strcat(tex, "_side");		break;
		case FACE_BOTTOM:	tex = strcat(tex, "_bottom");	break;
	}*/

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
	rotation = ((rotation/4)-floor(rotation/4))*4;
	ang_y += rotation*90;
	ang_x*=-1;
	makevectors(ang);
	vertofs = v_forward*vlen(vertofs);
	return vertofs;
}

void SetFaceValues(vector cubicpos, vector vertofs, entity typegroup, int facebit, int facegroupsize, vector texturecoords, float facescale)
{
	int vertspercubic, trianglevertsspercubic;
	
	vector vertpos = cubicpos + vertofs*cubicradius*facescale;
	entity facegroup = GetFaceGroup(typegroup, facebit);

	texturecoords = texturecoords*facescale;

	if(!facegroup)
	{
		if(FACE_SIDE & facebit)
			facebit = FACE_SIDE;
		
		switch(facebit)
		{
			case FACE_TOP:		vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
			case FACE_SIDE:		vertspercubic = 16;	trianglevertsspercubic = 24;	break;	// 4 faces
			case FACE_BOTTOM:	vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
		//	default:			print("Warning: Missing facebit value.\n");			break;
		}
		
		facegroup = spawn();
		facegroup.verts = memalloc(sizeof(trisoup_simple_vert_t)*(facegroupsize*vertspercubic)); // vertexes
		facegroup.vertex_indexes = memalloc(sizeof(int)*(facegroupsize*trianglevertsspercubic)); // triangles
		facegroup.verts_staticrgb = memalloc(sizeof(vector)*(facegroupsize*vertspercubic)); // vertex static lighting/basergb

		// FIXME: Remove these lines upon FTE engine update. (This is a workaround.)
	//	vector *workaroundalloc = memalloc(sizeof(vector)*(facegroupsize*vertspercubic));	
	//	memfree(workaroundalloc);
		// END

		facegroup.faces = facebit;
		facegroup.texturename = GetTextureForTypeFace(typegroup.blocktype, facebit);
		FaceGroupChain_Add(typegroup, facegroup);
	}
	
	float facealpha = typegroup.alpha;
	if(!facealpha)
		facealpha = 1;
	
	facegroup.verts_staticrgb[facegroup.numvertexes] = typegroup.lightcolor;
	facegroup.verts[facegroup.numvertexes].xyz	= (vec3) {vertpos_x, vertpos_y, vertpos_z};	// vert coords
	facegroup.verts[facegroup.numvertexes].st	= (vec2) {texturecoords_x, texturecoords_y};	// texture coords
	facegroup.verts[facegroup.numvertexes].rgba	= (vec4) {typegroup.lightcolor_x, typegroup.lightcolor_y, typegroup.lightcolor_z, facealpha};	// color and alpha

	facegroup.numvertexes++;	
}

void SetVertexIndexes(int numvertsforface, entity typegroup, int facebit)
{
	entity facegroup = GetFaceGroup(typegroup, facebit);
	int numindexes = facegroup.numvertexindexes;
	
	// first polygon
	vector tri1_verts = '0 1 2' + '1 1 1'*facegroup.numtrisets;
	facegroup.vertex_indexes[numindexes] = tri1_verts_x;	numindexes++;
	facegroup.vertex_indexes[numindexes] = tri1_verts_y;	numindexes++;
	facegroup.vertex_indexes[numindexes] = tri1_verts_z;	numindexes++;
	
	// second polygon
	if(numvertsforface == 4)
	{
		vector tri2_verts = '2 1 3' + '1 1 1'*facegroup.numtrisets;
		facegroup.vertex_indexes[numindexes] = tri2_verts_x;	numindexes++;
		facegroup.vertex_indexes[numindexes] = tri2_verts_y;	numindexes++;
		facegroup.vertex_indexes[numindexes] = tri2_verts_z;	numindexes++;
	}
	
	facegroup.numtrisets += numvertsforface;
	facegroup.numvertexindexes = numindexes;	
	
	if(numindexes > 65535)
		print("WARNING: Too many vertexes on facegroup!\n");
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
		case BLOCKROTATION_E:		break;	// default
		case BLOCKROTATION_N:		cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_S, CULLBITS_E, CULLBITS_N, CULLBITS_W, CULLBITS_D);	break;
		case BLOCKROTATION_W:		cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_E, CULLBITS_N, CULLBITS_W, CULLBITS_S, CULLBITS_D);	break;
		case BLOCKROTATION_S:		cullbits = SwapCullBits(cullbits, CULLBITS_U, CULLBITS_N, CULLBITS_W, CULLBITS_S, CULLBITS_E, CULLBITS_D);	break;
	}
	
	return cullbits;
}

int GetNumVertsForFace(int facecount, int A, int B, int C, int D, int E, int F, optional int G)
{
	int numvertsforface;
	
	switch(facecount)
	{
		case 0:	numvertsforface = A;	break;
		case 1: numvertsforface = B;	break;
		case 2:	numvertsforface = C;	break;
		case 3:	numvertsforface = D;	break;
		case 4:	numvertsforface = E;	break;
		case 5:	numvertsforface = F;	break;
		case 6:	numvertsforface = G;	break;
	}
	
	return numvertsforface;
}

vector SetDefaultTextureCoordsForFace(int facecount, int count, vector vertofs)
{
	vector texturecoords;
	
	vector texvertofs = [rint(vertofs_x), rint(vertofs_y), 0];
	
	if(facecount == 0)
	{
		if(texvertofs == VECOFS_NW)	texturecoords = '0 0 0';	else
		if(texvertofs == VECOFS_NE)	texturecoords = '1 0 0';	else
		if(texvertofs == VECOFS_SW)	texturecoords = '0 1 0';	else
		if(texvertofs == VECOFS_SE)	texturecoords = '1 1 0';
	}
	else
	if(facecount == 5)
	{
		if(texvertofs == VECOFS_SW)	texturecoords = '0 0 0';	else
		if(texvertofs == VECOFS_SE)	texturecoords = '1 0 0';	else
		if(texvertofs == VECOFS_NW)	texturecoords = '0 1 0';	else
		if(texvertofs == VECOFS_NE)	texturecoords = '1 1 0';		
	}
	else
	if(facecount >= 1 && facecount <= 4)
	{
		if(count == 0)	texturecoords = '0 0 0';	else
		if(count == 1)	texturecoords = '1 0 0';	else
		if(count == 2)	texturecoords = '0 1 0';	else
		if(count == 3)	texturecoords = '1 1 0';
	}	
	
	return texturecoords;
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
	memfree(facegroup.verts_staticrgb);

	FaceGroupChain_Remove(typegroup, facegroup);
	StaticLitFaceGroupChain_Remove(facegroup);
	LitFaceGroupChain_Remove(facegroup);
	Remove(facegroup);
}

void RemoveTypeGroup(entity chunk, entity typegroup)
{
	while(typegroup.list_facegroupchain)
		RemoveFaceGroup(typegroup, typegroup.list_facegroupchain);

	TypeGroupChain_Remove(chunk, typegroup);	
	Remove(typegroup);
}

//int totalvertcount;
void DrawFaceGroup(entity facegroup)
{
	if(!facegroup)
		return;
//	totalvertcount+=facegroup.numvertexindexes;
	addtrisoup_simple(facegroup.texturename, 0, facegroup.verts, facegroup.vertex_indexes, facegroup.numvertexindexes);	
}