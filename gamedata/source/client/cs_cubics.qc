void RemoveLight(entity chunk, entity light, int clearstaticlighttriggers, int removesource)
{
	if(light.staticlno)
	{
		dynamiclight_set(light.staticlno, LFIELD_RADIUS, 0);
		light.staticlno = 0;
	}	
	
	if(clearstaticlighttriggers)
		ClearStaticLightResetTriggersForLight(light);		
	
	StaticLightChain_Remove(light);
	DynamicLightChain_Remove(light);
	ChunkLightChain_Remove(chunk, light);
//	ChunkEntChain_Remove(chunk, light);
//	ClearChunkEntChain_Remove(light);
	if(removesource)
		Remove(light);	
}

void ClearChunkValues(entity chunk, int clearstaticlighttriggers, int removing)
{
	entity light = __NULL__, nexte = __NULL__;

	for(entity e = chunk.list_typegroupchain; e; e = nexte)
	{
		nexte = e.typegroupchain;
		RemoveTypeGroup(chunk, e);
	}
	
	while(chunk.list_chunklightchain)
	{
		light = chunk.list_chunklightchain;
		RemoveLight(chunk, light, clearstaticlighttriggers, TRUE);
	}
	
	while(chunk.list_cubicobjchain)
		Remove(chunk.list_cubicobjchain);
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
		memfill8(chunk.cubic_flags, 0, sizeof(int)*pow(chunksize, 3));
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
		
	//	if(!NonSolidType(type, FALSE))
		if(type < baseobjecttypeid)	
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
		
		chunk.cubic_flags[memslot] = readbyte();

		getrotation = FALSE;
	}		
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
//			if(!NonSolidType(type, FALSE))
			if(type < baseobjecttypeid)	
			{
				chunk.cubic_blockshape[memslot] = bloatent.cubic_blockshape[memslot];			
				chunk.cubic_cullbits[memslot] = bloatent.cubic_cullbits[memslot];
				chunk.cubic_health[memslot] = bloatent.cubic_health[memslot];
			}	
			
			chunk.cubic_blockrotation[memslot] = bloatent.cubic_blockrotation[memslot];
			chunk.cubic_flags[memslot] = bloatent.cubic_flags[memslot];
			
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
		ambientlight_modified_x = max(0.01, ambientlight_modified_x);
		ambientlight_modified_y = max(0.01, ambientlight_modified_y);
		ambientlight_modified_z = max(0.01, ambientlight_modified_z);
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
		RemoveDamageFacesForCubic(chunk, cubicid, oldhealth);	// removes old polygons from previous dmg lvl's facegroup
		AddDamageFacesForCubic(chunk, cubicid);	// need to allocate extra slots, and reallocate / rebuild with extra slots when those slots are full.
	}
}

void UpdateCubicFlags()
{
	int chunkid = readlong();
	int cubicid = readlong();
	int cubicflags = readbyte();

	if(!client_initialized)
		return;

	vector chunkorg = GetChunkOrigin(chunkid);
	int clusterid = GetClusterRef(GetNearClusterOrg(chunkorg));
	entity cluster = cluster_ent[clusterid];
		
	if(!cluster)
		return;

	entity chunk = cluster.chunk_ent[GetChunkRef(chunkorg-cluster.origin, __FUNC__)];
	
	if(!chunk)
		return;
	
	if(chunk.findnetworkbloatent)	// already updating
		return;
	
	int oldflags = chunk.cubic_flags[cubicid];
	chunk.cubic_flags[cubicid] = cubicflags;

	entity e = __NULL__;
	for(e = chunk.list_cubicobjchain; e; e = e.cubicobjchain)
	{
		if(e.cubicmemslot == cubicid)
			break;
	}
	
	if(!e)
		return;
	
	e.ob_flags = cubicflags;
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
			self.cubic_flags = memalloc(sizeof(int)*pow(chunksize, 3));
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

	//	QueueNearFaceBuildChain_Remove(self);
	//	QueueNearDamageFaceBuildChain_Remove(self);
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
		//		QueueNearFaceBuildChain_Remove(e);
		//		QueueNearDamageFaceBuildChain_Remove(e);
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
			self.cubic_flags = memalloc(sizeof(int)*pow(chunksize, 3));
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
		
//		QueueNearFaceBuildChain_Remove(self);
//		QueueNearDamageFaceBuildChain_Remove(self);
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
				
//				QueueNearFaceBuildChain_Remove(e);
//				QueueNearDamageFaceBuildChain_Remove(e);
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

void DrawFaces()
{
	entity typegroup = __NULL__, facegroup = __NULL__, editchunk = __NULL__;
	int drawplane = 0, builtfaces = 0;
			

	for(facegroup = list_drawfacegroupchain; facegroup; facegroup = facegroup.drawfacegroupchain)
//	for(facegroup = listend_drawfacegroupchain; facegroup; facegroup = facegroup.drawfacegroupchain_prev)
		DrawFaceGroup(facegroup.typegroupent, facegroup);	
		
	tss_batchsize = 0;
}

void DrawFaceDamage()
{
	for(entity facegroup = list_drawdamagefacegroupchain; facegroup; facegroup = facegroup.drawdamagefacegroupchain)
		DrawFaceGroup(facegroup.typegroupent, facegroup);	
		
	tss_batchsize = 0;
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