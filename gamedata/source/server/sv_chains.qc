entity		list_playerchain;
.entity		playerchain;
.entity		playerchain_prev;
void PlayerChain_Add(entity e)		{	list_playerchain = LinkedList_Add(e, list_playerchain, playerchain, playerchain_prev);	}
void PlayerChain_Remove(entity e)	{	list_playerchain = LinkedList_Remove(e, list_playerchain, playerchain, playerchain_prev);	}

.entity		list_chunkchain;
.entity		chunkchain;
.entity		chunkchain_prev;
void ChunkChain_Add(entity o, entity e)		{	o.list_chunkchain = LinkedList_Add(e, o.list_chunkchain, chunkchain, chunkchain_prev);	}
void ChunkChain_Remove(entity o, entity e)	{	o.list_chunkchain = LinkedList_Remove(e, o.list_chunkchain, chunkchain, chunkchain_prev);	}

.entity		list_cubicbboxchain;
.entity		cubicbboxchain;
.entity		cubicbboxchain_prev;
void CubicBBoxChain_Add(entity o, entity e)		{	o.list_cubicbboxchain = LinkedList_Add(e, o.list_cubicbboxchain, cubicbboxchain, cubicbboxchain_prev);	}
void CubicBBoxChain_Remove(entity o, entity e)	{	o.list_cubicbboxchain = LinkedList_Remove(e, o.list_cubicbboxchain, cubicbboxchain, cubicbboxchain_prev);	}

entity		list_unusedcubicbboxchain;
.entity		unusedcubicbboxchain;
.entity		unusedcubicbboxchain_prev;
void UnusedCubicBBoxChain_Add(entity e)		{	list_unusedcubicbboxchain = LinkedList_Add(e, list_unusedcubicbboxchain, unusedcubicbboxchain, unusedcubicbboxchain_prev);	}
void UnusedCubicBBoxChain_Remove(entity e)	{	list_unusedcubicbboxchain = LinkedList_Remove(e, list_unusedcubicbboxchain, unusedcubicbboxchain, unusedcubicbboxchain_prev);	}

entity		list_unoccupiedclusterchain;
.entity		unoccupiedclusterchain;
.entity		unoccupiedclusterchain_prev;
void UnoccupiedClusterChain_Add(entity e)		{	list_unoccupiedclusterchain = LinkedList_Add(e, list_unoccupiedclusterchain, unoccupiedclusterchain, unoccupiedclusterchain_prev);	}
void UnoccupiedClusterChain_Remove(entity e)	{	list_unoccupiedclusterchain = LinkedList_Remove(e, list_unoccupiedclusterchain, unoccupiedclusterchain, unoccupiedclusterchain_prev);	}

entity		list_removeclusterforclientchain;
.entity		removeclusterforclientchain;
.entity		removeclusterforclientchain_prev;
void RemoveClusterForClientChain_Add(entity e)		{	list_removeclusterforclientchain = LinkedList_Add(e, list_removeclusterforclientchain, removeclusterforclientchain, removeclusterforclientchain_prev);	}
void RemoveClusterForClientChain_Remove(entity e)	{	list_removeclusterforclientchain = LinkedList_Remove(e, list_removeclusterforclientchain, removeclusterforclientchain, removeclusterforclientchain_prev);	}

entity		list_removeclusterforallclientschain;
.entity		removeclusterforallclientschain;
.entity		removeclusterforallclientschain_prev;
void RemoveClusterForAllClientsChain_Add(entity e)		{	list_removeclusterforallclientschain = LinkedList_Add(e, list_removeclusterforallclientschain, removeclusterforallclientschain, removeclusterforallclientschain_prev);	}
void RemoveClusterForAllClientsChain_Remove(entity e)	{	list_removeclusterforallclientschain = LinkedList_Remove(e, list_removeclusterforallclientschain, removeclusterforallclientschain, removeclusterforallclientschain_prev);	}

entity		list_staggeredchunkupdatechain;
.entity		staggeredchunkupdatechain;
.entity		staggeredchunkupdatechain_prev;
void StaggeredChunkUpdateChain_Add(entity e)		{	list_staggeredchunkupdatechain = LinkedList_Add(e, list_staggeredchunkupdatechain, staggeredchunkupdatechain, staggeredchunkupdatechain_prev);	}
void StaggeredChunkUpdateChain_Remove(entity e)	{	list_staggeredchunkupdatechain = LinkedList_Remove(e, list_staggeredchunkupdatechain, staggeredchunkupdatechain, staggeredchunkupdatechain_prev);	}

entity		list_setchunksendflags_BUILD_chain;
.entity		setchunksendflags_BUILD_chain;
.entity		setchunksendflags_BUILD_chain_prev;
void SetChunkSendFlags_BUILD_Chain_Add(entity e)		{	list_setchunksendflags_BUILD_chain = LinkedList_Add(e, list_setchunksendflags_BUILD_chain, setchunksendflags_BUILD_chain, setchunksendflags_BUILD_chain_prev);	}
void SetChunkSendFlags_BUILD_Chain_Remove(entity e)	{	list_setchunksendflags_BUILD_chain = LinkedList_Remove(e, list_setchunksendflags_BUILD_chain, setchunksendflags_BUILD_chain, setchunksendflags_BUILD_chain_prev);	}

/*entity		list_hidingfromplayerchain;
.entity		hidingfromplayerchain;
.entity		hidingfromplayerchain_prev;
void HidingFromPlayerChain_Add(entity e)		{	list_hidingfromplayerchain = LinkedList_Add(e, list_hidingfromplayerchain, hidingfromplayerchain, hidingfromplayerchain_prev);	}
void HidingFromPlayerChain_Remove(entity e)	{	list_hidingfromplayerchain = LinkedList_Remove(e, list_hidingfromplayerchain, hidingfromplayerchain, hidingfromplayerchain_prev);	}
*/
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
void ProjectileChain_Remove(entity e)	{	list_projectilechain = LinkedList_Remove(e, list_projectilechain, projectilechain, projectilechain_prev);	}

// GENERATION CHAINS

entity		list_unconnectedchunkchain;
.entity		unconnectedchunkchain;
.entity		unconnectedchunkchain_prev;
void UnconnectedChunkChain_Add(entity e)		{	list_unconnectedchunkchain = LinkedList_Add(e, list_unconnectedchunkchain, unconnectedchunkchain, unconnectedchunkchain_prev);	}
void UnconnectedChunkChain_Remove(entity e)		{	list_unconnectedchunkchain = LinkedList_Remove(e, list_unconnectedchunkchain, unconnectedchunkchain, unconnectedchunkchain_prev);	}

entity		list_matchingprefabchain;
.entity		matchingprefabchain;
.entity		matchingprefabchain_prev;
void MatchingPrefabChain_Add(entity e)		{	list_matchingprefabchain = LinkedList_Add(e, list_matchingprefabchain, matchingprefabchain, matchingprefabchain_prev);	}
void MatchingPrefabChain_Remove(entity e)	{	list_matchingprefabchain = LinkedList_Remove(e, list_matchingprefabchain, matchingprefabchain, matchingprefabchain_prev);	}

entity		list_prefabtypechain;
.entity		prefabtypechain;
.entity		prefabtypechain_prev;
void PrefabTypeChain_Add(entity e)		{	list_prefabtypechain = LinkedList_Add(e, list_prefabtypechain, prefabtypechain, prefabtypechain_prev);	}
void PrefabTypeChain_Remove(entity e)	{	list_prefabtypechain = LinkedList_Remove(e, list_prefabtypechain, prefabtypechain, prefabtypechain_prev);	}

