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

void BuildFacesForShape(entity typegroup, int blockshape, int blockrotation, int cullbits, vector cubicposition, int numchunkcubics)
{
	switch(blockshape)
	{
		case BLOCKSHAPE_CUBE:														BuildFaces_Cube(typegroup, cullbits, cubicposition, numchunkcubics);						break;
		
		case BLOCKSHAPE_RAMP:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Ramp(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);			else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Ramp_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Ramp_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Ramp_CW(typegroup, ConvertRotation(blockrotation, -2, -1), cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Ramp_UD(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics);	break;
									
		case BLOCKSHAPE_WEDGETIP:	if(blockrotation <= BLOCKROTATION_S)			BuildFaces_WedgeTip(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics); 	else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_WedgeTip_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_WedgeTip_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_WedgeTip_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_WedgeTip_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_WedgeTip_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	break;
									
		case BLOCKSHAPE_WEDGE:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Wedge(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics); 		else	
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Wedge_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics); 	else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Wedge_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics); 	else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Wedge_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);	else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Wedge_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);		else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_Wedge_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics);		break;		
	}
}

void BuildChunkFaces(entity chunk, int isnew)
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
	
	if(!isnew)
		ResetStaticLights(TRUE);	// cubics were added or removed so chunk faces need to be relit
}

void ClearChunkValues(entity chunk, int clearstaticlighttriggers)
{
	entity light;
	
	while(chunk.list_typegroupchain)
		RemoveTypeGroup(chunk, chunk.list_typegroupchain);
	
	while(chunk.list_chunklightchain)
	{
		light = chunk.list_chunklightchain;
		
		if(clearstaticlighttriggers)
			ClearStaticLightResetTriggersForLight(light);		
		
		StaticLightChain_Remove(light);
		DynamicLightChain_Remove(light);
		ChunkLightChain_Remove(chunk, light);
		ChunkEntChain_Remove(chunk, light);
		ClearChunkEntChain_Remove(light);
		Remove(light);
	}
}

void UpdateChunk()
{
/*	if(self == world)
	{
		if(list_ghostchunkchain)
		{
			self = list_ghostchunkchain;
			GhostChunkChain_Remove(self);
		}
		else
			self = spawn();
	}*/
	
	float sendflags = readlong();

	int i, memslot, type;
	vector org;
	entity typegroup, light;

	if(sendflags & SFL_INITIALIZE)
	{
		worldsize = readlong();
		viewsize = readlong();
		viewheight = readlong();
		viewsize_distant = readlong();
		viewheight_distant = readlong();
		ambientlight_x = readcoord();
		ambientlight_y = readcoord();
		ambientlight_z = readcoord();
		SetDependentViewValues();
		ambientlightset = FALSE;

		if(!client_initialized) // this is here instead of in CSQC_Init() to make sure the server has loaded worldsize and any other variables before running InitGameVariables().
		{	
			InitGameVariables();
			client_initialized = TRUE;
		}
		
		localcmd("cmd initialized\n");	// tell the server to stop sending init info
	}
	
	if(sendflags & SFL_ISNEW)
	{
		i = readlong();		
		
		if(!self.chunkinitialized)
		{
			self.chunkinitialized = TRUE;
			
			self.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
			self.cubic_blockshape = memalloc(sizeof(int)*pow(chunksize, 3));
			self.cubic_blockrotation = memalloc(sizeof(int)*pow(chunksize, 3));		
			self.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
		
			org = GetChunkOrigin(i);
			setorigin(self, org);
			self.enttype = ENT_CHUNK;
			self.flags = FL_FINDABLE_NONSOLID;
			ChunkChain_Add(self);
		
			
			if(!clusters_allocated)
			{
				clusters_allocated = TRUE;
				cluster_ent = memalloc(sizeof(entity)*maxclusters);		
			}		
			
			int clusterid = GetClusterRef(GetNearClusterOrg(org));
			entity cluster = cluster_ent[clusterid];
			
			if((cluster == list_ghostclusterchain && list_ghostclusterchain) || cluster.ghostclusterchain)
				print("Warning: Trying to use ghosted cluster on client.\n");
			
			if(!cluster)
				cluster = SpawnCluster(clusterid);
			
			cluster.chunk_ent[GetChunkRef(self.origin-cluster.origin)] = self;
			cluster.numchunks++;
			
			TriggerStaticLightReset(org);
		}
	}

	if(sendflags & SFL_BUILD)
	{
		ClearChunkValues(self, TRUE);
		
		self.numvisiblecubics = readshort();
		
		if(!(sendflags & SFL_ISNEW))
		{
			memfill8(self.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
			memfill8(self.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
			memfill8(self.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
			memfill8(self.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
		}
		
		for(float count = 0; count < self.numvisiblecubics; count++)
		{
			memslot = readshort();
			type = readbyte();
			self.cubic_blocktype[memslot] = type;
			
			switch(type)
			{
				// EXAMPLE CUBIC OBJECT : Light
				case BLOCKTYPE_TORCH:	light = SetChunkLight(self, memslot, type);	 // adds a light to the chunk of specified type (BLOCKTYPE_TORCH in this case)
										light.lightcolor = '1 0.9 0.7';				// overrides default value set in SetChunkLight()
										SetAnimation(light, 0, 6, 0.1, TRUE, FALSE, TRUE);	// You may want to use your own animation code. This is just a hacky example.
										light.predraw = Predraw_Torch;	// set predraw func if necessary
										break;
				
				// default trisoup_simple cubic
				default:				self.cubic_blockshape[memslot] = readbyte();			
										self.cubic_blockrotation[memslot] = readbyte();
										self.cubic_cullbits[memslot] = readbyte();
										for(typegroup = self.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
											if(typegroup.blocktype == type)
												break;
										if(!typegroup)	// texture set group for chunk
										{
											CreateTypeGroup(self, type);
											self.list_typegroupchain.lightcolor = ambientlight;		// NOTE: the .list_ chain entity is always the last added to the list (but this should only be trusted if it was just added)
										}
										
										break;
			}
		}
	
		BuildChunkFaces(self, sendflags & SFL_ISNEW);
	}
}

void DrawFaceGroupForChunkGrid(vector pos)
{
	entity typegroup, facegroup, chunkent;
	
	vector nearchunkorg = GetNearChunkOrg(view_org);
	
	pos = nearchunkorg + pos*(chunksize*cubicradius*2);

	// CHECK WORLD BOUNDS
	if(pos_x >= worlddim_x*0.5 || pos_x <= worlddim_x*-0.5
	|| pos_y >= worlddim_y*0.5 || pos_y <= worlddim_y*-0.5
	|| pos_z >= worlddim_z*0.5 || pos_z <= worlddim_z*-0.5)
		return;	

	entity e = GetChunkForLocation(__NULL__, pos);
	if(e)
	{
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(facegroup, pos);
			
		for(chunkent = e.list_chunkentchain; chunkent; chunkent = chunkent.chunkentchain)
		{
			chunkent.drawmask = MASK_NORMAL;
			ClearChunkEntChain_Add(chunkent);
		}
	}
}

void DrawChunks()
{
	entity typegroup, facegroup;
//	vector pos, dist;

	vector nearchunkorg = GetNearChunkOrg(view_org);

	if(nearchunkorg != playerchunkorg)
	{
		if(!setchunkloadofs)	// leaves chunkloadofs null until there is movement so player can spawn away from '0 0 0'
			setchunkloadofs = TRUE;
		else
		{
			client_hasmoved = TRUE;
			chunkloadofs = (playerchunkorg - nearchunkorg);///(chunksize*cubicradius*2);
		}
		playerchunkorg = nearchunkorg;
	}
	
	while(list_clearchunkentchain)
	{
		list_clearchunkentchain.drawmask = 0;
		ClearChunkEntChain_Remove(list_clearchunkentchain);
	}

//	int drawplane = 0;
	
	for(entity e = list_chunkchain; e; e = e.chunkchain)
	{
		if(e.hidden)
			continue;
		
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(facegroup, e.origin);
	}
			
/*	int viewrange = ((max(maxviewsize, maxviewheight)*clustersize)+(1))*0.5;		
	
	makevectors(view_ang);
	vector draw_ofs = [rint(v_forward_x), rint(v_forward_y), rint(v_forward_z)];
	
	dist_x = PositiveValue(v_forward_x);
	dist_y = PositiveValue(v_forward_y);
	dist_z = PositiveValue(v_forward_z);
	
	if(dist_x > dist_y && dist_x > dist_z)
		drawplane = 1;
	else
	if(dist_y > dist_x && dist_y > dist_z)
		drawplane = 2;
	
	for(int range = -1; range <= viewrange; range++)
	{
		if(drawplane == 1)
		{
			pos_x = range*draw_ofs_x;
			for(pos_z = -viewrange; pos_z <= viewrange; pos_z++)
				for(pos_y = -viewrange; pos_y <= viewrange; pos_y++)
					DrawFaceGroupForChunkGrid(pos);
		}
		else
		if(drawplane == 2)
		{
			pos_y = range*draw_ofs_y;
			for(pos_z = -viewrange; pos_z <= viewrange; pos_z++)
				for(pos_x = -viewrange; pos_x <= viewrange; pos_x++)
					DrawFaceGroupForChunkGrid(pos);
		}
		else
		if(drawplane == 0)
		{
			pos_z = range*draw_ofs_z;
			for(pos_x = -viewrange; pos_x <= viewrange; pos_x++)
				for(pos_y = -viewrange; pos_y <= viewrange; pos_y++)
					DrawFaceGroupForChunkGrid(pos);
		}
	}*/
}