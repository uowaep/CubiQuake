void ClientToggleLight()
{
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
	clientlight.lightradius = 192;
	clientlight.lightbrightness = 2;
	clientlight.lightcolor = '1 0.9 0.7';
}

void ResetStaticLights(int forcerelight)
{
	if(forcerelight)
		static_relighttime = time;
	else
	if(!static_relighttime)
		static_relighttime = time + lightupdatedelay_static;	// the delay is to allow more shared server/client ents to update, thus requiring less calls to reset static lighting
}

void ResetAmbientLight()
{
	entity chunk, typegroup, facegroup;
	int count;
//	ambientlight = autocvar_ambientlight;
	for(chunk = list_chunkchain; chunk; chunk = chunk.chunkchain)
		for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
			{
				for(count = 0; count < facegroup.numvertexes; count++)
				{
					facegroup.verts_staticrgb[count] = ambientlight;
					facegroup.verts[count].rgba[0] = ambientlight_x;
					facegroup.verts[count].rgba[1] = ambientlight_y;
					facegroup.verts[count].rgba[2] = ambientlight_z;
				}	
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
	
	int flagfield = cluster.chunk_flags[GetChunkRef(org-clusterorg)];
	cluster.chunk_flags[GetChunkRef(org-clusterorg)] = flagfield | CHFL_TRIGGERSTATICLIGHTS;
}

void TriggerStaticLightReset(vector org)
{
	vector clusterorg = GetNearClusterOrg(org);
	entity cluster = GetClusterForLocation(__NULL__, clusterorg);
	
	if(!cluster)
		return;

	int chunkid = GetChunkRef(org-clusterorg);
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

	int flagfield = cluster.chunk_flags[GetChunkRef(org-clusterorg)];
	flagfield = flagfield - (flagfield & CHFL_TRIGGERSTATICLIGHTS);
	cluster.chunk_flags[GetChunkRef(org-clusterorg)] = flagfield;
}

void ClearStaticLightResetTriggersForLight(entity light)
{
	float lightradiusdotp, lightsize;
	int lrad;
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
	light.lightradius = 192;
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
	vector vertpos, facergb, ofs, chunkpos, rgb, lastrgb, lightchunkorg, target;
	float lightsize, ofsdotp, lightradiusdotp;
	entity typegroup, facegroup;
	int	count, facegroupislit, lrad;
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

				chunk = GetChunkForLocation(__NULL__, target);

				if(isstatic)
					SetStaticLightResetTrigger(target);

				if(chunk)
				{
					cluster = GetClusterForLocation(cluster, GetNearClusterOrg(chunk.origin));
					
					if(chunk.list_typegroupchain)
					for(typegroup = chunk.list_typegroupchain; typegroup != world; typegroup = typegroup.typegroupchain)
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
									rgb = lastrgb = light.lightcolor*light.lightbrightness*(1-(vlen(ofs)/lrad));

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

void AddLights()
{
	entity light;
	int count;
	vector rgb;

	if(!ambientlightset)//ambientlight != autocvar_ambientlight)	// checks if ambientlight cvar has changed. for building prefabs. FIXME: let server/world force this value.
		ResetAmbientLight();

	if((static_relighttime && time >= static_relighttime) || time >= dynamic_relighttime)
	{
		if(static_relighttime && time >= static_relighttime)
		{
			relightstatic = TRUE;
			static_relighttime = 0;
		}
		
		relightdynamic = TRUE;
		dynamic_relighttime = time+lightupdatedelay_dynamic;//0.02;	// dynamic light update delay
	}
	
	if(relightstatic)
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

	
	if(relightdynamic || relightstatic)
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
	
	if(relightstatic)	
	for(light = list_staticlightchain; light; light = light.staticlightchain)
		SetVertLights(light, TRUE);
		
	if(relightdynamic || relightstatic)	
	for(light = list_dynamiclightchain; light; light = light.dynamiclightchain)
		SetVertLights(light, FALSE);
	
	relightstatic = FALSE;
	relightdynamic = FALSE;
}