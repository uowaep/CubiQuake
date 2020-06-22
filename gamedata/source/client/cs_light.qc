void ClientToggleLight()
{
	if(!client_initialized)	// don't try to light anything until faces arrive (or even toggle this)
		return;
	
	if(clientlight_state)
	{
		clientlight_state = FALSE;
		DynamicLightChain_Remove(clientlight);
	}
	else
	{
		clientlight_state = TRUE;
		DynamicLightChain_Add(clientlight);
	}	
}

void InitializeClientLight()
{
	clientlight = spawn();
//	clientlight.lightradius = 256;//256;	// don't use the maxlightradius field as it is not set until networking starts.
	clientlight.lightbrightness = 2;
	clientlight.lightcolor = '1 0.9 0.7';
}

void ResetStaticLights(int forcerelight)
{
	if(forcerelight)
		static_relighttime = time;
	else
	if(!static_relighttime)
		static_relighttime = time + autocvar_cq_lights_static_updateinterval;	// the delay is to allow more shared server/client ents to update, thus requiring less calls to reset static lighting
}

vector GetModifiedLightForFaceGroupAngle(int facebit, vector ofs, vector rgb, float radiance)
{
	vector facenormal = '0 0 0';
	
	switch(facebit)
	{
		case FACE_TOP:		facenormal = '0 0 1';		break;
		case FACE_WEST:		facenormal = '-1 0 0';		break;
		case FACE_SOUTH:	facenormal = '0 -1 0';		break;
		case FACE_EAST:		facenormal = '1 0 0';		break;
		case FACE_NORTH:	facenormal = '0 1 0';		break;
		case FACE_BOTTOM:	facenormal = '0 0 -1';		break;
	}	
		
	float cos = bound(0, ((normalize(ofs)*facenormal)*(1-radiance)*-1)+radiance, 1);
	
	return rgb*cos;
}

vector GetAmbientLightForFaceVertex(int facebit, vector vertpos)
{
	if(ambientlight_position == '0 0 0')
		ambientlight_position = ('0 0 1'*worldheight*cubicradius);	// default light position
	
	return GetModifiedLightForFaceGroupAngle(facebit, vertpos - ambientlight_position, ambientlight_modified, autocvar_cq_ambientlight_radiance);
}

void ResetAmbientLight()	
{
	entity chunk, typegroup, facegroup;
	vector vertpos = '0 0 0', rgb = '0 0 0';
	
	int count;
	for(chunk = list_chunkchain; chunk; chunk = chunk.chunkchain)
		for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
		{
			if(typegroup.blocktype <= BLOCKTYPE_DMG_LOW && typegroup.blocktype >= BLOCKTYPE_DMG_HIGH)
				continue;
			
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				for(count = 0; count < facegroup.numvertexes; count++)
				{
					if(facegroup.faces == FACE_ALL)
						continue;
					
					vertpos_x = facegroup.verts[count].xyz[0];
					vertpos_y = facegroup.verts[count].xyz[1];
					vertpos_z = facegroup.verts[count].xyz[2];
					
					rgb = GetAmbientLightForFaceVertex(facegroup.faces, vertpos);
					
					facegroup.verts_ambientrgb[count] = rgb;
					facegroup.verts_staticrgb[count] = rgb;	// this saves this as the base
					facegroup.verts[count].rgba[0] = rgb_x; // these set this as the current value also
					facegroup.verts[count].rgba[1] = rgb_y;
					facegroup.verts[count].rgba[2] = rgb_z;
				}	
		}
//	ambientlightset = TRUE;			
	ResetStaticLights(TRUE);
}
/*
int buildambientvertex_vertexnum;
void UpdateVertexAmbientLightForFrame()
{
	entity nexte = __NULL__;
	int count = 0, numrelitvertexes = 0;
	vector vertpos = '0 0 0', rgb = '0 0 0';
	
	int maxrelitvertexesperframe = 1000;
	
	for(entity facegroup = list_resetambientlightchain; facegroup; facegroup = nexte)
	{
		nexte = facegroup.resetambientlightchain;
		
		for(count = buildambientvertex_vertexnum; count < facegroup.numvertexes && numrelitvertexes < maxrelitvertexesperframe; count++)
		{
			vertpos_x = facegroup.verts[count].xyz[0];
			vertpos_y = facegroup.verts[count].xyz[1];
			vertpos_z = facegroup.verts[count].xyz[2];
			
			rgb = GetAmbientLightForFaceVertex(facegroup.faces, vertpos);
			
			facegroup.verts_ambientrgb[count] = rgb;
			facegroup.verts_staticrgb[count] = rgb;	// this saves this as the base
			facegroup.verts[count].rgba[0] = rgb_x; // these set this as the current value also
			facegroup.verts[count].rgba[1] = rgb_y;
			facegroup.verts[count].rgba[2] = rgb_z;
		}

		if(count >= maxrelitvertexesperframe)
		{
			if(count == facegroup.numvertexes)
				ResetAmbientLightChain_Remove(facegroup);
			else
				buildambientvertex_vertexnum = count+1;
			return;
		}
		
		ResetStaticLights(TRUE);		// this might need a slow loop too :P
		ResetAmbientLightChain_Remove(facegroup);
		
		numrelitvertexes++;
	}
	
	buildambientvertex_vertexnum = 0;

//	ResetStaticLights(TRUE);	
}*/

void SetStaticLightResetTrigger(vector org)
{
	vector clusterorg = GetNearClusterOrg(org);
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		cluster = SpawnCluster(GetClusterRef(clusterorg));
	
	int flagfield = cluster.chunk_flags[GetChunkRef(org-clusterorg, __FUNC__)];
	cluster.chunk_flags[GetChunkRef(org-clusterorg, __FUNC__)] = flagfield | CHFL_TRIGGERSTATICLIGHTS;
}

void TriggerStaticLightReset(vector org)
{
	vector clusterorg = GetNearClusterOrg(org);
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;

	int chunkid = GetChunkRef(org-clusterorg, __FUNC__);
	int flagfield = cluster.chunk_flags[chunkid];
	
	if(flagfield & CHFL_TRIGGERSTATICLIGHTS)
		ResetStaticLights(FALSE);
}

void ClearStaticLightResetTrigger(vector org)
{
	vector clusterorg = GetNearClusterOrg(org);
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;

	int flagfield = cluster.chunk_flags[GetChunkRef(org-clusterorg, __FUNC__)];
	flagfield = flagfield - (flagfield & CHFL_TRIGGERSTATICLIGHTS);
	cluster.chunk_flags[GetChunkRef(org-clusterorg, __FUNC__)] = flagfield;
}

void ClearStaticLightResetTriggersForLight(entity light)
{
	float lightradiusdotp, lightsize, lrad;
	vector lightchunkorg, chunkpos, ofs, target;

	if(!maxlightradius)
		lrad = light.lightradius;
	else
		lrad = min(maxlightradius, light.lightradius);
	
	lightradiusdotp = lrad*lrad;
	lightchunkorg = GetNearChunkOrg(light.origin);
	lightsize = ceil(lrad / (chunksize*cubicradius));
	if(lightsize*0.5 == floor(lightsize*0.5))
		lightsize+=1;

	for(chunkpos_x = 0; chunkpos_x < lightsize; chunkpos_x++)
		for(chunkpos_y = 0; chunkpos_y < lightsize; chunkpos_y++)
			for(chunkpos_z = 0; chunkpos_z < lightsize; chunkpos_z++)
			{
				ofs = chunkpos - ('1 1 1'*(lightsize-1)*0.5);
				target = lightchunkorg + ofs*chunksize*cubicradius*2;
				ClearStaticLightResetTrigger(target);
			}
}

entity SetChunkLight(entity chunk, int memslot, int type)
{
	entity light;
	
	for(light = chunk.list_chunklightchain; light; light = light.chunklightchain)
	{
		if(light.cubicmemslot == memslot)
			return light;
	}
	
	light = spawn();
	SetModelForCubicObject(light, type, TRUE);
	SetYawForCubicObject(light, chunk.cubic_blockrotation[memslot]);
	light.solid = SOLID_BBOX;
	setorigin(light, chunk.origin + GetCubicOffset(memslot));
	light.drawmask = MASK_NORMAL;
	light.cubicmemslot = memslot;
	light.lightradius = 416;
	light.lightcolor = '1 1 1';
	light.lightbrightness = 1;
	ChunkEntChain_Add(chunk, light);	
	ChunkLightChain_Add(chunk, light);
	StaticLightChain_Add(light);	
	
	ResetStaticLights(FALSE);
	
	return light;
}

void SetVertLights(entity light, int isstatic)
{
	vector vertpos, facergb, ofs, chunkpos, rgb, lightchunkorg, target;
	float lightsize, ofsdotp, lightradiusdotp, lrad;
	entity typegroup, facegroup;
	int	count, facegroupislit;
	entity chunk = __NULL__;	
	entity cluster = __NULL__;

	if(!maxlightradius)
		lrad = light.lightradius;
	else
		lrad = min(maxlightradius, light.lightradius);
	
	lightradiusdotp = lrad*lrad;
	lightchunkorg = GetNearChunkOrg(light.origin);
	lightsize = ceil(lrad / (chunksize*cubicradius));
	if(lightsize*0.5 == floor(lightsize*0.5))
		lightsize+=1;

	for(chunkpos_x = 0; chunkpos_x < lightsize; chunkpos_x++)
		for(chunkpos_y = 0; chunkpos_y < lightsize; chunkpos_y++)
			for(chunkpos_z = 0; chunkpos_z < lightsize; chunkpos_z++)
			{
				ofs = chunkpos - ('1 1 1'*(lightsize-1)*0.5);
				target = lightchunkorg + ofs*chunksize*cubicradius*2;

				if(target_x > worlddim_x*0.5 || target_x < worlddim_x*-0.5
				|| target_y > worlddim_y*0.5 || target_y < worlddim_y*-0.5
				|| target_z > worlddim_z*0.5 || target_z < worlddim_z*-0.5)
					continue;
				
				chunk = GetChunkForLocation(__NULL__, target, __FUNC__);

				if(isstatic)
					SetStaticLightResetTrigger(target);

				if(chunk)
				{
					cluster = GetClusterForLocation(cluster, GetNearClusterOrg(chunk.origin));
					
					if(chunk.list_typegroupchain)
					for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
					{
						if(typegroup.lightcolor != '0 0 0')
								continue;
						
						for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
						{
							if(facegroup.faces == FACE_ALL)
								continue;
							
							facegroupislit = FALSE;
							
							for(count = 0; count < facegroup.numvertexes; count++)
							{
								vertpos_x = facegroup.verts[count].xyz[0];
								vertpos_y = facegroup.verts[count].xyz[1];
								vertpos_z = facegroup.verts[count].xyz[2];
								ofs = vertpos - light.origin;
								ofsdotp = ofs*ofs;
								
								facergb_x = facegroup.verts[count].rgba[0];
								facergb_y = facegroup.verts[count].rgba[1];
								facergb_z = facegroup.verts[count].rgba[2];		
								
								if(ofsdotp > lightradiusdotp)
									rgb = '0 0 0';
								else
								if(ofsdotp == 0)
									rgb = light.lightcolor*light.lightbrightness;
								else
									rgb = light.lightcolor*light.lightbrightness*(1-(vlen(ofs)/lrad));
								
								// checks the face normal vs the light angle and modies the total face brightness
								rgb = GetModifiedLightForFaceGroupAngle(facegroup.faces, ofs, rgb, autocvar_cq_lights_radiance);
								
								if(rgb_x > 0 || rgb_y > 0 || rgb_z > 0)
								{
									facegroupislit = TRUE;
								
									rgb = facergb + rgb;
									facegroup.verts[count].rgba[0] = rgb_x;
									facegroup.verts[count].rgba[1] = rgb_y;
									facegroup.verts[count].rgba[2] = rgb_z;

									if(isstatic)
										facegroup.verts_staticrgb[count] = rgb;
								}
							}
							
							if(facegroupislit)
							{
								if(isstatic)
									StaticLitFaceGroupChain_Add(facegroup);
								else
									LitFaceGroupChain_Add(facegroup);
								
								cluster.islit = TRUE;
							}
						}
					}
				}
			}
}

// This _Wrap function gives mods access to the relightstatic and relightdynamic fields before they are cleared. Use __wrap or __accumulate.
void ApplyLighting_Wrap()
{
	if(relightstatic || (autocvar_cq_lights_models && !cq_lights_models_old))		
	for(entity light = list_staticlightchain; light; light = light.staticlightchain)
	{
		if(autocvar_cq_lights_models)
		if(!light.staticlno)
			light.staticlno = dynamiclight_spawnstatic(light.origin, light.lightradius, light.lightcolor*light.lightbrightness);
		
		if(relightstatic)
			SetVertLights(light, TRUE);
	}

	if(relightdynamic || relightstatic || autocvar_cq_lights_models)		
	for(entity light = list_dynamiclightchain; light; light = light.dynamiclightchain)
	{
		if(autocvar_cq_lights_models)
			dynamiclight_add(light.origin, light.lightradius, light.lightcolor*light.lightbrightness*0.5, 0);
		
		if(relightdynamic || relightstatic)			
			SetVertLights(light, FALSE);	
	}
	
	// cleans up static lights if turning off engine lighting
	if(!autocvar_cq_lights_models && cq_lights_models_old)
	for(entity light = list_staticlightchain; light; light = light.staticlightchain)
	{
		dynamiclight_set(light.staticlno, LFIELD_RADIUS, 0);
		light.staticlno = 0;
	}

	cq_lights_models_old = autocvar_cq_lights_models;	
}

void AddLights()
{
	int count = 0;
	vector rgb = '0 0 0';

	if(clientlight)
		clientlight.lightradius = autocvar_cq_clientlightradius;

//	if(!ambientlightset)
//		ResetAmbientLight();
	
//  static_relighttime is the min amount of time to wait during chunk network updating and face building to re-light new incoming/built faces. it should not be triggered otherwise.
	if((static_relighttime && time >= static_relighttime) || time >= dynamic_relighttime) 
	{
		if(static_relighttime && time >= static_relighttime)
		{
			relightstatic = TRUE;
			static_relighttime = 0;
		}
		
		relightdynamic = TRUE;
		dynamic_relighttime = time+autocvar_cq_lights_dynamic_updateinterval;
	}
	
	if(relightstatic)		// sets base color to ambient when static relight is called
	while(list_staticlitfacegroupchain)
	{
		for(count = 0; count < list_staticlitfacegroupchain.numvertexes; count++)
		{
			rgb = list_staticlitfacegroupchain.verts_ambientrgb[count];
			list_staticlitfacegroupchain.verts_staticrgb[count] = rgb;	// setting the lit static values to ambient since the lit values are being reset and these faces can be ignored when adding lights if they are not in range
			list_staticlitfacegroupchain.verts[count].rgba[0] = rgb_x;	// resetting the lit total values to base ambient because we're going to have to reset dynamic also anyway
			list_staticlitfacegroupchain.verts[count].rgba[1] = rgb_y;
			list_staticlitfacegroupchain.verts[count].rgba[2] = rgb_z;
		}
		
		StaticLitFaceGroupChain_Remove(list_staticlitfacegroupchain);
	}
	
	if(relightdynamic || relightstatic) // sets verts to base color: ambient or static
	while(list_litfacegroupchain)
	{
		for(count = 0; count < list_litfacegroupchain.numvertexes; count++)
		{
			rgb = list_litfacegroupchain.verts_staticrgb[count];	// getting lit static value
			list_litfacegroupchain.verts[count].rgba[0] = rgb_x;	// resetting lit total values to the lit static value
			list_litfacegroupchain.verts[count].rgba[1] = rgb_y;
			list_litfacegroupchain.verts[count].rgba[2] = rgb_z;
		}
		
		LitFaceGroupChain_Remove(list_litfacegroupchain);
	}
	
	ApplyLighting_Wrap();
	
	relightstatic = FALSE;
	relightdynamic = FALSE;
}