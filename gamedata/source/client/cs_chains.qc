entity		list_chunkchain;
.entity		chunkchain;
.entity		chunkchain_prev;
void ChunkChain_Add(entity e)		{	list_chunkchain = LinkedList_Add(e, list_chunkchain, chunkchain, chunkchain_prev);	}
void ChunkChain_Remove(entity e)		{	list_chunkchain = LinkedList_Remove(e, list_chunkchain, chunkchain, chunkchain_prev);	}

.entity		list_facegroupchain;
.entity		facegroupchain;
.entity		facegroupchain_prev;
void FaceGroupChain_Add(entity o, entity e)		{	o.list_facegroupchain = LinkedList_Add(e, o.list_facegroupchain, facegroupchain, facegroupchain_prev);	}
void FaceGroupChain_Remove(entity o, entity e)		{	o.list_facegroupchain = LinkedList_Remove(e, o.list_facegroupchain, facegroupchain, facegroupchain_prev);	}

.entity		list_typegroupchain;
.entity		typegroupchain;
.entity		typegroupchain_prev;
void TypeGroupChain_Add(entity o, entity e)		{	o.list_typegroupchain = LinkedList_Add(e, o.list_typegroupchain, typegroupchain, typegroupchain_prev);	}
void TypeGroupChain_Remove(entity o, entity e)		{	o.list_typegroupchain = LinkedList_Remove(e, o.list_typegroupchain, typegroupchain, typegroupchain_prev);	}

void ChunkChain_Sort(entity chunk)
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
}