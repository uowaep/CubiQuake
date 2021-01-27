int ConvertRotation(int rotation, int xzoffset, int yawoffset)
{
	rotation += xzoffset*4;
	int xzrotation = floor(rotation/4)*4;
	int yaw = rotation-xzrotation;
	
	yaw+=yawoffset;
	if(yaw > 3)
		yaw -= 4;
	
	rotation = xzrotation+yaw;
	return rotation;
}

void BuildFacesForShape(entity typegroup, int blockshape, int blockrotation, int cullbits, vector cubicposition, int numchunkcubics, float facescale, int listid)
{
	switch(blockshape)
	{
		case BLOCKSHAPE_CUBE:														BuildFaces_Cube(typegroup, cullbits, cubicposition, numchunkcubics, facescale, listid);					break;
		
		case BLOCKSHAPE_RAMP:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Ramp(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);			else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Ramp_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Ramp_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Ramp_CW(typegroup, ConvertRotation(blockrotation, -2, -1), cullbits, cubicposition, numchunkcubics, facescale, listid);	break;
							//		if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Ramp_UD(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics);	break;
									
		case BLOCKSHAPE_WEDGETIP:	if(blockrotation <= BLOCKROTATION_S)			BuildFaces_WedgeTip(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid); 		else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_WedgeTip_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);	else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_WedgeTip_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);	else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_WedgeTip_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);	else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_WedgeTip_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);	else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_WedgeTip_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);	break;
									
		case BLOCKSHAPE_WEDGE:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Wedge(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid); 		else	
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Wedge_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid); 		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Wedge_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid); 		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Wedge_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Wedge_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_Wedge_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		break;

		case BLOCKSHAPE_SLAB:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Slab(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);			else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Slab_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Slab_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale, listid);		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Slab_CW(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics, facescale, listid);	break;
							//		if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Slab_UD(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics, facescale);	break;	
	}
}

void QueueFaceBuildChain_Remove(entity e)
{
	if(list_queuefacebuildchain == e)
	{
		buildchunkfaces_builtcount = 0;
		buildchunkfaces_cubiccount = 0;
	}
	
	QueueFaceBuildChain_Remove_(e);
}

/*void ClearAltBuildFace(entity e)
{
	if(buildaltface_chunk == e)
	{
		buildaltface_chunk = __NULL__;
		buildchunkdamagefaces_builtcount = 0;
		buildchunkdamagefaces_cubiccount = 0;
	}	
}*/

void QueueDamageFaceBuildChain_Remove(entity e)
{
	if(list_queuedamagefacebuildchain == e)
	{
		buildchunkdamagefaces_builtcount = 0;
		buildchunkdamagefaces_cubiccount = 0;
	}	
	
	QueueDamageFaceBuildChain_Remove_(e);
}

/*void QueueDamageFaceRebuildChain_Remove(entity e)
{
	ClearAltBuildFace(e);
	QueueDamageFaceRebuildChain_Remove_(e);
}*/

/*void ClearChunkDamageFaces(entity chunk)
{
	entity nexte = __NULL__;
	
	for(entity typegroup = chunk.list_typegroupchain; typegroup; typegroup = nexte)
	{
		nexte = typegroup.typegroupchain;
		
		if(typegroup.blocktype <= BLOCKTYPE_DMG_10 && typegroup.blocktype >= BLOCKTYPE_DMG_90)
		{
			for(entity facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
			{
				facegroup.settingvertex = 0;
				facegroup.settingindex = 0;
				facegroup.numtrisets = 0;
			}
		}
//			RemoveTypeGroup(chunk, typegroup);
	}	
}*/

/*int BuildDamageFace(entity chunk, int cubiccount)
{
	int blockshape = 0, blockrotation = 0, cullbits = 0, type = 0, cubichealth = 0;
	vector cubicposition = '0 0 0';
	
	cubichealth = chunk.cubic_health[cubiccount];

	if(cubichealth <= 0 || cubichealth > 90)	// don't show damage above 90 health 
		return FALSE;

	//these values are all negative, so this math is in reverse (min dmg is 10 here)
	type = BLOCKTYPE_DMG_10 + 1 - floor((100-cubichealth)/10); // DMG_10 for less than 10, so DMG 100 for less than 100 (no need to set a max because 100 wasn't allowed here)

	entity typegroup = GetTypeGroup(chunk, type);
	if(!typegroup)	// texture set group for chunk
		typegroup = CreateTypeGroup(chunk, type);
	
	if(typegroup)
	{
		blockshape = chunk.cubic_blockshape[cubiccount];
		blockrotation = chunk.cubic_blockrotation[cubiccount];
		cullbits = chunk.cubic_cullbits[cubiccount];
		cubicposition = chunk.origin + GetCubicOffset(cubiccount);
		BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, chunk.numdamagedcubics, 1);
	}
	
	return TRUE;
}*/

int	GetFaceTypeForDamage(float healthlvl)
{
/*	if(healthlvl <= secondstagedmghealth)
		return BLOCKTYPE_DMG_66;
	else
	if(healthlvl <= maxdmghealth)
		return BLOCKTYPE_DMG_33;*/
	
	
	return BLOCKTYPE_DMG_LOW + 1 - floor((100-healthlvl)/dmghealthincrementsize);
}

void RemoveDamageFacesForCubic(entity chunk, int cubicid, int oldhealth)
{
	int indexcount = 0, vertcount = 0, id = 0, facebit = 0, slot = 0, removedpolygons = 0;
	vector ofs = '0 0 0', pos = '0 0 0', tri_verts, vertex_a, vertex_b, vertex_c;
	entity facegroup = __NULL__;
	
	vector cubicposition = chunk.origin + GetCubicOffset(cubicid);	
	int type = GetFaceTypeForDamage(oldhealth);
	entity typegroup = GetTypeGroup(chunk, type);

	for(int facecount = 0; facecount < 6; facecount++)	// facegroup
	{	
		facebit = bitshift(1, facecount);
		facegroup = GetFaceGroup(typegroup, facebit);

		if(!facegroup)
			continue;

		removedpolygons = 0;

		switch(facecount)
		{
			case 0:		ofs = VECOFS_U;		break;
			case 1:		ofs = VECOFS_W;		break;
			case 2:		ofs = VECOFS_S;		break;
			case 3:		ofs = VECOFS_E;		break;
			case 4:		ofs = VECOFS_N;		break;
			case 5:		ofs = VECOFS_D;		break;
		}

		for(indexcount = 0; indexcount < facegroup.numvertexindexes; indexcount+=3)	// facegroup cubic
		{
			tri_verts_x = facegroup.vertex_indexes[indexcount];	
			tri_verts_y = facegroup.vertex_indexes[indexcount+1];
			tri_verts_z = facegroup.vertex_indexes[indexcount+2];
			
			vertex_a_x = facegroup.verts[tri_verts_x].xyz[0];
			vertex_a_y = facegroup.verts[tri_verts_x].xyz[1];
			vertex_a_z = facegroup.verts[tri_verts_x].xyz[2];

			vertex_b_x = facegroup.verts[tri_verts_y].xyz[0];
			vertex_b_y = facegroup.verts[tri_verts_y].xyz[1];
			vertex_b_z = facegroup.verts[tri_verts_y].xyz[2];
			
			vertex_c_x = facegroup.verts[tri_verts_z].xyz[0];
			vertex_c_y = facegroup.verts[tri_verts_z].xyz[1];
			vertex_c_z = facegroup.verts[tri_verts_z].xyz[2];			

			pos = (vertex_a+vertex_b+vertex_c)*(1/3);
			pos = pos - ofs;	// nudge toward inside of face
			pos = GetNearestCubicOrigin(pos, chunksize_iseven);
			id = GetCubicRef(pos-GetNearChunkOrg(pos));
			
			if(id == cubicid)
			{
				// these slots are just taking up space now, but aren't drawing anything anymore
				facegroup.verts[tri_verts_x].xyz	= (vec3) {0, 0, 0};	// vert coords
				facegroup.verts[tri_verts_x].st		= (vec2) {0, 0};	// texture coords
				facegroup.verts[tri_verts_x].rgba	= (vec4) {0, 0, 0, 0};	// color and alpha	
				facegroup.verts[tri_verts_y].xyz	= (vec3) {0, 0, 0};	// vert coords
				facegroup.verts[tri_verts_y].st		= (vec2) {0, 0};	// texture coords
				facegroup.verts[tri_verts_y].rgba	= (vec4) {0, 0, 0, 0};	// color and alpha	
				facegroup.verts[tri_verts_z].xyz	= (vec3) {0, 0, 0};	// vert coords
				facegroup.verts[tri_verts_z].st		= (vec2) {0, 0};	// texture coords
				facegroup.verts[tri_verts_z].rgba	= (vec4) {0, 0, 0, 0};	// color and alpha	
					
				facegroup.vertex_indexes[indexcount] = __NULL__;
				facegroup.vertex_indexes[indexcount+1] = __NULL__;
				facegroup.vertex_indexes[indexcount+2] = __NULL__;

				removedpolygons++;
				
				if(removedpolygons > 1)	// there are no faces with more than 2 polygons. no need to search this facegroup anymore
					break;
			}
		}
	}
}

void BuildChunkDamageFaces(entity chunk, int forcedcullbits, int onlytype, int fastbuild)
{
	int blockshape = 0, blockrotation = 0, type = 0, cullbits = 0, cubichealth = 0, cubiccount = 0, builtcount = 0, buildall = 0;
	vector cubicposition = '0 0 0';	
	entity typegroup = __NULL__, nexte = __NULL__;
	
	if(forcedcullbits || onlytype)
		buildall = TRUE;
	else
	{
			cubiccount = buildchunkdamagefaces_cubiccount;
			builtcount = buildchunkdamagefaces_builtcount;
	}

/*	if(!cubiccount)
	for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = nexte)
	{
		nexte = typegroup.typegroupchain;
		
		if(typegroup.blocktype <= BLOCKTYPE_DMG_10 && typegroup.blocktype >= BLOCKTYPE_DMG_90)
		{
			QueueClearChunkDamageFaces_Add(chunk, typegroup);
			typegroup.markedforremoval = TRUE;
		}
	}*/
	
	for(; (builtcount < chunk.numdamagedcubics && numdamagecubicsbuiltforframe < autocvar_cq_maxdamagecubicsperbuild) || buildall || fastbuild; cubiccount++)
	{
		if(cubiccount >= pow(chunksize, 3))	// the normal face building loop will handle this error
			break;

		cubichealth = chunk.cubic_health[cubiccount];

		if(cubichealth <= 0 || cubichealth > maxdmghealth)	// don't show damage above 90 health (doesn't count toward .numdamagedcubics unless 90 or below)
			continue;

		//these values are all negative, so this math is in reverse (min dmg is 10 here)
		type = GetFaceTypeForDamage(cubichealth);

		if(onlytype)
		if(type != onlytype)
		{
			builtcount++;
			continue;
		}

		typegroup = GetTypeGroup(chunk, type);
		if(!typegroup)
		{
			typegroup = CreateTypeGroup(chunk, type);
			typegroup.lightcolor = '-1 -1 -1';
			typegroup.alpha = 0.8;
		}
		
		if(typegroup)
		{
			blockshape = chunk.cubic_blockshape[cubiccount];
			blockrotation = chunk.cubic_blockrotation[cubiccount];
			cullbits = chunk.cubic_cullbits[cubiccount] | forcedcullbits;
			cubicposition = chunk.origin + GetCubicOffset(cubiccount);
			BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, chunk.numdamagedcubics, 1, DRAWLIST_DMG);
			numdamagecubicsbuiltforframe++;	
		}
		
		builtcount++;
	}
	
	if(buildall)
		return;
	
	if(fastbuild)
	{
		QueueNearDamageFaceBuildChain_Remove(chunk);
		return;
	}

	if(numdamagecubicsbuiltforframe >= autocvar_cq_maxdamagecubicsperbuild) // save place for next frame
	{
		numdamagecubicsbuiltforframe = -1;
		
		if(builtcount < chunk.numdamagedcubics)	// don't set these if the chunk finished right at the max per build
		{
//			buildaltface_chunk = chunk;
			buildchunkdamagefaces_builtcount = builtcount;
			buildchunkdamagefaces_cubiccount = cubiccount;
			return;
		}
	}
	
//	buildaltface_chunk = __NULL__;
	buildchunkdamagefaces_builtcount = 0;
	buildchunkdamagefaces_cubiccount = 0;
	QueueDamageFaceBuildChain_Remove(chunk);	
}

void AddDamageFacesForCubic(entity chunk, int cubiccount)
{
	int blockshape = 0, blockrotation = 0, cullbits = 0, type = 0, cubichealth = 0, typegroupisnew = 0, facebit = 0;
	vector cubicposition = '0 0 0';	
	entity typegroup = __NULL__, facegroup = __NULL__, nexte = __NULL__;
	
	cubichealth = chunk.cubic_health[cubiccount];

	if(cubichealth <= 0 || cubichealth > maxdmghealth)	// doesn't show damage above 90 health 
		return;

	//these values are all negative, so this math is in reverse (min dmg is 10 here)
	type = GetFaceTypeForDamage(cubichealth);

	typegroup = GetTypeGroup(chunk, type);
	if(!typegroup)
	{
		typegroup = CreateTypeGroup(chunk, type);
		typegroup.lightcolor = '-1 -1 -1';
		typegroup.alpha = 0.8;
		typegroupisnew = TRUE;
	}
	
	if(typegroup)
	{
		blockshape = chunk.cubic_blockshape[cubiccount];
		blockrotation = chunk.cubic_blockrotation[cubiccount];
		cullbits = chunk.cubic_cullbits[cubiccount];
		cubicposition = chunk.origin + GetCubicOffset(cubiccount);
		
		if(!typegroupisnew)
		for(int count = 0; count < 6; count++)
		{
			facebit = bitshift(1, count);
			facegroup = GetFaceGroup(typegroup, facebit);

			if(facegroup)
			if(chunk.numdamagedcubics*4 >= facegroup.allocsize_verts || chunk.numdamagedcubics*6 >= facegroup.allocsize_indexes)	// allocations are too small, rebuild/reallocate
			{
				RemoveFaceGroup(typegroup, facegroup, TRUE);	// clear existing facegroup
				BuildChunkDamageFaces(chunk, CULLBITS_ALL - facebit, type, FALSE);		// rebuild faces for this damage type for this side only
				cullbits = cullbits | facebit;	// don't add to this typegroup's side right now since it is going to be rebuilt to increase allocation size
			}
		}
		
		if(cullbits != CULLBITS_ALL)
			BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, chunk.numdamagedcubics, 1, DRAWLIST_DMG);
	}	
}

void BuildChunkFaces(entity chunk, int distant)
{
	entity typegroup = __NULL__;
	int blockshape = 0, blockrotation = 0, cullbits = 0, cubiccount = 0, numchunkcubics = 0, builtcount = 0, type = 0;
	vector cubicposition = '0 0 0';

	numchunkcubics = chunk.numvisiblecubics;
	
	if(distant)
	{
		cubiccount = buildchunkfaces_cubiccount;
		builtcount = buildchunkfaces_builtcount;
	}
	else
	{
		cubiccount = 0;
		builtcount = 0;
	}
	
	for(; builtcount < numchunkcubics && !(distant && numcubicsbuiltforframe >= autocvar_cq_maxcubicsperbuild); cubiccount++)
	{
		if(cubiccount >= pow(chunksize, 3))
		{
			print("Warning: Lost chunk data over the network.\n");
			localcmd(strcat("cmd cq_resendchunk ", itos(GetChunkOriginRef(chunk.origin)), "\n"));
			break;
		}
		
		type = chunk.cubic_blocktype[cubiccount];

		if(type == __NULL__)
			continue;
		
		typegroup = GetTypeGroup(chunk, type);
		
		if(typegroup)
		{
			blockshape = chunk.cubic_blockshape[cubiccount];
			blockrotation = chunk.cubic_blockrotation[cubiccount];
			cullbits = chunk.cubic_cullbits[cubiccount];
			cubicposition = chunk.origin + GetCubicOffset(cubiccount);
			BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, numchunkcubics, 1, DRAWLIST_CHUNK);
			numcubicsbuiltforframe++;
		}
		
		builtcount++;
	}
	
	if(distant)
	{
		if(numcubicsbuiltforframe >= autocvar_cq_maxcubicsperbuild) // save place for next frame
		{
			numcubicsbuiltforframe = -1;
			
			if(builtcount < numchunkcubics)	// don't set these if the chunk finished right at the max per build
			{
				buildchunkfaces_builtcount = builtcount;
				buildchunkfaces_cubiccount = cubiccount;
				return;
			}
		}
		
		buildchunkfaces_builtcount = 0;
		buildchunkfaces_cubiccount = 0;
		QueueFaceBuildChain_Remove(chunk);
	}
	else
		QueueNearFaceBuildChain_Remove(chunk);
	
	TriggerStaticLightReset(chunk.origin);
	
	if(chunk.resetlights)
	{
		ResetStaticLights(TRUE);	// cubics were added or removed so chunk faces need to be relit
		chunk.resetlights = FALSE;
	}

	
}

float	buildfacetime;
void BuildQueuedFaces()
{
	entity e = __NULL__, nexte = __NULL__;
	int numbuilds = 0;
	
	if(time < buildfacetime)
		return;

	if(facesbuiltforframe & FACEBUILD_NEAR)
		return;

	if(!(buildfacesforframe & FACEBUILD_FAR))
		return;

	numcubicsbuiltforframe = 0;
	buildfacetime = time+frametime*autocvar_cq_framesperfacebuild;	

	for(e = list_queuefacebuildchain; e && numbuilds < autocvar_cq_maxfacegroupsperbuild && numcubicsbuiltforframe != -1; e = nexte)
	{
		nexte = e.queuefacebuildchain;

	/*	if(e.lastupdatetime)
		if(time-e.lastupdatetime > 10)
		{
			e.lastupdatetime = 0;
			localcmd(strcat("cmd cq_resendchunk ", itos(GetChunkOriginRef(e.origin, __FUNC__)), "\n"));
			print("a chunk took too long to render\n");
			continue;
		}*/
		
		if(e.findnetworkbloatent)
			continue;
		
		numbuilds++;
		BuildChunkFaces(e, TRUE);
		facesbuiltforframe = FACEBUILD_FAR;
	}
	
	numcubicsbuiltforframe = 0;
}

// this function waits in line with other queues using the buildaltface_chunk field
float	builddamagefacetime;
void BuildQueuedDamageFaces()
{	
	entity e = __NULL__, nexte = __NULL__;
	int numbuilds = 0;

	if(facesbuiltforframe & FACEBUILD_NEAR)	
		return;
	
	if(!(buildfacesforframe & FACEBUILD_DMG))
		return;	

//	if(list_queuefacebuildchain)
//		return;
	
	if(time < builddamagefacetime)
		return;

	numdamagecubicsbuiltforframe = 0;
	builddamagefacetime = time+frametime*autocvar_cq_framesperfacebuild;	// kinda unnecessary, just in case for some reason this needs to be really slow

//	if(!(buildaltface_chunk && buildaltface_chunk != list_queuedamagefacebuildchain))	// don't do anything here yet until the buildaltface_chunk is done building if it's not part of this chain
	for(e = list_queuedamagefacebuildchain; e && numbuilds < autocvar_cq_maxfacegroupsperbuild && numdamagecubicsbuiltforframe != -1; e = nexte)
	{
		nexte = e.queuedamagefacebuildchain;

		if(e.findnetworkbloatent)	// in the middle of updating the chunk via network
		{
			print("Remove from chain if this shows up.\n");
			continue;
		}

		BuildChunkDamageFaces(e, 0, 0, FALSE);
		facesbuiltforframe = facesbuiltforframe | FACEBUILD_DMG;
		numbuilds++;		
	}

/*	for(e = list_queuedamagefacerebuildchain; e && numbuilds < autocvar_cq_maxfacegroupsperbuild && numdamagecubicsbuiltforframe != -1; e = nexte)
	{
		nexte = e.queuedamagefacerebuildchain;

		if(e.findnetworkbloatent)	// in the middle of updating the chunk via network
		{
			print("Remove from chain if this shows up.\n");
			continue;
		}

		numbuilds++;
		BuildChunkDamageFaces(e, TRUE);
	}*/
	
	numdamagecubicsbuiltforframe = 0;
}

void BuildNearQueuedFaces()
{
	entity e = __NULL__, nexte = __NULL__;

//	if(!(buildfacesforframe & FACEBUILD_NEAR))
//		return;

	for(e = list_queuenearfacebuildchain; e; e = nexte)
	{
		nexte = e.queuenearfacebuildchain;
		
		if(e.findnetworkbloatent)
			continue;
		
		BuildChunkFaces(e, FALSE);
		facesbuiltforframe = facesbuiltforframe | FACEBUILD_NEAR;
	}
	
	for(e = list_queueneardamagefacebuildchain; e ; e = nexte)
	{
		nexte = e.queueneardamagefacebuildchain;

		if(e.findnetworkbloatent)	// in the middle of updating the chunk via network
			continue;

		BuildChunkDamageFaces(e, 0, 0, TRUE);
		facesbuiltforframe = facesbuiltforframe | FACEBUILD_NEAR;
	}	
}

void QueueChunkFaceBuild(entity chunk, float sendflags)
{
	// should be able to add other blended stuff here as well as long as it's built slowly
	// these types of faces need their own chain, but should mimic the slow chains below

	vector ofs = chunk.origin - GetNearChunkOrg(view_org);
	float dist = ofs*ofs;

	float proximitydist = chunksize*cubicradius*2*autocvar_cq_bgload_dist;
	proximitydist = proximitydist*proximitydist;
	
	float dmg_proximitydist = chunksize*cubicradius*2*autocvar_cq_dmgload_dist;
	dmg_proximitydist = dmg_proximitydist*dmg_proximitydist;	
	
	float isnew = (sendflags & SFL_ISNEW);
	float sfldmgd = (sendflags & SFL_DAMAGED);	// geometry has changed
	

	if(dist <= dmg_proximitydist || (!isnew && sfldmgd))
	{
	//	Damaged Faces	
		if(chunk.numdamagedcubics)
		{
			if(!isnew && (sfldmgd || (sendflags & SFL_BUILD)))	// geometry updated damage faces (any range)
			{
				QueueNearDamageFaceBuildChain_Add(chunk);	// immediate chain		
				chunk.drawingdamage = TRUE;
			}
			else
			if(dist <= dmg_proximitydist)	// non-geometry updated damage faces (near)
			{
				QueueDamageFaceBuildChain_Append(chunk);		// add to slow chain	
				chunk.drawingdamage = TRUE;
			}
		}
	}
	
	if(dist <= proximitydist || (!isnew && sfldmgd))
	{
//		Nearby or geometry updated Chunk Faces
		QueueNearFaceBuildChain_Add(chunk);	// immediate chain
		
		if(!(sendflags & SFL_ISNEW))
			if(sendflags & SFL_BUILD)
				chunk.resetlights = TRUE;
	}
	else
//		Distant Chunk Faces
		QueueFaceBuildChain_Append(chunk);	// slow chain
	

}

vector	oldplayerchunkpos;
void UpdateFaceQueuesForPlayerPosition()
{
	vector ofs = '0 0 0';
	float dist = 0;
	entity e = __NULL__, nexte = __NULL__, typegroup = __NULL__;
//	entity firstmovedchunk = __NULL__;
	
	vector currentplayerchunkpos = GetNearChunkOrg(view_org);
	if(currentplayerchunkpos == oldplayerchunkpos)	// this keeps the loops from iterating every frame
		return;
	
	float proximitydist = chunksize*cubicradius*2*autocvar_cq_bgload_dist;
	proximitydist = proximitydist*proximitydist;	

	float dmg_proximitydist = chunksize*cubicradius*2*autocvar_cq_dmgload_dist;
	dmg_proximitydist = dmg_proximitydist*dmg_proximitydist;
	
	float dmg_removedist = chunksize*cubicradius*2*(autocvar_cq_dmgload_dist+1);
	dmg_removedist = dmg_removedist*dmg_removedist;	
	
	for(e = list_queuefacebuildchain; e; e = nexte)
	{
		nexte = e.queuefacebuildchain;

		ofs = e.origin - currentplayerchunkpos;
		dist = ofs*ofs;
		
		if(dist <= proximitydist)	// this moves facegroups from the slow bg queue to the fast local queue if the player gets closer to them
		{
		//	if(!firstmovedchunk)
		//		firstmovedchunk = e;
	
			if(e == list_queuefacebuildchain)	// let's facegroup that was building finish at the speed it was going instead of restarting it
				continue;
//			for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
//				while(typegroup.list_facegroupchain)
//					RemoveFaceGroup(typegroup, typegroup.list_facegroupchain, TRUE);
		
			QueueFaceBuildChain_Remove(e);
			QueueNearFaceBuildChain_Add(e);
			// damage faces are always slow right now
		}
	}
	
	// removes damage faces past 1.5 * bg load distance and appaends at bg load distance
	for(entity chunk = list_chunkchain; chunk; chunk = chunk.chunkchain)
	{
		ofs = chunk.origin - currentplayerchunkpos;
		dist = ofs*ofs;
		
		if(dist > dmg_removedist)
		{		
			if(chunk.drawingdamage)
			{
				for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = nexte)
				{
					nexte = typegroup.typegroupchain;
					
					if(typegroup.blocktype <= BLOCKTYPE_DMG_LOW && typegroup.blocktype >= BLOCKTYPE_DMG_HIGH)
						RemoveTypeGroup(chunk, typegroup);
				}
				
				QueueDamageFaceBuildChain_Remove(chunk);
				chunk.drawingdamage = FALSE;
			}
		}
		else
		if(dist <= dmg_proximitydist)
		if(!chunk.drawingdamage)
		{
			if(chunk.numdamagedcubics)
				QueueDamageFaceBuildChain_Append(chunk);
			chunk.drawingdamage = TRUE;
		}
	}
	
	
	
/*	if(firstmovedchunk)
		e = firstmovedchunk;
	else
		e = list_queuenearfacebuildchain;
	
	for(; e; e = nexte)
	{
		nexte = e.queuenearfacebuildchain;
		
		ofs = e.origin - currentplayerchunkpos;
		dist = ofs*ofs;		
		
		if(dist > proximitydist)
		{
			QueueNearFaceBuildChain_Remove(e);
			QueueFaceBuildChain_Add(e);			
		}
	}*/
	
	oldplayerchunkpos = currentplayerchunkpos;
}