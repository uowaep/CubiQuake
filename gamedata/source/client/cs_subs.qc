void CleanUp_Remove (entity e)
{
	#ifdef DEBUG
	if(wasfreed(e))
		print("CS_Remove A wasfreed.\n");
	#endif
	
	// remove from global chains

	// mute and end looped sound
//	EndLoopedSound(e);
//	EndBodySound(e);
	
	entity chunk;
	
	if(e.enttype == ENT_CHUNK)
	{
		while(e.list_chunkbloatchain)
			ChunkBloatChain_Remove(e, e.list_chunkbloatchain);

		if(e.list_chunklightchain)	// this unlights faces that were lit by lights that are now past the edge of the loaded world, but this also unlights faces near a chunk that was removed because it's last visible cubic was a light that was removed
			ResetStaticLights(FALSE);
		
		ClearChunkValues(e, FALSE, TRUE);

		if(e.chunkinitialized)
			FreeChunkAllocations(e);

		entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(e.origin));
		if(cluster)
		{
			cluster.chunk_ent[GetChunkRef(e.origin-cluster.origin, __FUNC__)] = __NULL__;
			cluster.numchunks -= 1;

			if(!cluster.numchunks)
			if(!cluster.islit)
			{
//				cluster_ent[GetClusterRef(cluster.origin)] = __NULL__;
//				memfree(cluster.chunk_ent);
//				memfree(cluster.chunk_flags);
//				Remove(cluster);
				GhostCluster(cluster);
			}
		}

/*		e.numvisiblecubics = 0;
		e.flags = 0;
		e.enttype = 0;
		setorigin(e, '0 0 0');

		memfill8(e.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_health, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_flags, 0, sizeof(int)*pow(chunksize, 3));
	*/

		ChunkChain_Remove(e);
	//	GhostChunkChain_Add(e);
	//	return;
	
	
	
	}
	else
	if(e.enttype == ENT_CHUNKBLOAT)
	{
		if(e.chunkinitialized)
			FreeChunkAllocations(e);
		QueueChunkBloatChain_Remove(e);
		
		chunk = GetChunkForLocation(__NULL__, e.origin, __FUNC__);
		if(chunk)
			ChunkBloatChain_Remove(chunk, e);

	}
	
	// FIXME: this is already happening in RemoveLight(), could probably remove this here
	if(e.staticlno)
	{
		dynamiclight_set(e.staticlno, LFIELD_RADIUS, 0);
		e.staticlno = 0;
	}
	
	// FIXME: look for larger allocations to ghost, but only small allocations should ever see this
	for(entity typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
		while(typegroup.list_facegroupchain)
		{
		//	print("testA\n");
			RemoveFaceGroup(typegroup, typegroup.list_facegroupchain, FALSE);
		}
		
	while(e.list_facegroupchain)
	{
	//	print("testB\n");
		RemoveFaceGroup(e, e.list_facegroupchain, FALSE);	
	}
	BlockObjectChain_Remove(e);
	
	QueueNearFaceBuildChain_Remove(e);
	QueueNearDamageFaceBuildChain_Remove(e);
	QueueFaceBuildChain_Remove(e);
	QueueDamageFaceBuildChain_Remove(e);
//	QueueDamageFaceRebuildChain_Remove(e);

	if(e.enttype == ENT_CUBICOBJ)
	{
	//	chunk = GetChunkForLocation(__NULL__, e.origin, __FUNC__);
		if(e.parentchunk)
			CubicObjChain_Remove(e.parentchunk, e);
		else
			print("Missing parent chunk on removed cubic object. CSQC\n");
	}
	
	LightEntChain_Remove(e);
	RelightEntChain_Remove(e);
}

void Remove(entity e)
{
	CleanUp_Remove(e);
	
	// remove this entity
	remove(e);
}

void ListWorlds()
{
	string s;
	
	float h = search_begin("data/worlds/*", TRUE, FALSE);
	float n = search_getsize(h);

	print("Worlds:\n");

	for(int count = 0; count < n; count++)
	{
		s = search_getfilename(h, count);
		print(substring(s, 12, strlen(s)-12-1), "\n");
	}
	
	search_end(h);
}

void ReadAnimation(entity e)
{
	float startframe	= readbyte();
	float endframe		= readbyte();
	float looping		= readbyte();
	float framedur		= readshort();
	SetAnimation(e, startframe, endframe, framedur, looping, TRUE, FALSE);	
}