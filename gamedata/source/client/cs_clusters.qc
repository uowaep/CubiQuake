entity SpawnCluster(int clusterid)
{
	entity cluster;
	
	if(list_ghostclusterchain)
	{
		cluster = list_ghostclusterchain;
		GhostClusterChain_Remove(cluster);
	}
	else
	{
		cluster = spawn();
		cluster.chunk_ent = memalloc(sizeof(entity)*pow(clustersize, 3));
		cluster.chunk_flags = memalloc(sizeof(int)*pow(clustersize, 3));
	}
	
	setorigin(cluster, GetClusterOffset(clusterid));
	cluster_ent[clusterid] = cluster;
	
	return cluster;
}

void GhostCluster(entity cluster)
{
	memfill8(cluster.chunk_ent, __NULL__, sizeof(entity)*pow(clustersize, 3));
	memfill8(cluster.chunk_flags, 0, sizeof(int)*pow(clustersize, 3));
	GhostClusterChain_Add(cluster);
}