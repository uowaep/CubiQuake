entity		list_playerchain;
.entity		playerchain;
.entity		playerchain_prev;
void PlayerChain_Add(entity e)		{	list_playerchain = LinkedList_Add(e, list_playerchain, playerchain, playerchain_prev);	}
void PlayerChain_Remove(entity e)		{	list_playerchain = LinkedList_Remove(e, list_playerchain, playerchain, playerchain_prev);	}

.entity		list_chunkchain;
.entity		chunkchain;
.entity		chunkchain_prev;
void ChunkChain_Add(entity o, entity e)		{	o.list_chunkchain = LinkedList_Add(e, o.list_chunkchain, chunkchain, chunkchain_prev);	}
void ChunkChain_Remove(entity o, entity e)		{	o.list_chunkchain = LinkedList_Remove(e, o.list_chunkchain, chunkchain, chunkchain_prev);	}

.entity		list_cubicbboxchain;
.entity		cubicbboxchain;
.entity		cubicbboxchain_prev;
void CubicBBoxChain_Add(entity o, entity e)		{	o.list_cubicbboxchain = LinkedList_Add(e, o.list_cubicbboxchain, cubicbboxchain, cubicbboxchain_prev);	}
void CubicBBoxChain_Remove(entity o, entity e)		{	o.list_cubicbboxchain = LinkedList_Remove(e, o.list_cubicbboxchain, cubicbboxchain, cubicbboxchain_prev);	}

entity		list_unusedcubicbboxchain;
.entity		unusedcubicbboxchain;
.entity		unusedcubicbboxchain_prev;
void UnusedCubicBBoxChain_Add(entity e)		{	list_unusedcubicbboxchain = LinkedList_Add(e, list_unusedcubicbboxchain, unusedcubicbboxchain, unusedcubicbboxchain_prev);	}
void UnusedCubicBBoxChain_Remove(entity e)		{	list_unusedcubicbboxchain = LinkedList_Remove(e, list_unusedcubicbboxchain, unusedcubicbboxchain, unusedcubicbboxchain_prev);	}

entity		list_unoccupiedclusterchain;
.entity		unoccupiedclusterchain;
.entity		unoccupiedclusterchain_prev;
void UnoccupiedClusterChain_Add(entity e)		{	list_unoccupiedclusterchain = LinkedList_Add(e, list_unoccupiedclusterchain, unoccupiedclusterchain, unoccupiedclusterchain_prev);	}
void UnoccupiedClusterChain_Remove(entity e)		{	list_unoccupiedclusterchain = LinkedList_Remove(e, list_unoccupiedclusterchain, unoccupiedclusterchain, unoccupiedclusterchain_prev);	}

entity		list_saveclusterqueuechain;
.entity		saveclusterqueuechain;
.entity		saveclusterqueuechain_prev;
void SaveClusterQueueChain_Add(entity e)		{	list_saveclusterqueuechain = LinkedList_Add(e, list_saveclusterqueuechain, saveclusterqueuechain, saveclusterqueuechain_prev);	}
void SaveClusterQueueChain_Remove(entity e)		{	list_saveclusterqueuechain = LinkedList_Remove(e, list_saveclusterqueuechain, saveclusterqueuechain, saveclusterqueuechain_prev);	}

.entity		list_savechunkqueuechain;
.entity		savechunkqueuechain;
.entity		savechunkqueuechain_prev;
void SaveChunkQueueChain_Add(entity o, entity e)		{	o.list_savechunkqueuechain = LinkedList_Add(e, o.list_savechunkqueuechain, savechunkqueuechain, savechunkqueuechain_prev);	}
void SaveChunkQueueChain_Remove(entity o, entity e)		{	o.list_savechunkqueuechain = LinkedList_Remove(e, o.list_savechunkqueuechain, savechunkqueuechain, savechunkqueuechain_prev);	}


entity		list_projectilechain;
.entity		projectilechain;
.entity		projectilechain_prev;
void ProjectileChain_Add(entity e)		{	list_projectilechain = LinkedList_Add(e, list_projectilechain, projectilechain, projectilechain_prev);	}
void ProjectileChain_Remove(entity e)		{	list_projectilechain = LinkedList_Remove(e, list_projectilechain, projectilechain, projectilechain_prev);	}