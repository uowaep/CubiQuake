void Remove(entity e)
{
	#ifdef DEBUG
	if(wasfreed(e))
		print("CS_Remove A wasfreed.\n");
	#endif
	
	// remove from global chains

	// mute and end looped sound
//	EndLoopedSound(e);
//	EndBodySound(e);
	
	if(e.enttype == ENT_CHUNK)
	{
		ClearChunkValues(e, FALSE);
		if(e.chunkinitialized)
			FreeChunkAllocations(e);

		entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(e.origin));
		if(cluster)
		{
			cluster.chunk_ent[GetChunkRef(e.origin-cluster.origin)] = __NULL__;
			cluster.numchunks -= 1;
			
			if(!cluster.numchunks)
			if(!cluster.islit)
				GhostCluster(cluster);
		}

/*		e.numvisiblecubics = 0;
		e.flags = 0;
		e.enttype = 0;
		setorigin(e, '0 0 0');

		memfill8(e.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
		memfill8(e.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
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
		
		entity chunk = GetChunkForLocation(__NULL__, e.origin);
		if(chunk)
			ChunkBloatChain_Remove(chunk, e);

	}
	
	QueueNearFaceBuildChain_Remove(e);
	QueueFaceBuildChain_Remove(e);
	QueueChunkBloatChain_Remove(e);
	
	// remove this entity
	remove(e);
}

void ListWorlds()
{
	string s;
	
	float h = search_begin("data/worlds/*", FALSE, FALSE);
	float n = search_getsize(h);

	print("Worlds:\n");

	for(int count = 0; count < n; count++)
	{
		s = search_getfilename(h, count);
		print(substring(s, 12, strlen(s)-12-1), "\n");
	}
	
	search_end(h);
}