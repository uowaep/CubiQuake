void SetModelForCubicObject(entity cubic, int type, int setbboxsize)
{
	switch(type)
	{
		case BLOCKTYPE_TORCH:		setmodel(cubic, "models/objects/torch.mdl");		break;
	}
	
	if(setbboxsize)
		setsize(cubic, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
}

float Predraw_Torch()
{
	AnimateModel(self);
	return PREDRAW_AUTOADD;
}