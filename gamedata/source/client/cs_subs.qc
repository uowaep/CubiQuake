entity Remove(entity e)
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
		ClearChunkValues(e);
		ChunkChain_Remove(e);
	}
	
	// remove this entity
	remove(e);
	
	return __NULL__;
}