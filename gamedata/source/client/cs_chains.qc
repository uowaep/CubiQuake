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