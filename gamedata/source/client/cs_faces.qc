string GetTextureForTypeFace(float type, float facebit)
{
	switch(type)
	{
		case BLOCKTYPE_EDIT:		return "edit";				break;

//		case BLOCKTYPE_DMG_25:		return "dmg_20";			break;
//		case BLOCKTYPE_DMG_50:		return "dmg_50";			break;
//		case BLOCKTYPE_DMG_75:		return "dmg_80";			break;
		
		case BLOCKTYPE_DMG_10:		return "dmg_10";			break;
		case BLOCKTYPE_DMG_20:		return "dmg_20";			break;
		case BLOCKTYPE_DMG_30:		return "dmg_30";			break;
		case BLOCKTYPE_DMG_40:		return "dmg_40";			break;
		case BLOCKTYPE_DMG_50:		return "dmg_50";			break;
		case BLOCKTYPE_DMG_60:		return "dmg_60";			break;
		case BLOCKTYPE_DMG_70:		return "dmg_70";			break;
		case BLOCKTYPE_DMG_80:		return "dmg_80";			break;
		case BLOCKTYPE_DMG_90:		return "dmg_90";			break;
		
		case BLOCKTYPE_DIRT:		if(facebit == FACE_TOP) return "dirt_top";		if(FACE_SIDE & facebit) return "dirt_side";		if(facebit == FACE_BOTTOM) return "dirt_bottom";		break;
		case BLOCKTYPE_BRICK:		if(facebit == FACE_TOP) return "city4_6_top";	if(FACE_SIDE & facebit) return "city4_6_side";		if(facebit == FACE_BOTTOM) return "city4_6_bottom";		break;
		case BLOCKTYPE_BLOCK:		if(facebit == FACE_TOP) return "bricka2_top";	if(FACE_SIDE & facebit) return "bricka2_side";		if(facebit == FACE_BOTTOM) return "bricka2_bottom";		break;
		case BLOCKTYPE_SUPPORT:		if(facebit == FACE_TOP) return "mmetal1_2_top";	if(FACE_SIDE & facebit) return "mmetal1_2_side";	if(facebit == FACE_BOTTOM) return "mmetal1_2_bottom";	break;
		case BLOCKTYPE_GORE:		if(facebit == FACE_TOP) return "exit02_2_top";	if(FACE_SIDE & facebit) return "exit02_2_side";	if(facebit == FACE_BOTTOM) return "exit02_2_bottom";	break;
		case BLOCKTYPE_STONE:		if(facebit == FACE_TOP) return "metal4_top";	if(FACE_SIDE & facebit) return "metal4_side";		if(facebit == FACE_BOTTOM) return "metal4_bottom";		break;
		case BLOCKTYPE_METAL:		if(facebit == FACE_TOP) return "metal5_3_top";	if(FACE_SIDE & facebit) return "metal5_3_side";	if(facebit == FACE_BOTTOM) return "metal5_3_bottom";	break;
		case BLOCKTYPE_METALB:		if(facebit == FACE_TOP) return "cop_top";		if(FACE_SIDE & facebit) return "cop_side";			if(facebit == FACE_BOTTOM) return "cop_bottom";			break;
		case BLOCKTYPE_METALC:		if(facebit == FACE_TOP) return "cop1_3_top";	if(FACE_SIDE & facebit) return "cop1_3_side";		if(facebit == FACE_BOTTOM) return "cop1_3_bottom";		break;
		case BLOCKTYPE_WOOD:		if(facebit == FACE_TOP) return "wizwood1_3_top";if(FACE_SIDE & facebit) return "wizwood1_3_side";	if(facebit == FACE_BOTTOM) return "wizwood1_3_bottom";	break;
		case BLOCKTYPE_BLUESTONE:	if(facebit == FACE_TOP) return "bluestone_top";	if(FACE_SIDE & facebit) return "bluestone_side";	if(facebit == FACE_BOTTOM) return "bluestone_bottom";	break;
		case BLOCKTYPE_BLUEMETAL:	if(facebit == FACE_TOP) return "wiz1_1_top";	if(FACE_SIDE & facebit) return "wiz1_1_side";		if(facebit == FACE_BOTTOM) return "wiz1_1_bottom";		break;
		case BLOCKTYPE_DECMETAL:	if(facebit == FACE_TOP) return "m5_top";		if(FACE_SIDE & facebit) return "m5_side";			if(facebit == FACE_BOTTOM) return "m5_bottom";			break;
	}

/*	if(type > 0)
	switch(facebit)
	{
		case FACE_TOP:		tex = strcat(tex, "_top");		break;
		case FACE_SIDE:		tex = strcat(tex, "_side");		break;
		case FACE_BOTTOM:	tex = strcat(tex, "_bottom");	break;
	}*/

	return __NULL__;
}

entity GetFaceGroup(entity typegroup, int facebit)
{
	entity facegroup;
	for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
		if((facebit && (facegroup.faces & facebit)))
			break;
	
	return facegroup;
}

entity GetTypeGroup(entity chunk, int type)
{
	entity typegroup;
	for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
	{
		if(!typegroup.markedforremoval)
		if(typegroup.blocktype == type)
			break;
	}
		
	return typegroup;
}

vector RotateVertOFS(vector vertofs, int rotation)
{
	vector ang = vectoangles(vertofs);
	rotation = ((rotation/4)-floor(rotation/4))*4;
	ang_y = ang_y + rotation*90;
	ang_x = ang_x*-1;
	makevectors(ang);
	vertofs = v_forward*vlen(vertofs);
	return vertofs;
}

int RotateFaceBits(int facebit, int rotation)
{
	if(!rotation)
		return facebit;

	if(facebit == FACE_TOP || facebit == FACE_BOTTOM)
		return facebit;
	
	rotation = rotation - floor(rotation/4)*4;	// is floor slow?
	
	if(!rotation)
		return facebit;

	for(int count = 0; count < rotation; count++)
	{
	//	print(ftos(facebit), " : ", ftos(bitshift(facebit, -1)), "\n");
		
		facebit = bitshift(facebit, 1);
		if(facebit > FACE_NORTH)
			facebit = FACE_WEST;
	}
	
	return facebit;
}

entity GetGhostFaceGroup(int facegroupsize)
{
	entity closestallocationsizefacegroup = __NULL__;
	int vertmaxdiff = 0, indexmaxdiff = 0;
	
	int vertsize = facegroupsize*4;
	int	indexsize = facegroupsize*6;
	
	for(entity e = list_ghostfacegroupchain; e; e = e.ghostfacegroupchain)
	{
		if(e.allocsize_verts >= vertsize)
		if(e.allocsize_indexes >= indexsize)
		{
			if(e.allocsize_verts-vertsize < vertmaxdiff || !closestallocationsizefacegroup)
			if(e.allocsize_indexes-indexsize < indexmaxdiff || !closestallocationsizefacegroup)
			{
				closestallocationsizefacegroup = e;
				vertmaxdiff = e.allocsize_verts-vertsize;
				indexmaxdiff = e.allocsize_indexes-indexsize;
				
				if(vertmaxdiff == 0 || indexmaxdiff == 0)	// close enough
					break;
			}
		}
	}
	
	if(closestallocationsizefacegroup)
		GhostFaceGroupChain_Remove(closestallocationsizefacegroup);
	
	return closestallocationsizefacegroup;
}

// i don't know if there's a proper term for this. i just call it ghosting.
int GhostFaceGroup(entity typegroup, entity facegroup)
{
	// maybe return FALSE here if the facegroup is gigantic and has been around for a while?
	
//	memfill8(facegroup.verts, 0, sizeof(trisoup_simple_vert_t)*facegroup.allocsize_verts); // do i need to do anything with this? guess not.
//	memfill8(facegroup.vertex_indexes, 0, sizeof(int)*facegroup.allocsize_indexes); // i could probably leave these alone too since i have the number as a variable... haha i don't even remember
//	memfill8(facegroup.verts_ambientrgb, 0, sizeof(int)*facegroup.allocsize_verts);	
//	memfill8(facegroup.verts_staticrgb, 0, sizeof(int)*facegroup.allocsize_verts);

	facegroup.numvertexindexes = 0;
	facegroup.numvertexes = 0;
	facegroup.numtrisets = 0;
	facegroup.faces = 0;
	facegroup.texturename = __NULL__;
	facegroup.typegroupent = __NULL__;

	DrawFaceGroupChain_Remove(facegroup);
	DrawDamageFaceGroupChain_Remove(facegroup);
	FaceGroupChain_Remove(typegroup, facegroup);
	StaticLitFaceGroupChain_Remove(facegroup);
	LitFaceGroupChain_Remove(facegroup);
	
	GhostFaceGroupChain_Add(facegroup);
	
	return TRUE;
}

void SetFaceValues(vector cubicpos, vector vertofs, entity typegroup, int facebit, int facegroupsize, vector texturecoords, float facescale, int listid)
{
	int vertspercubic = 0, trianglevertsspercubic = 0;
	vector vertpos = cubicpos + vertofs*cubicradius*facescale;
	entity facegroup = GetFaceGroup(typegroup, facebit);
	texturecoords = texturecoords*facescale;

	if(!facegroup)
	{
	//	if(FACE_SIDE & facebit)
	//		facebit = FACE_SIDE;
		
		// can't really think of a reason to get this working because it has less culling support, and it is probably slower. still curious.
/*		if(typegroup.blocktype <= 0)	// no need to separate top/bottom/sides of alternate use types
		{
			vertspercubic = 24;
			trianglevertsspercubic = 36;
			facebit = FACE_ALL;
		}
		else
		{*/
	
		facegroupsize += 10;	// number of extra faces that can be added to the facegroup before requiring a rebuild (extra allocations)
		facegroup = GetGhostFaceGroup(facegroupsize);
		
		if(!facegroup)
		{	
	
			switch(facebit)
			{
				case FACE_TOP:		vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
				
				
				case FACE_WEST:		vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
				case FACE_SOUTH:	vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
				case FACE_EAST:		vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
				case FACE_NORTH:	vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
				
			//	case FACE_SIDE:		vertspercubic = 16;	trianglevertsspercubic = 24;	break;	// 4 faces
				
				
				case FACE_BOTTOM:	vertspercubic = 4;	trianglevertsspercubic = 6;		break;	// 1 face
			//	default:			print("Warning: Missing facebit value.\n");			break;
			}
//		}
		

			// these allocations only represent 1 of 6 sides
			facegroup = spawn();
			
			facegroup.verts = memalloc(sizeof(trisoup_simple_vert_t)*(facegroupsize*vertspercubic)); // vertexes
			facegroup.vertex_indexes = memalloc(sizeof(int)*(facegroupsize*trianglevertsspercubic)); // triangles
			facegroup.verts_ambientrgb = memalloc(sizeof(vector)*(facegroupsize*vertspercubic)); // vertex ambient lighting/basergb		
			facegroup.verts_staticrgb = memalloc(sizeof(vector)*(facegroupsize*vertspercubic)); // vertex static lighting/basergb

			facegroup.allocsize_verts = facegroupsize*vertspercubic;			// some facegroups will have extra space already depending on hidden faces
			facegroup.allocsize_indexes = facegroupsize*trianglevertsspercubic;	
		}
		
		facegroup.faces = facebit;
		facegroup.texturename = GetTextureForTypeFace(typegroup.blocktype, facebit);	// FIXME:	could just look this up on draw instead of storing it...
		FaceGroupChain_Add(typegroup, facegroup);
		facegroup.typegroupent = typegroup;
		
		if(listid == DRAWLIST_CHUNK)
			DrawFaceGroupChain_Add(facegroup);
		else
		if(listid == DRAWLIST_DMG)
			DrawDamageFaceGroupChain_Add(facegroup);
	}
	
	float facealpha = typegroup.alpha;
	if(!facealpha)
		facealpha = 1;
	
	// add ambient light or specified brightness/color
	
	vector rgb = '0 0 0';
	
	if(typegroup.lightcolor != '0 0 0')
		rgb = typegroup.lightcolor;
	else
		rgb = GetAmbientLightForFaceVertex(facegroup.faces, vertpos);
	
	facegroup.verts_ambientrgb[facegroup.numvertexes] = rgb;	// sets vertexe's base ambient value
	facegroup.verts_staticrgb[facegroup.numvertexes] = rgb;		// sets all the following to the ambient value so it is ready to have light added to it
	facegroup.verts[facegroup.numvertexes].xyz	= (vec3) {vertpos_x, vertpos_y, vertpos_z};	// vert coords
	facegroup.verts[facegroup.numvertexes].st	= (vec2) {texturecoords_x, texturecoords_y};	// texture coords
	facegroup.verts[facegroup.numvertexes].rgba	= (vec4) {rgb_x, rgb_y, rgb_z, facealpha};	// color and alpha

	facegroup.numvertexes++;
}

void SetVertexIndexes(int numvertsforface, entity typegroup, int facebit)
{
//	if(typegroup.blocktype <= 0)	// no need to separate top/bottom/sides of alternate use types
//		facebit = FACE_ALL;
	
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
	
	facegroup.numtrisets += numvertsforface;		// make sure to set facegroup.numtrisets to 0 before using the rebuilding flag
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
	int numvertsforface = 0;
	
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
	vector texturecoords = '0 0 0';
	
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

entity CreateTypeGroup(entity chunk, float type)
{
	entity typegroup = spawn();
	typegroup.blocktype = type;
	TypeGroupChain_Add(chunk, typegroup);	
	
	return typegroup;
}

void RemoveFaceGroup(entity typegroup, entity facegroup, int allowghost)
{
	if(allowghost)
	if(GhostFaceGroup(typegroup, facegroup))
		return;
	
	memfree(facegroup.verts);
	memfree(facegroup.vertex_indexes);
	memfree(facegroup.verts_ambientrgb);	
	memfree(facegroup.verts_staticrgb);

	DrawFaceGroupChain_Remove(facegroup);
	DrawDamageFaceGroupChain_Remove(facegroup);
	FaceGroupChain_Remove(typegroup, facegroup);
	StaticLitFaceGroupChain_Remove(facegroup);
	LitFaceGroupChain_Remove(facegroup);
	Remove(facegroup);
}

void RemoveTypeGroup(entity chunk, entity typegroup)
{
	while(typegroup.list_facegroupchain)
		RemoveFaceGroup(typegroup, typegroup.list_facegroupchain, TRUE);	// This function assumes it is being used on a chunk.

	TypeGroupChain_Remove(chunk, typegroup);	
	Remove(typegroup);
}

void SetFacesToBuildForFrame()
{
	facesbuiltforframe = 0;

	if((buildfacesforframe & FACEBUILD_FAR) && list_queuedamagefacebuildchain)
	{
		buildfacesforframe = buildfacesforframe - (buildfacesforframe & FACEBUILD_FAR);
		buildfacesforframe = buildfacesforframe | FACEBUILD_DMG;
	}
	else
	{
		buildfacesforframe = buildfacesforframe - (buildfacesforframe & FACEBUILD_DMG);
		buildfacesforframe = buildfacesforframe | FACEBUILD_FAR;
	}		
}

void DrawFaceGroup(entity typegroup, entity facegroup)
{
	if(!typegroup || !facegroup)
		return;

	addtrisoup_simple(facegroup.texturename, 0, facegroup.verts, facegroup.vertex_indexes, facegroup.numvertexindexes);
}