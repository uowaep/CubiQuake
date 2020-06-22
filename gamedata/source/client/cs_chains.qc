entity		list_chunkchain;
.entity		chunkchain;
.entity		chunkchain_prev;
void ChunkChain_Add(entity e)			{	list_chunkchain = LinkedList_Add(e, list_chunkchain, chunkchain, chunkchain_prev);	}
void ChunkChain_Remove(entity e)		{	list_chunkchain = LinkedList_Remove(e, list_chunkchain, chunkchain, chunkchain_prev);	}

entity		list_drawfacegroupchain;
.entity		drawfacegroupchain;
.entity		drawfacegroupchain_prev;
void DrawFaceGroupChain_Add(entity e)		{	list_drawfacegroupchain = LinkedList_Add(e, list_drawfacegroupchain, drawfacegroupchain, drawfacegroupchain_prev);	}
void DrawFaceGroupChain_Remove(entity e)	{	list_drawfacegroupchain = LinkedList_Remove(e, list_drawfacegroupchain, drawfacegroupchain, drawfacegroupchain_prev);	}

entity		list_drawdamagefacegroupchain;
.entity		drawdamagefacegroupchain;
.entity		drawdamagefacegroupchain_prev;
void DrawDamageFaceGroupChain_Add(entity e)		{	list_drawdamagefacegroupchain = LinkedList_Add(e, list_drawdamagefacegroupchain, drawdamagefacegroupchain, drawdamagefacegroupchain_prev);	}
void DrawDamageFaceGroupChain_Remove(entity e)	{	list_drawdamagefacegroupchain = LinkedList_Remove(e, list_drawdamagefacegroupchain, drawdamagefacegroupchain, drawdamagefacegroupchain_prev);	}

.entity		list_facegroupchain;
.entity		facegroupchain;
.entity		facegroupchain_prev;
void FaceGroupChain_Add(entity o, entity e)			{	o.list_facegroupchain = LinkedList_Add(e, o.list_facegroupchain, facegroupchain, facegroupchain_prev);	}
void FaceGroupChain_Remove(entity o, entity e)		{	o.list_facegroupchain = LinkedList_Remove(e, o.list_facegroupchain, facegroupchain, facegroupchain_prev);	}

entity		list_ghostfacegroupchain;
.entity		ghostfacegroupchain;
.entity		ghostfacegroupchain_prev;
void GhostFaceGroupChain_Add(entity e)		{	list_ghostfacegroupchain = LinkedList_Add(e, list_ghostfacegroupchain, ghostfacegroupchain, ghostfacegroupchain_prev);	}
void GhostFaceGroupChain_Remove(entity e)	{	list_ghostfacegroupchain = LinkedList_Remove(e, list_ghostfacegroupchain, ghostfacegroupchain, ghostfacegroupchain_prev);	}

.entity		list_typegroupchain;
.entity		typegroupchain;
.entity		typegroupchain_prev;
void TypeGroupChain_Add(entity o, entity e)			{	o.list_typegroupchain = LinkedList_Add(e, o.list_typegroupchain, typegroupchain, typegroupchain_prev);	}
void TypeGroupChain_Remove(entity o, entity e)		{	o.list_typegroupchain = LinkedList_Remove(e, o.list_typegroupchain, typegroupchain, typegroupchain_prev);	}

entity		list_queuenearfacebuildchain;
.entity		queuenearfacebuildchain;
.entity		queuenearfacebuildchain_prev;
void QueueNearFaceBuildChain_Add(entity e)		{	list_queuenearfacebuildchain = LinkedList_Add(e, list_queuenearfacebuildchain, queuenearfacebuildchain, queuenearfacebuildchain_prev);	}
void QueueNearFaceBuildChain_Remove(entity e)	{	list_queuenearfacebuildchain = LinkedList_Remove(e, list_queuenearfacebuildchain, queuenearfacebuildchain, queuenearfacebuildchain_prev);	}

entity		list_queuefacebuildchain;
entity		listend_queuefacebuildchain;
.entity		queuefacebuildchain;
.entity		queuefacebuildchain_prev;
void QueueFaceBuildChain_Append(entity e)		{	list_queuefacebuildchain = LinkedList_Append(e, list_queuefacebuildchain, listend_queuefacebuildchain, queuefacebuildchain, queuefacebuildchain_prev);	listend_queuefacebuildchain = list_lastent;	}
void QueueFaceBuildChain_Remove_(entity e)	{	list_queuefacebuildchain = LinkedList_Remove(e, list_queuefacebuildchain, queuefacebuildchain, queuefacebuildchain_prev);	}

entity		list_queuedamagefacebuildchain;
entity		listend_queuedamagefacebuildchain;
.entity		queuedamagefacebuildchain;
.entity		queuedamagefacebuildchain_prev;
void QueueDamageFaceBuildChain_Append(entity e)		{	list_queuedamagefacebuildchain = LinkedList_Append(e, list_queuedamagefacebuildchain, listend_queuedamagefacebuildchain, queuedamagefacebuildchain, queuedamagefacebuildchain_prev);	listend_queuedamagefacebuildchain = list_lastent;	}
void QueueDamageFaceBuildChain_Remove_(entity e)	{	list_queuedamagefacebuildchain = LinkedList_Remove(e, list_queuedamagefacebuildchain, queuedamagefacebuildchain, queuedamagefacebuildchain_prev);	}

/*entity		list_queuedamagefacerebuildchain;
entity		listend_queuedamagefacerebuildchain;
.entity		queuedamagefacerebuildchain;
.entity		queuedamagefacerebuildchain_prev;
void QueueDamageFaceRebuildChain_Append(entity e)		{	list_queuedamagefacerebuildchain = LinkedList_Append(e, list_queuedamagefacerebuildchain, listend_queuedamagefacerebuildchain, queuedamagefacerebuildchain, queuedamagefacerebuildchain_prev);	listend_queuedamagefacerebuildchain = list_lastent;	}
void QueueDamageFaceRebuildChain_Remove_(entity e)	{	list_queuedamagefacerebuildchain = LinkedList_Remove(e, list_queuedamagefacerebuildchain, queuedamagefacerebuildchain, queuedamagefacerebuildchain_prev);	}*/

.entity		list_queueclearchunkdamagefaces;
.entity		queueclearchunkdamagefaces;
.entity		queueclearchunkdamagefaces_prev;
void QueueClearChunkDamageFaces_Add(entity o, entity e)		{	o.list_queueclearchunkdamagefaces = LinkedList_Add(e, o.list_queueclearchunkdamagefaces, queueclearchunkdamagefaces, queueclearchunkdamagefaces_prev);	}
void QueueClearChunkDamageFaces_Remove(entity o, entity e)		{	o.list_queueclearchunkdamagefaces = LinkedList_Remove(e, o.list_queueclearchunkdamagefaces, queueclearchunkdamagefaces, queueclearchunkdamagefaces_prev);	}

entity		list_dynamiclightchain;
.entity		dynamiclightchain;
.entity		dynamiclightchain_prev;
void DynamicLightChain_Add(entity e)		{	list_dynamiclightchain = LinkedList_Add(e, list_dynamiclightchain, dynamiclightchain, dynamiclightchain_prev);	}
void DynamicLightChain_Remove(entity e)		{	list_dynamiclightchain = LinkedList_Remove(e, list_dynamiclightchain, dynamiclightchain, dynamiclightchain_prev);	}

entity		list_staticlightchain;
.entity		staticlightchain;
.entity		staticlightchain_prev;
void StaticLightChain_Add(entity e)			{	list_staticlightchain = LinkedList_Add(e, list_staticlightchain, staticlightchain, staticlightchain_prev);	}
void StaticLightChain_Remove(entity e)		{	list_staticlightchain = LinkedList_Remove(e, list_staticlightchain, staticlightchain, staticlightchain_prev);	}

.entity		list_chunklightchain;
.entity		chunklightchain;
.entity		chunklightchain_prev;
void ChunkLightChain_Add(entity o, entity e)		{	o.list_chunklightchain = LinkedList_Add(e, o.list_chunklightchain, chunklightchain, chunklightchain_prev);	}
void ChunkLightChain_Remove(entity o, entity e)		{	o.list_chunklightchain = LinkedList_Remove(e, o.list_chunklightchain, chunklightchain, chunklightchain_prev);	}

entity		list_staticlitfacegroupchain;
.entity		staticlitfacegroupchain;
.entity		staticlitfacegroupchain_prev;
void StaticLitFaceGroupChain_Add(entity e)			{	list_staticlitfacegroupchain = LinkedList_Add(e, list_staticlitfacegroupchain, staticlitfacegroupchain, staticlitfacegroupchain_prev);	}
void StaticLitFaceGroupChain_Remove(entity e)		{	list_staticlitfacegroupchain = LinkedList_Remove(e, list_staticlitfacegroupchain, staticlitfacegroupchain, staticlitfacegroupchain_prev);	}

entity		list_litfacegroupchain;
.entity		litfacegroupchain;
.entity		litfacegroupchain_prev;
void LitFaceGroupChain_Add(entity e)			{	list_litfacegroupchain = LinkedList_Add(e, list_litfacegroupchain, litfacegroupchain, litfacegroupchain_prev);	}
void LitFaceGroupChain_Remove(entity e)			{	list_litfacegroupchain = LinkedList_Remove(e, list_litfacegroupchain, litfacegroupchain, litfacegroupchain_prev);	}

.entity		list_chunkentchain;
.entity		chunkentchain;
.entity		chunkentchain_prev;
void ChunkEntChain_Add(entity o, entity e)		{	o.list_chunkentchain = LinkedList_Add(e, o.list_chunkentchain, chunkentchain, chunkentchain_prev);	}
void ChunkEntChain_Remove(entity o, entity e)	{	o.list_chunkentchain = LinkedList_Remove(e, o.list_chunkentchain, chunkentchain, chunkentchain_prev);	}

entity		list_clearchunkentchain;
.entity		clearchunkentchain;
.entity		clearchunkentchain_prev;
void ClearChunkEntChain_Add(entity e)			{	list_clearchunkentchain = LinkedList_Add(e, list_clearchunkentchain, clearchunkentchain, clearchunkentchain_prev);	}
void ClearChunkEntChain_Remove(entity e)		{	list_clearchunkentchain = LinkedList_Remove(e, list_clearchunkentchain, clearchunkentchain, clearchunkentchain_prev);	}

entity		list_infoeditchunksidechain;
.entity		infoeditchunksidechain;
.entity		infoeditchunksidechain_prev;
void InfoEditChunkSideChain_Add(entity e)			{	list_infoeditchunksidechain = LinkedList_Add(e, list_infoeditchunksidechain, infoeditchunksidechain, infoeditchunksidechain_prev);	}
void InfoEditChunkSideChain_Remove(entity e)		{	list_infoeditchunksidechain = LinkedList_Remove(e, list_infoeditchunksidechain, infoeditchunksidechain, infoeditchunksidechain_prev);	}

.entity		list_chunkbloatchain;
.entity		chunkbloatchain;
.entity		chunkbloatchain_prev;
void ChunkBloatChain_Add(entity o, entity e)		{	o.list_chunkbloatchain = LinkedList_Add(e, o.list_chunkbloatchain, chunkbloatchain, chunkbloatchain_prev);	}
void ChunkBloatChain_Remove(entity o, entity e)	{	o.list_chunkbloatchain = LinkedList_Remove(e, o.list_chunkbloatchain, chunkbloatchain, chunkbloatchain_prev);	}


entity		list_queuechunkbloatchain;
.entity		queuechunkbloatchain;
.entity		queuechunkbloatchain_prev;
void QueueChunkBloatChain_Add(entity e)			{	list_queuechunkbloatchain = LinkedList_Add(e, list_queuechunkbloatchain, queuechunkbloatchain, queuechunkbloatchain_prev);	}
void QueueChunkBloatChain_Remove(entity e)		{	list_queuechunkbloatchain = LinkedList_Remove(e, list_queuechunkbloatchain, queuechunkbloatchain, queuechunkbloatchain_prev);	}

entity		list_resetambientlightchain;
.entity		resetambientlightchain;
.entity		resetambientlightchain_prev;
void ResetAmbientLightChain_Add(entity e)			{	list_resetambientlightchain = LinkedList_Add(e, list_resetambientlightchain, resetambientlightchain, resetambientlightchain_prev);	}
void ResetAmbientLightChain_Remove(entity e)		{	list_resetambientlightchain = LinkedList_Remove(e, list_resetambientlightchain, resetambientlightchain, resetambientlightchain_prev);	}


/*void ChunkChain_Sort(entity chunk)
{
	entity oldlist, lastlistent;
	vector chainofs;
	float chaindist;

	if(!list_chunkchain)
		return;
	
	vector listofs = list_chunkchain.origin - view_org;
	float listdist = listofs*listofs;
	
	if(!list_chunkchain.chunkchain)
		return;
	
	for(entity e = list_chunkchain.chunkchain; e; e = e.chunkchain)
	{
		chainofs = e.origin - view_org;
		chaindist = chainofs*chainofs;
		
		if(listdist <= chaindist)
		{
			if(e == list_chunkchain.chunkchain)
				return;
			
			oldlist = list_chunkchain;
			
			list_chunkchain = list_chunkchain.chunkchain;
			list_chunkchain.chunkchain_prev = __NULL__;
			
			e.chunkchain_prev.chunkchain = oldlist;
			oldlist.chunkchain_prev = e.chunkchain_prev;
			oldlist.chunkchain = e;
			e.chunkchain_prev = oldlist;
			return;
		}
		
		lastlistent = e;
	}
	
	// end of list	
	lastlistent.chunkchain = list_chunkchain;
	list_chunkchain = list_chunkchain.chunkchain;
	list_chunkchain.chunkchain_prev = __NULL__;
	lastlistent.chunkchain.chunkchain_prev = lastlistent;
	lastlistent.chunkchain.chunkchain = __NULL__;
}*/