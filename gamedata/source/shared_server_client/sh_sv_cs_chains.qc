entity		list_affectedchunkchain;
.entity		affectedchunkchain;
.entity		affectedchunkchain_prev;
void AffectedChunkChain_Add(entity e)		{	list_affectedchunkchain = LinkedList_Add(e, list_affectedchunkchain, affectedchunkchain, affectedchunkchain_prev);	}
void AffectedChunkChain_Remove(entity e)		{	list_affectedchunkchain = LinkedList_Remove(e, list_affectedchunkchain, affectedchunkchain, affectedchunkchain_prev);	}

.entity		list_cubicchain;
.entity		cubicchain;
.entity		cubicchain_prev;
void CubicChain_Add(entity o, entity e)		{	o.list_cubicchain = LinkedList_Add(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}
void CubicChain_Remove(entity o, entity e)		{	o.list_cubicchain = LinkedList_Remove(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}
