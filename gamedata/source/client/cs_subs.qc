void Remove(entity e)
{
	if(wasfreed(e))
	{print("\n removing free ent?\n\n");
		eprint(e);
	}
	
	// remove from global chains

	// mute and end looped sound
//	EndLoopedSound(e);
//	EndBodySound(e);
	
	if(e.enttype == ENT_CHUNK)
	{
		ClearChunkValues(e, FALSE);
		FreeChunkAllocations(e);

		entity cluster = GetClusterForLocation(__NULL__, GetNearClusterOrg(e.origin));
		if(cluster)
		{
			cluster.chunk_ent[GetChunkRef(e.origin-cluster.origin)] = __NULL__;
			cluster.numchunks -= 1;
			
			if(!cluster.numchunks)
			if(!cluster.islit)
			{
				cluster_ent[GetClusterRef(cluster.origin)] = __NULL__;
			//	memfree(cluster.chunk_ent);
				GhostCluster(cluster);
//				Remove(cluster);
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
	*/
	
		ChunkChain_Remove(e);
	//	GhostChunkChain_Add(e);
	//	return;
	}
	
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