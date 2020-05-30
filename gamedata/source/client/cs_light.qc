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
	clientlight.lightbrightness = 3;
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

void ResetAmbientLight()
{
	entity chunk, typegroup, facegroup;
	int count;
	for(chunk = list_chunkchain; chunk; chunk = chunk.chunkchain)
		for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				for(count = 0; count < facegroup.numvertexes; count++)
				{
					facegroup.verts_staticrgb[count] = ambientlight;
					facegroup.verts[count].rgba[0] = ambientlight_x;
					facegroup.verts[count].rgba[1] = ambientlight_y;
					facegroup.verts[count].rgba[2] = ambientlight_z;
				}	
			
	ambientlightset = TRUE;			
	ResetStaticLights(TRUE);
}

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
						for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
						{
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

// This _Wrap function gives mods access to the relightstatic and relightdynamic fields before they are cleared. Use __wrap or __accumulate.
void ApplyLighting_Wrap()
{
	if(relightstatic)		
	for(entity light = list_staticlightchain; light; light = light.staticlightchain)
		SetVertLights(light, TRUE);

	if(relightdynamic || relightstatic)		
	for(entity light = list_dynamiclightchain; light; light = light.dynamiclightchain)
		SetVertLights(light, FALSE);	
}

void AddLights()
{
	int count = 0;
	vector rgb = '0 0 0';

	if(clientlight)
		clientlight.lightradius = autocvar_cq_clientlightradius;

	if(!ambientlightset)
		ResetAmbientLight();
	
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
			list_staticlitfacegroupchain.verts_staticrgb[count] = ambientlight;
			list_staticlitfacegroupchain.verts[count].rgba[0] = ambientlight_x;
			list_staticlitfacegroupchain.verts[count].rgba[1] = ambientlight_y;
			list_staticlitfacegroupchain.verts[count].rgba[2] = ambientlight_z;
		}
		
		StaticLitFaceGroupChain_Remove(list_staticlitfacegroupchain);
	}
	
	if(relightdynamic || relightstatic) // sets verts to base color: ambient or static
	while(list_litfacegroupchain)
	{
		for(count = 0; count < list_litfacegroupchain.numvertexes; count++)
		{
			rgb = list_litfacegroupchain.verts_staticrgb[count];
			list_litfacegroupchain.verts[count].rgba[0] = rgb_x;
			list_litfacegroupchain.verts[count].rgba[1] = rgb_y;
			list_litfacegroupchain.verts[count].rgba[2] = rgb_z;
		}
		
		LitFaceGroupChain_Remove(list_litfacegroupchain);
	}
	
	ApplyLighting_Wrap();
	
	relightstatic = FALSE;
	relightdynamic = FALSE;
}