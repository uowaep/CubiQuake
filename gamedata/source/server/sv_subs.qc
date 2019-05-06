void Remove(entity e)
{
	ProjectileChain_Remove(e);
	UnusedCubicBBoxChain_Remove(e);
	UnoccupiedClusterChain_Remove(e);
	
	while(e.list_cubicbboxchain)
		Remove(e.list_cubicbboxchain);
	
	if(e.parentchunk)
		CubicBBoxChain_Remove(e.parentchunk, e);
		
	remove(e);
}