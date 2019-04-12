.entity		list_cubicchain;
.entity		cubicchain;
.entity		cubicchain_prev;
void CubicChain_Add(entity o, entity e)		{	o.list_cubicchain = LinkedList_Add(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}
void CubicChain_Remove(entity o, entity e)		{	o.list_cubicchain = LinkedList_Remove(e, o.list_cubicchain, cubicchain, cubicchain_prev);	}
