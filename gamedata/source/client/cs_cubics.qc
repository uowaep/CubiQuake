void ClearChunkValues(entity chunk, int clearstaticlighttriggers, int removing)
{
	entity light = __NULL__, nexte = __NULL__;

//	chunk.findnetworkbloatent = FALSE;
	
	for(entity e = chunk.list_typegroupchain; e; e = nexte)
	{
		nexte = e.typegroupchain;
		
	//	if(!removing)
	//	if(e.blocktype <= BLOCKTYPE_DMG_10 && e.blocktype >= BLOCKTYPE_DMG_90)
	//		continue;
		
		RemoveTypeGroup(chunk, e);
	}
	
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

// chunk can also be a chunk bloat ent for storing data in queue
void UpdateChunkBuildData(entity chunk, float sendflags, int bloatstage, int clearmem)
{
	int memslot = 0, type = 0, getrotation = 0;//, bloatcount;
	int maxblocks = pow(chunksize, 3);
	
	chunk.numvisiblecubics = readshort();
	
	if(clearmem)
	{
		memfill8(chunk.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(chunk.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(chunk.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(chunk.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(chunk.cubic_health, 0, sizeof(int)*pow(chunksize, 3));
	}
	
	for(float count = 0; count < min(maxcubicupdates, chunk.numvisiblecubics-(maxcubicupdates*bloatstage)); count++)
	{
		memslot = readlong();//readshort();
		
//		memslot = 0;		
//		for(bloatcount = 0; bloatcount < maxblocks/255; bloatcount++)
//			memslot += readbyte();

	//	memslot = readbyte();
	//	memslot += readbyte();
	//	memslot += readbyte();

		if(!count)
			chunk.firstmemslot = memslot;		
		
		type = readbyte();		
		chunk.cubic_blocktype[memslot] = type;
		
		if(!NonSolidType(type))
		{
			chunk.cubic_blockshape[memslot] = readbyte();			
			chunk.cubic_cullbits[memslot] = readbyte();
			chunk.cubic_health[memslot] = readbyte();
			
			if(chunk.cubic_blockshape[memslot] != BLOCKSHAPE_CUBE)
				getrotation = TRUE;
		}	
		else
			getrotation = TRUE;
		
		if(getrotation)
			chunk.cubic_blockrotation[memslot] = readbyte();	
		
		getrotation = FALSE;
	}		
}

// for adding new cubic objects like the torch to mods
int LoadCubic_Wrap_Pre(entity chunk, int memslot, int type, int returnvalue)
{
	return returnvalue;
}

void LoadCubic_Wrap_Post(entity chunk, int memslot, int type, entity modelent){}

void LoadCubic(entity chunk, int memslot, int type)
{
	entity typegroup = __NULL__, modelent = __NULL__;	
	
	if(LoadCubic_Wrap_Pre(chunk, memslot, type, FALSE))
		return;
	
	switch(type)
	{
		// EXAMPLE CUBIC OBJECT : Light
		case BLOCKTYPE_TORCH:	modelent = SetChunkLight(chunk, memslot, type);	 // adds a light to the chunk of specified type (BLOCKTYPE_TORCH in this case)
								modelent.lightcolor = '1 0.9 0.7';				// overrides default value set in SetChunkLight()
								modelent.lightbrightness = 4;
								SetAnimation(modelent, 0, 6, 0.1, TRUE, FALSE, TRUE);	// Sets up the animation for this model.
								modelent.predraw = Predraw_Torch;	// set predraw func if necessary
								modelent.parentchunk = chunk;
								break;
		
		// default trisoup_simple cubic
		default:				for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
									if(typegroup.blocktype == type)
										break;
								if(!typegroup)	// texture set group for chunk
								{
									CreateTypeGroup(chunk, type);
								//	chunk.list_typegroupchain.lightcolor = ambientlight;		// NOTE: the .list_ chain entity is always the last added to the list (but this should only be trusted if it was just added)
								}
								
								break;
	}	
	
	LoadCubic_Wrap_Post(chunk, memslot, type, modelent);
}

void CopyBloatChunkValuesToChunk(entity bloatent, entity chunk, int bloatstage)
{
	int type = 0, slotcount = 0;
	
	for(float memslot = bloatent.firstmemslot; slotcount < min(maxcubicupdates, chunk.numvisiblecubics-(maxcubicupdates*bloatstage)); memslot++)
	{
		type = bloatent.cubic_blocktype[memslot];
		chunk.cubic_blocktype[memslot] = type;
		
		if(type)
		{
			if(!NonSolidType(type))
			{
				chunk.cubic_blockshape[memslot] = bloatent.cubic_blockshape[memslot];			
				chunk.cubic_blockrotation[memslot] = bloatent.cubic_blockrotation[memslot];
				chunk.cubic_cullbits[memslot] = bloatent.cubic_cullbits[memslot];
				chunk.cubic_health[memslot] = bloatent.cubic_health[memslot];
			}	
			
			slotcount++;
		}
	}	
}

void LoadChunkCubics(entity chunk)
{
	int loadcount = 0, type = 0;
	
	chunk.numdamagedcubics = 0;
	
	for(int memslot = 0; loadcount < chunk.numvisiblecubics && memslot < pow(chunksize, 3); memslot++)
	{
		type = chunk.cubic_blocktype[memslot];
		
		if(type)
		{
			if(chunk.cubic_health[memslot] > 0 && chunk.cubic_health[memslot] <= maxdmghealth)
				chunk.numdamagedcubics++;
			
			LoadCubic(chunk, memslot, type);
			loadcount++;
		}
	}
	
//	ClearChunkDamageFaces(chunk);
//	BuildChunkDamageFaces(chunk);
}

void ReadInitializeData(float sendflags)
{
	if(sendflags & SFL_INITIALIZE)
	{
		worldsize = readbyte();
		clustersize = readbyte();
		chunksize = readbyte();
		cubicradius = readbyte()*0.5;	// *0.5 because we sent 2x the radius as an integer instead of radius as a float when trying to support single quake unit sized cubics
		viewsize = readbyte();
		viewheight = readbyte();
		viewsize_distant = readbyte();
		viewheight_distant = readbyte();
		ambientlight_x = readcoord();
		ambientlight_y = readcoord();
		ambientlight_z = readcoord();
		ambientlight_modified = autocvar_cq_ambientlight;
		maxcubicupdates = readbyte();
		SetDependentViewValues();
		ambientlightset = FALSE;

		if(!client_initialized) // this is here instead of in CSQC_Init() to make sure the server has loaded worldsize and any other variables before running InitGameVariables().
		{
			InitGameVariables();
			client_initialized = TRUE;
			localcmd("cmd cq_initialized\n");	// tell the server to stop sending init info
		}
	}
}

void UpdateCubicHealth()
{
	int nobuild = FALSE;
	int chunkid = readlong();
	int cubicid = readlong();
	int cubichealth = readbyte();

	vector chunkorg = GetChunkOrigin(chunkid);
	int clusterid = GetClusterRef(GetNearClusterOrg(chunkorg));
	entity cluster = cluster_ent[clusterid];
		
	if(!cluster)
		return;

	entity chunk = cluster.chunk_ent[GetChunkRef(chunkorg-cluster.origin, __FUNC__)];
	
	if(!chunk)
		return;
	
	if(chunk.findnetworkbloatent)	// updating via network
		return;
	
	int oldhealth = chunk.cubic_health[cubicid];
	chunk.cubic_health[cubicid] = cubichealth;

	if(oldhealth > 0 && oldhealth <= maxdmghealth && cubichealth > maxdmghealth)
		chunk.numdamagedcubics--;	// was previously drawing damage, is no longer
	else
	if((oldhealth > maxdmghealth || oldhealth == 0) && cubichealth > 0 && cubichealth <= maxdmghealth)
		chunk.numdamagedcubics++;	// was not drawing damage for this cubic earlier, is now

	if(chunk.queuedamagefacebuildchain || chunk.queuedamagefacebuildchain_prev || chunk == list_queuedamagefacebuildchain)	// already rebuilding
		return;

	if(!chunk.drawingdamage)
		return;

	int oldlvl = GetFaceTypeForDamage(oldhealth);//ceil(oldhealth/dmghealthincrementsize);
	int newlvl = GetFaceTypeForDamage(cubichealth);//ceil(cubichealth/dmghealthincrementsize);
		
	if(oldlvl != newlvl)		
	{
		RemoveDamageFacesForCubic(chunk, cubicid, oldhealth);	// removes old shader
		AddDamageFacesForCubic(chunk, cubicid);	// need to allocate extra slots, and reallocate / rebuild with extra slots when those slots are full.
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

	entity e = __NULL__, nexte = __NULL__;
	int i = 0, numbloatentsfound = 0;
	vector org = '0 0 0';
	int clearmem = TRUE;
//	int oldupdateref = self.updateref;
	
	self.lastupdatetime = time;
	
	float sendflags = readlong();
	int ref = readbyte();

	ReadInitializeData(sendflags);
	
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
			self.cubic_health = memalloc(sizeof(int)*pow(chunksize, 3));
			clearmem = FALSE;
			
			org = GetChunkOrigin(i);
			setorigin(self, org);
//			setsize(self, '-25 -25 -25', '25 25 25');
			self.enttype = ENT_CHUNK;
			self.flags = FL_FINDABLE_NONSOLID;
			self.chunkid = i;
			ChunkChain_Add(self);	
			
			if(!clusters_allocated)
			{
				clusters_allocated = TRUE;
				cluster_ent = memalloc(sizeof(entity)*maxclusters);
			}		
			
			int clusterid = GetClusterRef(GetNearClusterOrg(org));
			entity cluster = cluster_ent[clusterid];

			if((cluster == list_ghostclusterchain && list_ghostclusterchain) || cluster.ghostclusterchain_prev)
				print("Warning: Trying to use ghosted cluster on client.\n");
			
			if(!cluster)
				cluster = SpawnCluster(clusterid);
			
			cluster.chunk_ent[GetChunkRef(self.origin-cluster.origin, __FUNC__)] = self;
			cluster.numchunks++;
			
		//	TriggerStaticLightReset(org);
		}
	}

	if(sendflags & SFL_BUILD)
	{
//		if(sendflags & SFL_DAMAGED)
//		if(!(sendflags & SFL_ISNEW))
//			print("damaged chunk\n");
		
		UpdateChunkBuildData(self, sendflags, 0, clearmem);
		
		if(ref <= self.updateref && !(ref < 100 && self.updateref >= 100))
		{
			dprint("Developer Notice: Caught out of order bloat.\n");
			return;
		}
		
		self.updateref = ref;

		QueueNearFaceBuildChain_Remove(self);
		QueueFaceBuildChain_Remove(self);
		QueueDamageFaceBuildChain_Remove(self);
	//	QueueDamageFaceRebuildChain_Remove(self);
		
		self.findnetworkbloatent = FALSE;

		int numbloatents = ceil((float)self.numvisiblecubics/maxcubicupdates)-1;
		
		for(e = list_queuechunkbloatchain; e; e = nexte)
		{
			nexte = e.queuechunkbloatchain;
			
			if(e.origin == self.origin)
			{
				QueueNearFaceBuildChain_Remove(e);
				QueueFaceBuildChain_Remove(e);
				QueueDamageFaceBuildChain_Remove(e);
	//			QueueDamageFaceRebuildChain_Remove(e);
				// FIXME: also don't remove faces from bloats so early (damage face removal would be here)
				
				if(e.updateref == self.updateref)
					continue;
				
				QueueChunkBloatChain_Remove(e);
				ChunkBloatChain_Remove(self, e);
			}
		}
		
		if(self.numvisiblecubics > maxcubicupdates)
		{
			for(e = list_queuechunkbloatchain; e; e = nexte)
			{
				nexte = e.queuechunkbloatchain;
				
				if(e.origin == self.origin)
				if(e.updateref == self.updateref)
				{
					numbloatentsfound++;
					CopyBloatChunkValuesToChunk(e, self, e.bloatlevel);
					QueueChunkBloatChain_Remove(e);
					ChunkBloatChain_Add(self, e);
				}
			}
			
			if(numbloatentsfound < numbloatents)
			{
				self.findnetworkbloatent = TRUE;//numbloatents-numbloatentsfound;
				self.recentsendflags = sendflags;
			}
		}

		if(!self.findnetworkbloatent)
		{
			ClearChunkValues(self, TRUE, FALSE);
			LoadChunkCubics(self);
		//	TriggerStaticLightReset(org);	
			
			QueueChunkFaceBuild(self, sendflags);

			for(e = self.list_chunkbloatchain; e; e = nexte)
			{
				nexte = e.chunkbloatchain;
				ChunkBloatChain_Remove(self, e);
			}
		}
	}
}

void UpdateChunkBloat()
{
	int i = 0, numbloatentsfound = 0;
	entity cluster = __NULL__, e = __NULL__, nexte = __NULL__, chunk = __NULL__;
	int clearmem = TRUE;
	int addbloattochunk = FALSE;	
	vector org = '0 0 0';
//	int oldupdateref = self.updateref;
	
	float sendflags = readlong();
	int ref = readbyte();
	
	ReadInitializeData(sendflags);

	if(sendflags & SFL_ISNEW)
	{
		i = readlong();	
		self.bloatlevel = readbyte();
		
		if(!self.chunkinitialized)
		{
			self.chunkinitialized = TRUE;
			
			self.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
			self.cubic_blockshape = memalloc(sizeof(int)*pow(chunksize, 3));
			self.cubic_blockrotation = memalloc(sizeof(int)*pow(chunksize, 3));		
			self.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
			self.cubic_health = memalloc(sizeof(int)*pow(chunksize, 3));
			clearmem = FALSE;
			
			self.enttype = ENT_CHUNKBLOAT;
			self.flags = FL_FINDABLE_NONSOLID;
			org = GetChunkOrigin(i);
			setorigin(self, org);
			
		//	TriggerStaticLightReset(org);
		}
	}

	if(sendflags & SFL_BUILD)
	{
//		if(sendflags & SFL_DAMAGED)
//		if(!(sendflags & SFL_ISNEW))
//			print("damaged bloat\n");		
		
		UpdateChunkBuildData(self, sendflags, self.bloatlevel, clearmem);

		if(ref <= self.updateref && !(ref < 100 && self.updateref >= 100))
		{
			dprint("Developer Notice: Caught out of order bloat.\n");
			return;	// this information is out of date. ignore it all. (it has been read to avoid a crash in UpdateChunkBuildData)
		}
		self.updateref = ref;
		
		QueueNearFaceBuildChain_Remove(self);
		QueueFaceBuildChain_Remove(self);
		QueueDamageFaceBuildChain_Remove(self);
	//	QueueDamageFaceRebuildChain_Remove(self);
		// FIXME: same as main chunk

		int clusterid = GetClusterRef(GetNearClusterOrg(self.origin));
		cluster = cluster_ent[clusterid];
		
		if(cluster)
			chunk = cluster.chunk_ent[GetChunkRef(self.origin-cluster.origin, __FUNC__)];
		
		if(chunk)
		{
			ChunkBloatChain_Remove(chunk, self);			
			
			for(e = chunk.list_chunkbloatchain; e; e = nexte)
			{
				nexte = e.chunkbloatchain;
				
				if(e.updateref == self.updateref)
					continue;
				
				QueueNearFaceBuildChain_Remove(e);
				QueueFaceBuildChain_Remove(e);
				QueueDamageFaceBuildChain_Remove(e);
			//	QueueDamageFaceRebuildChain_Remove(e);
				ChunkBloatChain_Remove(chunk, e);
			}
			
			if(chunk.updateref == self.updateref)
				addbloattochunk = TRUE;
		}
		
		if(addbloattochunk)
		{
			ChunkBloatChain_Add(chunk, self);
			
			for(e = chunk.list_chunkbloatchain; e; e = e.chunkbloatchain)
				numbloatentsfound++;

		//	ClearChunkValues(chunk, TRUE);
			CopyBloatChunkValuesToChunk(self, chunk, self.bloatlevel);
			QueueChunkBloatChain_Remove(self);

			if(numbloatentsfound == ceil((float)chunk.numvisiblecubics/maxcubicupdates)-1)
			{
				chunk.findnetworkbloatent = FALSE;
				ClearChunkValues(chunk, TRUE, FALSE);
				LoadChunkCubics(chunk);
			//	TriggerStaticLightReset(org);		
			
				QueueChunkFaceBuild(chunk, chunk.recentsendflags);
				
				for(e = chunk.list_chunkbloatchain; e; e = nexte)
				{
					nexte = e.chunkbloatchain;
					ChunkBloatChain_Remove(chunk, e);
				}
			}
		}
		else
			QueueChunkBloatChain_Add(self); // puts bloat in global chain so when the parent chunk update arrives it has a place to look for it and know that it is waiting to be updated to the chunk
	}
}

int maxfacesbuiltperframe = 1;

/*int DrawFaceGroupForChunkGrid(vector pos, int builtfaces)
{
	entity typegroup, facegroup, chunkent;
	
	vector nearchunkorg = GetNearChunkOrg(view_org);
	
	pos = nearchunkorg + pos*(chunksize*cubicradius*2);

	// CHECK WORLD BOUNDS
	if(pos_x >= worlddim_x*0.5 || pos_x <= worlddim_x*-0.5
	|| pos_y >= worlddim_y*0.5 || pos_y <= worlddim_y*-0.5
	|| pos_z >= worlddim_z*0.5 || pos_z <= worlddim_z*-0.5)
		return builtfaces;	

	entity e = GetChunkForLocation(__NULL__, pos);
	
	if(e)
	{
		
		if(e.queuedforfacebuild == 1)
		{
			if(builtfaces < maxfacesbuiltperframe)
			{
				BuildChunkFaces(e);
				e.queuedforfacebuild++;
				builtfaces++;
			}
			else
				return builtfaces;
		}		
		
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(facegroup, pos);
			
		for(chunkent = e.list_chunkentchain; chunkent; chunkent = chunkent.chunkentchain)
		{
			chunkent.drawmask = MASK_NORMAL;
			ClearChunkEntChain_Add(chunkent);
		}
	}
	
	return builtfaces;
}*/

void DrawChunks()
{
	entity typegroup = __NULL__, facegroup = __NULL__, editchunk = __NULL__;
//	vector pos, dist;
	int drawplane = 0, builtfaces = 0;
	
/*	vector nearchunkorg = GetNearChunkOrg(view_org);

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
	}*/

//	int drawplane = 0;
//	totalvertcount = 0;
/*	for(entity e = list_chunkchain; e; e = e.chunkchain)
	{
		if(editor_infoedit)
		if(e.chunkid != editor_editchunk)
			continue;
		
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
				DrawFaceGroup(typegroup, facegroup);
	}*/
			
	for(facegroup = list_drawfacegroupchain; facegroup; facegroup = facegroup.drawfacegroupchain)
				DrawFaceGroup(facegroup.typegroupent, facegroup);	
			
			
//print(ftos(totalvertcount), "\n");
/*	int numgroupsdrawn = 0;
	int maxgroupsdrawn = 1;

	int viewrange = ((max(maxviewsize, maxviewheight)*clustersize)+(1))*0.5;		
	
	viewrange = viewrange*(0.5+(120*frametime));//(maxgroupsdrawn/numfacegroups);
	
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
	

	
	for(int range = -1; range <= viewrange && numgroupsdrawn < maxgroupsdrawn; range++)
	{
		if(drawplane == 1)
		{
			pos_x = range*draw_ofs_x;
			for(pos_z = -viewrange; pos_z <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_z++)
				for(pos_y = -viewrange; pos_y <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_y++)
				{
					builtfaces += DrawFaceGroupForChunkGrid(pos, builtfaces);
				//	numgroupsdrawn++;
				}
		}
		else
		if(drawplane == 2)
		{
			pos_y = range*draw_ofs_y;
			for(pos_z = -viewrange; pos_z <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_z++)
				for(pos_x = -viewrange; pos_x <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_x++)
				{
					builtfaces += DrawFaceGroupForChunkGrid(pos, builtfaces);
				//	numgroupsdrawn++;
				}
		}
		else
		if(drawplane == 0)
		{
			pos_z = range*draw_ofs_z;
			for(pos_x = -viewrange; pos_x <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_x++)
				for(pos_y = -viewrange; pos_y <= viewrange && numgroupsdrawn < maxgroupsdrawn; pos_y++)
				{
					builtfaces += DrawFaceGroupForChunkGrid(pos, builtfaces);
				//	numgroupsdrawn++;
				}
		}
	}*/
}

void DrawChunkDamage()
{
	for(entity facegroup = list_drawdamagefacegroupchain; facegroup; facegroup = facegroup.drawdamagefacegroupchain)
		DrawFaceGroup(facegroup.typegroupent, facegroup);	
}

vector GetIntercept(vector line_start, vector line_end, vector edge_offset)
{
	vector runrise = line_end - line_start;
	float slope = runrise_y/runrise_x;
	vector point = line_start - edge_offset;
	
	// point_y = slope*point_x + yintercept;
	vector intercept;
	intercept_x = 0;
	intercept_y = point_y - slope*point_x;
	intercept += edge_offset;
	
	return intercept;	
}

vector GetInterceptInverted(vector line_start, vector line_end, vector edge_offset)
{
	vector runrise = line_end - line_start;
	float slope = runrise_x/runrise_y;
	vector point = line_start - edge_offset;
	
	// point_y = slope*point_x + yintercept;
	vector intercept;
	intercept_y = 0;
	intercept_x = point_x - slope*point_y;
	intercept += edge_offset;
	
	return intercept;	
}

int		tracelinetoplane_behindplane;
vector TraceLineToPlane(vector line_start, vector line_end, vector plane_normal, vector plane_point)
{
	tracelinetoplane_behindplane = FALSE;
	
    vector v = line_end-line_start;
    vector n = plane_normal;
    float d = -(plane_normal*plane_point);
	
    // dot products
    float dot1 = n*v;
    float dot2 = n*line_start;

	if(plane_normal*(line_end-plane_point) > 0) // the end isn't on or behind the plane (ignores reverse intersection, and non-intersections)
		return line_end;
	else
	if(plane_normal*(line_start-plane_point) <= 0) // both ends are behind the plane (or on it)
	{
		tracelinetoplane_behindplane = TRUE;
		return line_end;
	}

	// line is parallel with plane
     if(dot1 == 0)
        return line_end; // return original end point

    float t = -(dot2 + d) / dot1;
    return line_start + (t * v);
}

void DrawGridLine(vector baseorg, vector pos, vector direction, float cellsize, int gridsize, vector rgb, float gridalpha)
{
	vector line_start = baseorg + (pos - '0.5 0.5 0.5'*(gridsize-1))*cellsize;
	vector line_end = line_start + direction*(gridsize-1)*cellsize;
		
	vector line_start_p = TraceLineToPlane(line_end, line_start, view_normal, view_point);
	
	if(tracelinetoplane_behindplane)
		return;
	
	vector line_end_p = TraceLineToPlane(line_start, line_end, view_normal, view_point);

	if(tracelinetoplane_behindplane)
		return;
	
	line_start = project(line_start_p);
	line_end = project(line_end_p);

	drawline(4, line_start, line_end, rgb, gridalpha);	
}

void DrawGrid(vector baseorg, float cellsize, int gridsize, vector rgb, float gridalpha)
{
	vector pos = '0 0 0';
	
	for(pos_x = 0; pos_x < gridsize; pos_x++)
		for(pos_y = 0; pos_y < gridsize; pos_y++)
			DrawGridLine(baseorg, pos, '0 0 1', cellsize, gridsize, rgb, gridalpha);

	pos_y = 0;
	for(pos_x = 0; pos_x < gridsize; pos_x++)
		for(pos_z = 0; pos_z < gridsize; pos_z++)
		DrawGridLine(baseorg, pos, '0 1 0', cellsize, gridsize, rgb, gridalpha);
		
	pos_x = 0;
	for(pos_y = 0; pos_y < gridsize; pos_y++)
		for(pos_z = 0; pos_z < gridsize; pos_z++)
		DrawGridLine(baseorg, pos, '1 0 0', cellsize, gridsize, rgb, gridalpha);		
}

void DrawGrids()
{
	if(cvar("cq_showchunkoutline"))
		DrawGrid(GetNearChunkOrg(view_org), chunksize*cubicradius*2, 2, '0 1 1', 0.4);
//	DrawGrid(GetNearestCubicOrigin(view_org+view_normal*80, chunksize_iseven), cubicradius*2, 2, '1 1 1', 0.2);
}

void InitializeClientSettings()
{


}