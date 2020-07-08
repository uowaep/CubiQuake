/*.entity		list_cubicchain;
.entity		cubicchain;
.entity		cubicchain_prev;
void CubicChain_Add(entity o, entity e)		{	o.list_cubicchain = LinkedList_Add(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}
void CubicChain_Remove(entity o, entity e)		{	o.list_cubicchain = LinkedList_Remove(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}*/

entity		list_ghostchunkchain;
.entity		ghostchunkchain;
.entity		ghostchunkchain_prev;
void GhostChunkChain_Add(entity e)		{	list_ghostchunkchain = LinkedList_Add(e, list_ghostchunkchain, ghostchunkchain, ghostchunkchain_prev);	}
void GhostChunkChain_Remove(entity e)		{	list_ghostchunkchain = LinkedList_Remove(e, list_ghostchunkchain, __NULL__, ghostchunkchain, ghostchunkchain_prev);	}

entity		list_ghostclusterchain;
.entity		ghostclusterchain;
.entity		ghostclusterchain_prev;
void GhostClusterChain_Add(entity e)		{	list_ghostclusterchain = LinkedList_Add(e, list_ghostclusterchain, ghostclusterchain, ghostclusterchain_prev);	}
void GhostClusterChain_Remove(entity e)		{	list_ghostclusterchain = LinkedList_Remove(e, list_ghostclusterchain, __NULL__, ghostclusterchain, ghostclusterchain_prev);	}

entity		list_objchain;
.entity		objchain;
.entity		objchain_prev;
void ObjChain_Add(entity e)			{	list_objchain = LinkedList_Add(e, list_objchain, objchain, objchain_prev);	}
void ObjChain_Remove(entity e)		{	list_objchain = LinkedList_Remove(e, list_objchain, __NULL__, objchain, objchain_prev);	}

.entity		list_cubicobjchain;
.entity		cubicobjchain;
.entity		cubicobjchain_prev;
void CubicObjChain_Add(entity o, entity e)		{	o.list_cubicobjchain = LinkedList_Add(e, o.list_cubicobjchain, cubicobjchain, cubicobjchain_prev);	}
void CubicObjChain_Remove(entity o, entity e)		{	o.list_cubicobjchain = LinkedList_Remove(e, o.list_cubicobjchain, __NULL__, cubicobjchain, cubicobjchain_prev);	}
