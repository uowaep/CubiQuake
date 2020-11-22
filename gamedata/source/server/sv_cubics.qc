void GhostChunk(entity cluster, entity chunk)
{
	cluster.chunk_ent[GetChunkRef(chunk.origin-cluster.origin, __FUNC__)] = __NULL__;
	
	while(chunk.list_cubicbboxchain)
	{
		#ifdef DEBUG
		if(wasfreed(chunk.list_cubicbboxchain))
			print("GhostChunk A wasfreed.\n");	
		#endif
		
		Remove(chunk.list_cubicbboxchain);
	}
	
	chunk.chunkbits = __NULL__;
	QueueSetNumVisibleCubics(chunk, 0);
	chunk.flags = 0;
	chunk.enttype = 0;	
	setorigin(chunk, '0 0 0');
	chunk.SendEntity = __NULL__;	// this is most likely the reason ghosting chunks doesn't work
	chunk.SendFlags = 0;
	
	memfill8(chunk.cubic_blocktype, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_blockshape, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_blockrotation, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_cullbits, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_health, 0, sizeof(int)*pow(chunksize, 3));
	memfill8(chunk.cubic_flags, 0, sizeof(int)*pow(chunksize, 3));
	
	ChunkChain_Remove(cluster, chunk);
	GhostChunkChain_Add(chunk);
}

void GhostCluster(entity cluster)
{
	cluster_ent[GetClusterRef(cluster.origin)] = __NULL__;	
	
//	cluster.averagetype = 0;
	cluster.numvisiblecubics = 0;
	cluster.flags = 0;
	cluster.enttype = 0;
	cluster.removetime = 0;
	setorigin(cluster, '0 0 0');
	
	memfill8(cluster.chunk_ent, __NULL__, sizeof(entity)*pow(clustersize, 3));
	memfill8(cluster.cluster_playerlist, __NULL__, sizeof(entity)*maxplayers);	// this line shouldn't be necessary.
	
	UnoccupiedClusterChain_Remove(cluster);
	RemoveClusterForAllClientsChain_Remove(cluster);
	GhostClusterChain_Add(cluster);
}

float InitializeCluster(entity cluster, vector org, int forceload)
{
//	entity chunk, nextchunk;
//	int numchunksghosted;
//	int	maxchunksghostedperframe = 9;
	if(!(cluster.flags & FL_FINDABLE_NONSOLID))	// cluster is new
	{
		cluster.flags = FL_FINDABLE_NONSOLID;
		cluster.enttype = ENT_CLUSTER;
		setorigin(cluster, org);
	//	setsize(cluster, '-100 -100 -100', '100 100 100');
	}

/*	if(!forceload && self.stagger_initializecluster_ghostchunk)
		chunk = self.stagger_initializecluster_ghostchunk;
	else
		chunk = cluster.list_chunkchain;
	
	for(; chunk; chunk = nextchunk)	// FIXME STAGGER could stagger this?
	{
		nextchunk = chunk.chunkchain;
		GhostChunk(cluster, chunk);
	//	FreeChunkAllocations(chunk);
	//	Remove(chunk);
	
		numchunksghosted++;
	
		if(!forceload)
		if(numchunksghosted == maxchunksghostedperframe)
		if(nextchunk)
		{
			self.stagger_initializecluster_ghostchunk = nextchunk;
			return FALSE;
		}
	}
	
	if(!forceload)
		self.stagger_initializecluster_ghostchunk = __NULL__;*/
	
	return TRUE;
}

void InitializeChunk(entity cluster, entity chunk)
{
	if(!(chunk.flags & FL_FINDABLE_NONSOLID))
	{
		chunk.flags = FL_FINDABLE_NONSOLID;
		chunk.enttype = ENT_CHUNK;
	
		if(chunk.numvisiblecubics)
		{
			chunk.SendEntity = SendChunk;
			SetChunkSendFlags(chunk, SFL_ISNEW | SFL_BUILD);
		}
		
		ChunkChain_Add(cluster, chunk);
	}
}

int SaveClusterChunks(entity cluster, int numsaved, int saveall)
{
	entity chunk = __NULL__, nextchunk = __NULL__;
	string filename = __NULL__;
	int *cluster_data = __NULL__;
	int clusterchunkid = 0, i = 0, chunkslot0 = 0, cubicslot0 = 0;
	float file = 0;	
	
	filename = strcat(worldpath, itos(GetClusterRef(cluster.origin)));
	file = fopen(filename, FILE_MMAP_RW, sizeof(*cluster_data)*clusterdataslots);
	cluster_data = (int*)fgets(file);
	
	cluster_data[CLUSTERSLOT_VERSION] = cq_version;
	// numvisiblecubics for cluster is not used
	
	for(chunk = cluster.list_savechunkqueuechain; (saveall || numsaved < autocvar_cq_chunksave_numperinterval) && chunk; chunk = nextchunk)
	{
		#ifdef DEBUG
		if(wasfreed(chunk))
			print("SaveModifiedClusterFiles B wasfreed.\n");	
		#endif
		
		nextchunk = chunk.savechunkqueuechain;
		
		clusterchunkid = GetChunkRef(chunk.origin-cluster.origin, __FUNC__);
		chunkslot0 = numprechunkvaluesincluster + clusterchunkid*numslotsforchunkincluster;

		cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS] = chunk.chunkbits;
		cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = chunk.numvisiblecubics;
		
		for(i = 0; i < pow(chunksize, 3); i++)
		{
			cubicslot0 = chunkslot0+numprecubicvaluesinchunk+i*numvaluespercubic;

			cluster_data[cubicslot0+CUBICSLOT_TYPE] = chunk.cubic_blocktype[i];
			cluster_data[cubicslot0+CUBICSLOT_SHAPE] = chunk.cubic_blockshape[i];
			cluster_data[cubicslot0+CUBICSLOT_ROTATION] = GetFixedRotation(chunk.cubic_blocktype[i], chunk.cubic_blockrotation[i], chunk.cubic_blockshape[i]);
			cluster_data[cubicslot0+CUBICSLOT_CULLBITS] = chunk.cubic_cullbits[i];	
			cluster_data[cubicslot0+CUBICSLOT_HEALTH] = chunk.cubic_health[i];	
			cluster_data[cubicslot0+CUBICSLOT_FLAGS] = chunk.cubic_flags[i];	
		}

	//	print("chunk saved\n");
		SaveChunkQueueChain_Remove(cluster, chunk);
		numsaved++;
	}
	
	fclose(file);
	
	if(!cluster.list_savechunkqueuechain)
		SaveClusterQueueChain_Remove(cluster);	
	
	return numsaved;
}

void SaveModifiedClusterFiles(int saveall)
{
	if(!saveall)
	{
		if(numplayersloadingfiles > 0)
			return;
		
		// this should only happen occasionally, only force saves on exit and cluster removal/unload
		
		if(time < clustersavetime)
			return;
	}

	if(saveall)	// this is only set on quit and map change
	{
		while(list_blockobjectchain)
			LockBlockObject(list_blockobjectchain);		
	}

	int numsaved = 0;
	
	clustersavetime = time+autocvar_cq_chunksave_interval;	// set this cvar to 0 if you want to save everything instantly
	
	entity cluster = __NULL__, nextcluster = __NULL__;
	
	for(cluster = list_saveclusterqueuechain; (saveall || numsaved < autocvar_cq_chunksave_numperinterval) && cluster; cluster = nextcluster)
	{
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("SaveModifiedClusterFiles A wasfreed.\n");	
		#endif
		
		nextcluster = cluster.saveclusterqueuechain;
		
		numsaved += SaveClusterChunks(cluster, numsaved, saveall);
	}
}

void RemoveClustersForPlayerClients()
{
	entity chunk = __NULL__, cluster = __NULL__;//, nextcluster;
//	for(cluster = list_removeclusterforallclientschain; cluster; cluster = nextcluster)
//	{
		cluster = list_removeclusterforallclientschain;
		
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("RemoveClustersForPlayerClients A wasfreed.\n");	
		#endif
		
//		nextcluster = cluster.removeclusterforallclientschain;
		if(cluster)
		{
			for(chunk = cluster.list_chunkchain; chunk; chunk = chunk.chunkchain)
			{
				#ifdef DEBUG
				if(wasfreed(chunk))
					print("RemoveClustersForPlayerClients B wasfreed.\n");		
				#endif
				
				SetChunkSendFlags(chunk, SFL_UPDATE);	// this triggers an update and removes from the client w/o actually removing from the server
			}
			
			RemoveClusterForAllClientsChain_Remove(cluster);
		}
//	}
}

void RemoveChunkEnt(entity chunk, entity cluster)
{
	vector org = chunk.origin;
	
	FreeChunkAllocations(chunk);
	
	while(chunk.list_cubicbboxchain)
	{
		#ifdef DEBUG
		if(wasfreed(chunk.list_cubicbboxchain))
			print("RemoveChunkEnt A wasfreed.\n");
		#endif
		
		Remove(chunk.list_cubicbboxchain);
	}
	
	ChunkChain_Remove(cluster, chunk);
	Remove(chunk);	
	
	cluster.chunk_ent[GetChunkRef(org-cluster.origin, __FUNC__)] = __NULL__;
}


void RemoveUnoccupiedClusters(int numframesbetweenunloads)
{
	entity cluster = __NULL__, chunk = __NULL__, nextchunk = __NULL__;
//	int	numchunksghosted;
	
	if(!list_unoccupiedclusterchain)
	if(!list_removeclusterforallclientschain)
		return;
	
	if(time >= backgroundunloadtime)	
		backgroundunloadtime = time+frametime*numframesbetweenunloads;
	else
		return;	
	
	if(list_removeclusterforallclientschain)
		RemoveClustersForPlayerClients();	// triggers chunks SendFlags and SendEntity to stop networking
	
	cluster = list_unoccupiedclusterchain;
	
	#ifdef DEBUG
	if(wasfreed(cluster))
		print("RemoveUnoccupiedClusters A wasfreed.\n");	
	#endif
	
	if(cluster)
	{
		if(time < cluster.removetime)
			return;
		
		if(stagger_removeunoccupiedclusters_ghostchunk) // this is disabled
		{
			chunk = stagger_removeunoccupiedclusters_ghostchunk;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("RemoveUnoccupiedClusters B wasfreed.\n");
			#endif
			
			stagger_removeunoccupiedclusters_ghostchunk = __NULL__;
		}
		else
		{
			RemoveClusterForAllClientsChain_Remove(cluster);
			chunk = cluster.list_chunkchain;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("RemoveUnoccupiedClusters C wasfreed.\n");
			#endif
		}			
		
		SaveClusterChunks(cluster, 0, TRUE);
		
		for(; chunk; chunk = nextchunk) // ghost/remove the whole cluster now
		{
			nextchunk = chunk.chunkchain;
			
//			GhostChunk(cluster, chunk);
			RemoveChunkEnt(chunk, cluster);

//			numchunksghosted++;

/*			if(numchunksghosted == maxchunksghostedperframe)
			if(nextchunk)
			{
				stagger_removeunoccupiedclusters_ghostchunk = nextchunk;
				return;
			}*/
		}
		GhostCluster(cluster);

/*		memfree(cluster.chunk_ent);
		memfree(cluster.cluster_playerlist);
		
		UnoccupiedClusterChain_Remove(cluster);
		RemoveClusterForAllClientsChain_Remove(cluster);
		cluster_ent[GetClusterRef(cluster.origin)] = __NULL__;
		Remove(cluster);*/
	}
}

int AddPlayerToCluster(entity player, entity cluster, int chunkcount)
{
	entity e = __NULL__, chunk = __NULL__;

	if(player.viewreset)
	for(chunk = cluster.list_chunkchain; chunk; chunk = chunk.chunkchain)
		SetChunkSendFlags(chunk, SFL_ISNEW | SFL_BUILD);
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("AddPlayerToCluster A wasfreed.\n");
		#endif
		
		if(!e)
		{
			cluster.cluster_playerlist[i] = player;
			for(chunk = cluster.list_chunkchain; chunk; chunk = chunk.chunkchain)
				chunkcount++;

			return chunkcount;
		}
		
		if(e == player)
			return chunkcount;		
	}
	
	return chunkcount;
}

int RemovePlayerFromCluster(entity player, entity cluster)
{
	entity e = __NULL__;
	int shiftslots = FALSE;
	
	for(int i = 0; i < maxplayers; i++)
	{
		e = cluster.cluster_playerlist[i];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("RemovePlayerFromCluster A wasfreed.\n");
		#endif
		
		if(!e)
			break;
		
		if(!shiftslots)
		if(e == player)
			shiftslots = TRUE;

		if(!shiftslots)
			continue;
			
		if(i+1 == maxplayers)
			e = __NULL__;
		else
			e = cluster.cluster_playerlist[i+1];
		
		#ifdef DEBUG
		if(wasfreed(e))
			print("RemovePlayerFromCluster B wasfreed.\n");
		#endif
		
		cluster.cluster_playerlist[i] = e;
		
		if(!e)
			break;
	}
	
	return shiftslots;
}

void UnloadWorldForPlayer(entity player, vector org, int disconnect)
{
	vector dist = '0 0 0', pos = '0 0 0', clusterpos = '0 0 0';
	entity cluster = __NULL__;

	int _maxviewsize = maxviewsize;
	int _maxviewheight = maxviewheight;
	vector _maxviewcenter = maxviewcenter;
	
	if(player.maxviewsize_prev)
	{
		_maxviewsize = player.maxviewsize_prev;
		_maxviewheight = player.maxviewheight_prev;
		_maxviewcenter = player.maxviewcenter_prev;
	}
	
	player.maxviewsize_prev = maxviewsize;
	player.maxviewheight_prev = maxviewheight;
	player.maxviewcenter_prev = maxviewcenter;
	
	for(pos_x = 0; pos_x < _maxviewsize; pos_x++)
		for(pos_y = 0; pos_y < _maxviewsize; pos_y++)
			for(pos_z = 0; pos_z < _maxviewheight; pos_z++)
			{
				if(loadradiusarea)
				{
					dist = pos - _maxviewcenter;
					if(dist*dist > (_maxviewsize*0.5)*(_maxviewsize*0.5))
						continue;
				}
				
				clusterpos = pos - ('1 1 0'*((_maxviewsize - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven));
				clusterpos -= '0 0 1'*((_maxviewheight - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven);
				clusterpos = clusterpos*clustersize*chunksize*cubicradius*2;
				clusterpos += org;
				
				if((clusterpos_x < worlddim_x*-0.5) || (clusterpos_x > worlddim_x*0.5)
				|| (clusterpos_y < worlddim_y*-0.5) || (clusterpos_y > worlddim_y*0.5)
				|| (clusterpos_z < worlddim_z*-0.5) || (clusterpos_z > worlddim_z*0.5))
					continue;

				cluster = GetClusterForLocation(__NULL__, clusterpos);

				if(!cluster)
					continue;

				if(!RemovePlayerFromCluster(player, cluster))
					continue;
				
				if(!disconnect)
					RemoveClusterForClientChain_Add(cluster);	// makes sure chunks update over time if they need to be removed on the client still
				
				cluster.occupantcount-=1;
				
				if(cluster.occupantcount < 1)
				{
					if(!cluster.removetime)
						cluster.removetime = time+chunkremovaldelay;
					UnoccupiedClusterChain_Add(cluster);
				}
			}
}

void FixClusterDataForOldVersions(int *cdata)
{
	float f = 0;
	int slot0 = 0, oldver_slot0 = 0, i = 0, chunkslot0 = 0, oldver_chunkslot0 = 0;
//	int datasize = clusterdataslots;	

	int r155_numslotsforchunkincluster = (numprechunkvaluesincluster+pow(chunksize, 3)*r155_numvaluespercubic);
	int r174_numslotsforchunkincluster = (numprechunkvaluesincluster+pow(chunksize, 3)*r174_numvaluespercubic);
	int r177_numslotsforchunkincluster = (numprechunkvaluesincluster+pow(chunksize, 3)*r177_numvaluespercubic);

	int version = cdata[CLUSTERSLOT_VERSION];

	// upgrade to r174
	if(version <= 155)	// pre versioned info
	{
		for(int chunkcount = pow(clustersize, 3)-1; chunkcount >= 0; chunkcount--)
		{
			for(i = 1; i <= pow(chunksize, 3); i++)
			{
				slot0 = numprechunkvaluesincluster + chunkcount*r174_numslotsforchunkincluster + r174_numslotsforchunkincluster - i*r174_numvaluespercubic;		
				oldver_slot0 = numprechunkvaluesincluster + chunkcount*r155_numslotsforchunkincluster + r155_numslotsforchunkincluster - i*r155_numvaluespercubic;

				if(cdata[oldver_slot0+CUBICSLOT_TYPE])
					cdata[slot0+CUBICSLOT_HEALTH] = 100;
				else
					cdata[slot0+CUBICSLOT_HEALTH] = 0;
				cdata[slot0+CUBICSLOT_CULLBITS] = cdata[oldver_slot0+CUBICSLOT_CULLBITS];
				cdata[slot0+CUBICSLOT_ROTATION] = cdata[oldver_slot0+CUBICSLOT_ROTATION];
				cdata[slot0+CUBICSLOT_SHAPE] = cdata[oldver_slot0+CUBICSLOT_SHAPE];
				cdata[slot0+CUBICSLOT_TYPE] = cdata[oldver_slot0+CUBICSLOT_TYPE];
			}
	
			chunkslot0 = numprechunkvaluesincluster+chunkcount*r174_numslotsforchunkincluster;
			oldver_chunkslot0 = numprechunkvaluesincluster+chunkcount*r155_numslotsforchunkincluster;
			
			cdata[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = cdata[oldver_chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS];
			cdata[chunkslot0+CHUNKSLOT_CHUNKBITS] = cdata[oldver_chunkslot0+CHUNKSLOT_CHUNKBITS];
		}
		
		cdata[CLUSTERSLOT_VERSION] = 174;
	}
	
	// upgrade to r177
	if(version <= 174)
	{

		for(int chunkcount = pow(clustersize, 3)-1; chunkcount >= 0; chunkcount--)
		{
			for(i = 1; i <= pow(chunksize, 3); i++)
			{
				slot0 = numprechunkvaluesincluster + chunkcount*r177_numslotsforchunkincluster + r177_numslotsforchunkincluster - i*r177_numvaluespercubic;		
				oldver_slot0 = numprechunkvaluesincluster + chunkcount*r174_numslotsforchunkincluster + r174_numslotsforchunkincluster - i*r174_numvaluespercubic;

				cdata[slot0+CUBICSLOT_FLAGS] = 0;
				cdata[slot0+CUBICSLOT_HEALTH] = cdata[oldver_slot0+CUBICSLOT_HEALTH];
				cdata[slot0+CUBICSLOT_CULLBITS] = cdata[oldver_slot0+CUBICSLOT_CULLBITS];
				cdata[slot0+CUBICSLOT_ROTATION] = cdata[oldver_slot0+CUBICSLOT_ROTATION];
				cdata[slot0+CUBICSLOT_SHAPE] = cdata[oldver_slot0+CUBICSLOT_SHAPE];
				cdata[slot0+CUBICSLOT_TYPE] = cdata[oldver_slot0+CUBICSLOT_TYPE];
			}
	
			chunkslot0 = numprechunkvaluesincluster+chunkcount*r177_numslotsforchunkincluster;
			oldver_chunkslot0 = numprechunkvaluesincluster+chunkcount*r174_numslotsforchunkincluster;
			
			cdata[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS] = cdata[oldver_chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS];
			cdata[chunkslot0+CHUNKSLOT_CHUNKBITS] = cdata[oldver_chunkslot0+CHUNKSLOT_CHUNKBITS];
		}
		
		cdata[CLUSTERSLOT_VERSION] = 177;		
	}
}

entity LoadCluster(entity player, vector pos, int forceload)
{
	int chunkslot0 = 0, cubicslot0 = 0, count = 0, numchunksloaded = 0, i =0;
	entity cluster = __NULL__;
	int *cluster_data;
	float file = 0;

	if(!forceload && player.stagger_loadcluster_chunkid)
	{
		i = player.stagger_loadcluster_chunkid;
		player.stagger_loadcluster_chunkid =  0;
		
		cluster = cluster_ent[GetClusterRef(pos)];
		
		#ifdef DEBUG
		if(wasfreed(cluster))
			print("LoadCluster A wasfreed.\n");
		#endif
		
		if(!cluster)
		{
			print("Warning: no cluster\n");
			return __NULL__;
		}
		
		file = player.loadcluster_file;
		cluster_data = player.loadcluster_cluster_data;
	}
	else
	{
	/*	if(!forceload && player.stagger_initializecluster_ghostchunk)
		{
			cluster = cluster_ent[GetClusterRef(pos)];
			file = player.loadcluster_file;
			cluster_data = player.loadcluster_cluster_data;
		}
		else
		{*/
			string filename = strcat(worldpath, itos(GetClusterRef(pos)));
			file = fopen(filename, FILE_MMAP_READ, sizeof(int)*clusterdataslots);	// rewrite so fixclusterdata can fix the file also, else clusters with more than 1 chunk break (pretty sure this is still fast) .. can't really test this because I don't have old worlds with larger clusters
			
			if(file == -1)
			{
				print("Warning: no file found\n");
				return __NULL__;
			}

			cluster_data = (int*)fgets(file);	


			int version = cluster_data[CLUSTERSLOT_VERSION];
			if(version <= oldfileversion)
			{
				fclose(file);
				file = fopen(filename, FILE_MMAP_RW, sizeof(int)*clusterdataslots);	// reopens file with re-write enabled
				cluster_data = (int*)fgets(file);
				FixClusterDataForOldVersions(cluster_data);
			}
			
			if(!forceload)
			{
				player.loadcluster_file = file;
				player.loadcluster_cluster_data = cluster_data;		// this seems like it might not be ok to do
			}
			
			if(list_ghostclusterchain)
			{
				cluster = list_ghostclusterchain;
				
				#ifdef DEBUG
				if(wasfreed(cluster))
					print("LoadCluster B wasfreed.\n");	
				#endif
				
				GhostClusterChain_Remove(cluster);
			}
			else
			{
				cluster = spawn();
				cluster.chunk_ent = memalloc(sizeof(entity)*pow(clustersize, 3));
				cluster.cluster_playerlist = memalloc(sizeof(entity)*maxplayers);
			}
			
			if(!clusters_allocated)
			{
				clusters_allocated = TRUE;
				cluster_ent = memalloc(sizeof(entity)*maxclusters);

			}
			
			cluster_ent[GetClusterRef(pos)] = cluster;
			
		//	cluster.averagetype = cluster_data[CLUSTERSLOT_AVERAGETYPE];	// not used
			cluster.numvisiblecubics = cluster_data[CLUSTERSLOT_NUMVISIBLECUBICS];
	//	}
		
		if(!InitializeCluster(cluster, pos, forceload))	// staggering cluster ghosting here
			return cluster;
	}
	
	for(; i < pow(clustersize, 3); i++)
	{
		chunkslot0 = numprechunkvaluesincluster + i*numslotsforchunkincluster;

		entity chunk;

		if(list_ghostchunkchain)
		{
			chunk = list_ghostchunkchain;
			
			#ifdef DEBUG
			if(wasfreed(chunk))
				print("LoadCluster C wasfreed.\n");	
			#endif
			
			GhostChunkChain_Remove(chunk);
		}
		else
		{
			chunk = spawn(); 
			setorigin(chunk, GetChunkOffset(i)+pos);
//			setsize(chunk, '-50 -50 -50', '50 50 50');
			
			chunk.chunk_playerdelay = memalloc(sizeof(float)*maxplayers);	// is this used?
			chunk.cubic_blocktype = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_blockshape = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_blockrotation = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_cullbits = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_health = memalloc(sizeof(int)*pow(chunksize, 3));
			chunk.cubic_flags = memalloc(sizeof(int)*pow(chunksize, 3));
		}

		cluster.chunk_ent[i] = chunk;
		
		#ifdef DEBUG
		if(wasfreed(chunk))
			print("Loadcluster D wasfreed.\n");
		#endif
		
		chunk.chunkbits = cluster_data[chunkslot0+CHUNKSLOT_CHUNKBITS];
		QueueSetNumVisibleCubics(chunk, cluster_data[chunkslot0+CHUNKSLOT_NUMVISIBLECUBICS]);

		InitializeChunk(cluster, chunk);

		for(count = 0; count < pow(chunksize, 3); count++)
		{
			cubicslot0 = chunkslot0 + numprecubicvaluesinchunk + count*numvaluespercubic;
			
			chunk.cubic_blocktype[count] = cluster_data[cubicslot0+CUBICSLOT_TYPE];
			chunk.cubic_blockshape[count] = cluster_data[cubicslot0+CUBICSLOT_SHAPE];
			chunk.cubic_blockrotation[count] = GetFixedRotation(chunk.cubic_blocktype[count], cluster_data[cubicslot0+CUBICSLOT_ROTATION], chunk.cubic_blockshape[count]);
			chunk.cubic_cullbits[count] = cluster_data[cubicslot0+CUBICSLOT_CULLBITS];
			chunk.cubic_health[count] = cluster_data[cubicslot0+CUBICSLOT_HEALTH];
			chunk.cubic_flags[count] = cluster_data[cubicslot0+CUBICSLOT_FLAGS];
			
			InitializeCubic_Wrap(chunk, count);	// for mods
		}
		
		if(!forceload)
		{
			numchunksloaded++;
			
			if(numchunksloaded == autocvar_cq_maxchunksloadedperframe)
			if(i+1 < pow(clustersize, 3))
			{
				player.stagger_loadcluster_chunkid = i+1;
				return cluster;
			}
		}
	}
	
/*	if(!forceload)
	{
		player.stagger_loadcluster_chunkid = 0;
	//	lastloadclustercluster = __NULL__;
	}*/
	
	fclose(file);

	return cluster;
}

void SetClusterOccupancyForPlayer(entity player, vector org)
{
	vector dist = '0 0 0', pos = '0 0 0', clusterpos = '0 0 0';
	entity cluster = __NULL__;
	int chunkcount = 0;
	
	float viewedgeA = (maxviewsize-viewsize)*0.5;
	float viewedgeB = maxviewsize-viewedgeA-1;
	float viewedgeC = (maxviewheight-viewheight)*0.5;
	float viewedgeD = maxviewheight-viewedgeC-1;
	float viewedgeE = (maxviewsize-viewsize_distant)*0.5;
	float viewedgeF = maxviewsize-viewedgeE-1;
	float viewedgeG = (maxviewheight-viewheight_distant)*0.5;
	float viewedgeH = maxviewheight-viewedgeG-1;
							
	for(pos_x = 0; pos_x < maxviewsize; pos_x++)
		for(pos_y = 0; pos_y < maxviewsize; pos_y++)
			for(pos_z = 0; pos_z < maxviewheight; pos_z++)
			{
				if(loadradiusarea)
				{
					dist = pos - maxviewcenter;
					if(dist*dist > (maxviewsize*0.5)*(maxviewsize*0.5))
						continue;
				}
				
				if(pos_x < viewedgeA || pos_x > viewedgeB
				|| pos_y < viewedgeA || pos_y > viewedgeB
				|| pos_z < viewedgeC || pos_z > viewedgeD)
				if(pos_x < viewedgeE || pos_x > viewedgeF
				|| pos_y < viewedgeE || pos_y > viewedgeF
				|| pos_z < viewedgeG || pos_z > viewedgeH)
					continue;
			
				clusterpos = pos - ('1 1 0'*((maxviewsize - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven));
				clusterpos -= '0 0 1'*((maxviewheight - !loadsize_iseven)*0.5 - 0.5*loadsize_iseven);				
				clusterpos = clusterpos*clustersize*chunksize*cubicradius*2;
				clusterpos += org;

				if(clusterpos_x < worlddim_x*-0.5 || clusterpos_x > worlddim_x*0.5
				|| clusterpos_y < worlddim_y*-0.5 || clusterpos_y > worlddim_y*0.5
				|| clusterpos_z < worlddim_z*-0.5 || clusterpos_z > worlddim_z*0.5)
					continue;
								
				cluster = GetClusterForLocation(__NULL__, clusterpos);

				if(cluster)
				{
					chunkcount = AddPlayerToCluster(player, cluster, chunkcount);
					cluster.occupantcount++;
					cluster.removetime = 0;

					// don't add this to the all player's chain. if no other players are adding it to the chain, then it will remove the cluster.
					RemoveClusterForClientChain_Remove(cluster);	
					UnoccupiedClusterChain_Remove(cluster);
				}
			}		
}

int LoadClusterForPlayer(entity player, vector pos, int forceload)
{
	entity cluster = __NULL__;
	
	if(forceload || !player.stagger_loadcluster_chunkid)
	{
		cluster = GetClusterForLocation(__NULL__, pos);

		if(cluster)
			return FALSE;
	}
	
	cluster = LoadCluster(player, pos, forceload);
	
	if(!cluster)
		return FALSE;

	if(!forceload)
	if(player.stagger_loadcluster_chunkid)
		return TRUE;
	
	AddPlayerToCluster(player, cluster, 0);
	cluster.occupantcount++;
	cluster.removetime = 0;
	UnoccupiedClusterChain_Remove(cluster);

	return TRUE;
}

int LoadWorldForPlayer(entity player, vector org, int areasize, int areaheight, vector areacenter, int maxclustersloadedperframe, int isbackground, int subsize, int subheight, float numframesbetweenloads)
{
	vector dist = '0 0 0', pos = '0 0 0', ofs = '0 0 0', clusterpos = '0 0 0', nextpos = '0 0 0', lastpos = '0 0 0';
	float scaleval = 0, scaleheightval = 0;
	int numloadedclustersthisframe = 0, stop = 0, getnextpos = 0;

	float loadareaedge = (areasize-subsize)*0.5;
	float loadheightedge = (areaheight-subheight)*0.5;
	
	if(isbackground)
	if(time >= player.backgroundloadtime)	
		player.backgroundloadtime = time+frametime*numframesbetweenloads;
	else
		return TRUE;
	
	if(!isbackground)
		LoadClusterForPlayer(player, org, TRUE);	// immediately loads a cluster around the player
	
	if(player.loadingbackgroundchunks == 1)
		pos = player.lastbackgroundqueuepos;
	else
	if(player.loadingbackgroundchunks == 2)
		pos = player.lastdistantbackgroundqueuepos;
	else
		pos = '0 0 0';
	
	for(; pos_x < areasize && !stop; pos_x++)
	{
		if(getnextpos)
		{
			nextpos = pos;
			stop = TRUE;
			break;
		}		
		
		for(; pos_y < areasize && !stop; pos_y++)
		{
			if(getnextpos)
			{
				nextpos = pos;
				stop = TRUE;
				break;
			}
			
			for(; pos_z < areaheight && !stop; pos_z++)
			{
				if(isbackground)
				if(pos_x >= loadareaedge && pos_x < loadareaedge+subsize
				&& pos_y >= loadareaedge && pos_y < loadareaedge+subsize
				&& pos_z == loadheightedge)
				{
					pos_z += subheight;
					if(pos_z >= areaheight)
						break;
				}
				
				if(getnextpos)
				{
					nextpos = pos;
					stop = TRUE;
					break;
				}
				
				if(loadradiusarea)
				{
					dist = pos - areacenter;
					if(dist*dist > (areasize*0.5)*(areasize*0.5))
						continue;
				}

				scaleval = (areasize-!loadsize_iseven)*0.5 - 0.5*loadsize_iseven;
				scaleheightval = (areaheight-!loadsize_iseven)*0.5 - 0.5*loadsize_iseven;
				ofs = '1 1 0'*scaleval + '0 0 1'*scaleheightval;
				ofs = pos-ofs;
				scaleval = clustersize*chunksize*cubicradius*2;
				clusterpos = ofs*scaleval;
				clusterpos = clusterpos + org;

				if(clusterpos == org)
					continue;
				
				if(clusterpos_x < worlddim_x*-0.5 || clusterpos_x > worlddim_x*0.5
				|| clusterpos_y < worlddim_y*-0.5 || clusterpos_y > worlddim_y*0.5
				|| clusterpos_z < worlddim_z*-0.5 || clusterpos_z > worlddim_z*0.5)
					continue;

				if(LoadClusterForPlayer(player, clusterpos, !isbackground))
				if(isbackground)
				{
					numloadedclustersthisframe++;
					
					if(player.stagger_loadcluster_chunkid)
					{
						lastpos = pos;
						stop = TRUE;
						break;
					}
					else
					if(numloadedclustersthisframe == maxclustersloadedperframe)
						getnextpos = TRUE;
				}
			}
			
			pos_z = 0;
		}
		
		pos_y = 0;
	}
	
	player.lastbackgroundqueuepos = '0 0 0';
	player.lastdistantbackgroundqueuepos = '0 0 0';

	if(isbackground)
	if(stop)
	{
		if(getnextpos)			
			pos = nextpos;
		else
			pos = lastpos;
		
		if(player.loadingbackgroundchunks == 1)
			player.lastbackgroundqueuepos = pos;
		else
		if(player.loadingbackgroundchunks == 2)
			player.lastdistantbackgroundqueuepos = pos;
	}
	
	return stop;
}

void Player_WorldInterface()
{
	if(world_initialized < 3)
		return;

	entity player, e, nexte;
	int updatecount = 0;
	
	float loadwidth = clustersize*chunksize*cubicradius*1.2;
	float loadheight = clustersize*chunksize*cubicradius*1.2;

	for(player = list_playerchain; player; player = player.playerchain)
	{
		CheckWorldBounds(player);
		
		#ifdef DEBUG
		if(wasfreed(player))
			print("Player_WorldInterface A wasfreed.\n");	
		#endif
		
		// CHECK WORLD BOUNDS	(for MOVETYPE_NOCLIP)
		if(player.origin_x >= worlddim_x*0.5 || player.origin_x <= worlddim_x*-0.5
		|| player.origin_y >= worlddim_y*0.5 || player.origin_y <= worlddim_y*-0.5
		|| player.origin_z >= worlddim_z*0.5 || player.origin_z <= worlddim_z*-0.5)
			continue;		
			
//		if(player.movetype != MOVETYPE_WALK)
//			continue;
		
		if(!player.loadingchunks)
		if(!player.loadingbackgroundchunks)
		if(player.origin_x > player.playerclusterorg_x + loadwidth || player.origin_x < player.playerclusterorg_x - loadwidth
		|| player.origin_y > player.playerclusterorg_y + loadwidth || player.origin_y < player.playerclusterorg_y - loadwidth
		|| player.origin_z > player.playerclusterorg_z + loadheight || player.origin_z < player.playerclusterorg_z - loadheight
		|| !player.worldloaded
		|| player.viewreset)
		{
			numplayersloadingfiles++;
			
			player.loadingchunks = TRUE;
			player.loadingbackgroundchunks = TRUE;
			
			if(player.worldloaded)
				UnloadWorldForPlayer(player, player.playerclusterorg, FALSE);	// removeclusterforclientchain is set inside
			
			vector newclusterorg = GetNearClusterOrg(player.origin);
			SetClusterOccupancyForPlayer(player, newclusterorg);
			player.playerclusterorg = newclusterorg;
			player.playerclusterid = GetClusterRef(player.playerclusterorg);
			player.viewreset = FALSE;
			
			// the purpose of this per player chain being separate from the all player chain, then feeding into it is to cull it per player before adding it to the main chain.
			// chunks that would be removed from the individual player's chain may still need to be updated for other players, hence the bigger chain.
			for(e = list_removeclusterforclientchain; e; e = nexte)
			{
				#ifdef DEBUG
				if(wasfreed(e))
					print("Player_WorldInterface B wasfreed.\n");		
				#endif
				
				nexte = e.removeclusterforclientchain;
				RemoveClusterForAllClientsChain_Add(e); // adds the clusters to stop networking to this player to the master list
				RemoveClusterForClientChain_Remove(e); // clears the temporary list for the next player to use
			}			
		}
	}

	RemoveUnoccupiedClusters(1);

	for(player = list_playerchain; player; player = player.playerchain)
	{
		#ifdef DEBUG
		if(wasfreed(player))
			print("Player_WorldInterface C wasfreed.\n");			
		#endif
		
		// CHECK WORLD BOUNDS
		if(player.origin_x >= worlddim_x*0.5 || player.origin_x <= worlddim_x*-0.5
		|| player.origin_y >= worlddim_y*0.5 || player.origin_y <= worlddim_y*-0.5
		|| player.origin_z >= worlddim_z*0.5 || player.origin_z <= worlddim_z*-0.5)
			continue;
		
		if(player.loadingchunks)
		{
			player.loadingchunks = LoadWorldForPlayer(player, player.playerclusterorg, loadsize, loadsize, loadcenter, pow(loadsize, 3), FALSE, 0, 0, 0);
			player.worldloaded = TRUE;
		}
		else
		if(player.loadingbackgroundchunks == 1)
		{
			if(!LoadWorldForPlayer(player, player.playerclusterorg, viewsize, viewheight, viewcenter, 1, TRUE, loadsize, loadsize, 1))
			{
				player.loadingbackgroundchunks = 2;
				player.lastbackgroundqueuepos = '0 0 0';
			}
		}
		else
		if(player.loadingbackgroundchunks == 2)
		{
			if(!LoadWorldForPlayer(player, player.playerclusterorg, viewsize_distant, viewheight_distant, viewcenter_distant, 1, TRUE, viewsize, viewheight, 1))
			{
				player.loadingbackgroundchunks = FALSE;
				player.lastdistantbackgroundqueuepos = '0 0 0';
				numplayersloadingfiles -= 1;
			}
		}

		LeaveSolidCubics(player, player.lastsolidcubicorigin);
		SetSolidCubics(player, player.origin);
		player.lastsolidcubicorigin = player.origin;
	}

//	RemoveUnusedCubicBBoxes();
	
	for(e = list_setchunksendflags_BUILD_chain; e; e = nexte)
	{
		nexte = e.setchunksendflags_BUILD_chain;
		SetChunkSendFlags(e, SFL_BUILD);
		SetChunkSendFlags_BUILD_Chain_Remove(e);
	}
}

void UninitializePlayers()
{
	for(entity e = list_playerchain; e; e = e.playerchain)
	{
		#ifdef DEBUG
		if(wasfreed(e))
			print("UninitializePlayers A wasfreed.\n");	
		#endif
		
		e.client_initialized = FALSE;
		e.viewreset = TRUE;
	}
}

void SetLoadDistanceValues()
{
	viewsize = max(1, cvar("cq_viewdist1"))*2 + 1;
	viewheight = max(1, cvar("cq_viewheight1"))*2 + 1;
	viewsize_distant = max(1, cvar("cq_viewdist2"))*2 + 1;
	viewheight_distant = max(1, cvar("cq_viewheight2"))*2 + 1;
	SetDependentViewValues();
}

void SetAmbientLight()
{
	ambientlight = stov(cvar_string("cq_ambientlight"));	
}

void InitServerCubics()
{
//	testbox = spawn();
//	setmodel(testbox, "models/editor/cubeselector.mdl");
	int generatingworld = FALSE;
	
	maxplayers = 0;
	for(entity p = world; (p=nextent(p)); maxplayers++) {}
	
	clientstat(STAT_TOOL, EV_INTEGER, tool);
	clientstat(STAT_TOOLSIZE, EV_INTEGER, toolsize);
	clientstat(STAT_EDITOR_BLOCKTYPE, EV_INTEGER, editor_blocktype);
	clientstat(STAT_EDITOR_BLOCKSHAPE, EV_INTEGER, editor_blockshape);
	clientstat(STAT_EDITOR_BLOCKROTATION, EV_INTEGER, editor_blockrotation);
	clientstat(STAT_EDITOR_INFOEDIT, EV_INTEGER, editor_infoedit);
	clientstat(STAT_EDITOR_EDITCHUNK, EV_INTEGER, editor_editchunk);
	clientstat(STAT_EDITOR_FILLMODE, EV_INTEGER, editor_fillmode);
	clientstat(STAT_EDITOR_SIZETOOL, EV_INTEGER, editor_sizetool);
	
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_UP, EV_INTEGER, infoedit_chunksidedata[0]);
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_WEST, EV_INTEGER, infoedit_chunksidedata[1]);
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_SOUTH, EV_INTEGER, infoedit_chunksidedata[2]);
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_EAST, EV_INTEGER, infoedit_chunksidedata[3]);
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_NORTH, EV_INTEGER, infoedit_chunksidedata[4]);
	clientstat(STAT_EDITOR_CHUNKSIDETYPE_DOWN, EV_INTEGER, infoedit_chunksidedata[5]);

	clientstat(STAT_EDITOR_CHUNKSIDEFIT_UP, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+0]);
	clientstat(STAT_EDITOR_CHUNKSIDEFIT_WEST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+1]);
	clientstat(STAT_EDITOR_CHUNKSIDEFIT_SOUTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+2]);
	clientstat(STAT_EDITOR_CHUNKSIDEFIT_EAST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+3]);
	clientstat(STAT_EDITOR_CHUNKSIDEFIT_NORTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+4]);
	clientstat(STAT_EDITOR_CHUNKSIDEFIT_DOWN, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFIT_0+5]);

	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_UP, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+0]);
	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_WEST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+1]);
	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_SOUTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+2]);
	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_EAST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+3]);
	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_NORTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+4]);
	clientstat(STAT_EDITOR_CHUNKSIDEFLAGS_DOWN, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_CONNECTIONFLAGS_0+5]);

	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_UP, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+0]);
	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_WEST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+1]);
	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_SOUTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+2]);
	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_EAST, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+3]);
	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_NORTH, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+4]);
	clientstat(STAT_EDITOR_CHUNKGROUPSIZE_DOWN, EV_INTEGER, infoedit_chunksidedata[PREFABCHUNKSLOT_GROUPSIZE_0+5]);

	clientstat(STAT_EDITOR_CHUNKZONE, EV_INTEGER, prefabzone);
	clientstat(STAT_EDITOR_CHUNKCHANCE, EV_INTEGER, prefabchance);
	clientstat(STAT_EDITOR_CHUNKFLAGS, EV_INTEGER, prefabchunkflags);
	
	clientstat(STAT_PLAYERCLUSTERID, EV_INTEGER, playerclusterid);

	cubicradius = max(1, floor(cvar("cq_blocksize")*0.5));	
	maxcubicupdates = ceil(cvar("cq_maxcubicupdates"));
	chunkremovaldelay = ceil(cvar("cq_chunkremovaldelay"));	

	gen_type = cvar("cq_gen_type");

	int *world_data;	
	worldpath = strcat("worlds/", cvar_string("cq_worldname"), "/");
	string filename = strcat(worldpath, "world_data");
	float file = fopen(filename, FILE_MMAP_READ, sizeof(int)*numworldslots);
	
	if(file != -1) // world exists
	{
		world_data = (int*)fgets(file);
		worldsize = world_data[WORLDSLOT_WORLDSIZE];
		clustersize = world_data[WORLDSLOT_CLUSTERSIZE];
		chunksize = world_data[WORLDSLOT_CHUNKSIZE];
		fclose(file);
		world_initialized = 3;
	}
	else // create new world
	{
		generatingworld = TRUE;
		file = fopen(filename, FILE_MMAP_RW, sizeof(int)*numworldslots);
		world_data = (int*)fgets(file);
		worldsize = max(1, floor(cvar("cq_worldsize")));
		clustersize = max(1, floor(cvar("cq_clustersize")));
		chunksize = max(1, floor(cvar("cq_chunksize")));
		dungeonsize = stov(cvar_string("cq_dungeonsize"));
		lineargeneration = cvar("cq_gen_linear");
		genstep = cvar("cq_gen_step");
		
		print("\nReading worldsize: ", itos(worldsize), "\n");
		if(worldsize/2 == floor(worldsize/2))
		{
			worldsize+=1;
			print("Increasing worldsize to ", itos(worldsize), " to make it odd.\n");
		}

		if(gen_type == GEN_TYPE_PREFAB)
		if(worldsize*clustersize <= 2)
		{
			print("World is too small to generate dungeon.\n");
			dungeonsize = '0 0 0';
		}
		else
		{
			dungeonsize_x = bound(1, dungeonsize_x, worldsize*clustersize-2);
			dungeonsize_y = bound(1, dungeonsize_y, worldsize*clustersize-2);
			dungeonsize_z = bound(1, dungeonsize_z, worldsize*clustersize-2);		
			print("dungeon size: ", vtos(dungeonsize), "\n");
			print("linear generation: ", itos(lineargeneration), "\n");
		}
		
		world_data[WORLDSLOT_WORLDSIZE] = worldsize;
		world_data[WORLDSLOT_CLUSTERSIZE] = clustersize;
		world_data[WORLDSLOT_CHUNKSIZE] = chunksize;
		fclose(file);
	}
	
	print("cluster size: ", itos(clustersize), "\n");
	print("chunk size: ", itos(chunksize), "\n");
	print("block size: ", itos(cubicradius*2), "\n");	
	print("max cubicupdates: ", itos(maxcubicupdates), "\n");
	print("chunk removal delay: ", itos(chunkremovaldelay), "\n");

	if(generatingworld)
		print("Generating World.\n");

	SetLoadDistanceValues();
	SetAmbientLight();
	
	InitGameVariables();
	SharedPrecaches();
}

void InitializePlayers()
{
	int count = 0, free = 0;
	vector org = '0 0 0', cubicpos = '0 0 0';
	entity chunk = __NULL__;
	float playercubicheight;
	
	for(entity e = list_playerchain; e; e = e.playerchain)
		if(e.waitingtospawn)
		if(e.worldloaded)
		if(!e.loadingchunks)
		if(!e.loadingbackgroundchunks)
		{
			e.waitingtospawn = FALSE;
			
			if(e.movetype != MOVETYPE_NOCLIP)
			{	
				e.movetype = MOVETYPE_WALK;
				
				playercubicheight = ceil((e.maxs_z-e.mins_z)/(cubicradius*2));	// who knows, some players may end up shorter than others somehow
				org = GetNearChunkOrg('0 0 0');
				org_z += (chunksize-1)*cubicradius;
				cubicpos = org;
				
				for(count = 0; count < chunksize; count++)
				{
					cubicpos_z = org_z - count*cubicradius*2;
					chunk = GetChunkForLocation(__NULL__, cubicpos, __FUNC__);
					if(GetCubicStatus(chunk, cubicpos, TRUE) == -1)
						free++;
					else
					if(free >= playercubicheight)
					{
						cubicpos_z += cubicradius*2;
						break;
					}
					else
						free = 0;
				}

				free = 0;

				org = cubicpos;
				org_z -= cubicradius;
				org_z -= e.mins_z;
				org_z += 1;
				
				setorigin(e, org);
			}
		}
}

void UpdateBlockObjects();
void WorldLogic()
{
	entity e = __NULL__, nexte = __NULL__;
	
	InitializePlayers();
//	ProjectileUpdate();	// see sv_attacks.qc for examples
	SaveModifiedClusterFiles(FALSE);
	UpdateBlockObjects();
	Player_WorldInterface();	
	
	// obj colllision (includes projectiles)
	for(e = list_objchain; e; e = e.objchain)
	{
		LeaveSolidCubics(e, e.lastsolidcubicorigin);
		SetSolidCubics(e, e.origin);
		e.lastsolidcubicorigin = e.origin;
	}	
	
	// obj think (includes projectiles)
	for(e = list_objchain; e; e = nexte)
	{
		nexte = e.objchain;
		Obj_Think(e);
	}		
}

void StartFrame_Cubics()
{
	if(world_initialized < 3)
	{
		if(gen_type == GEN_TYPE_FLAT)
			GenerateWorld_Wasteland();
		else
		if(gen_type == GEN_TYPE_WASTELAND)
			GenerateWorld_Wasteland();
		else
		if(gen_type == GEN_TYPE_PREFAB)
			GenerateWorld_Prefabs();
	}
	else
	{	
		WorldLogic();
		RemoveUnusedCubicBBoxes();
		SetNumVisibleCubicsForChunks();		
		UpdateChunkNetworkEntities();		
	}
}