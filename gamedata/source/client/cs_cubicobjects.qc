float Predraw_Torch()
{
	if(editor_infoedit)
	if(self.parentchunk.chunkid != editor_editchunk)
		return PREDRAW_NEXT;
	
	AnimateModel(self);
	
	return PREDRAW_AUTOADD;
}

entity SetChunkCubicObject(entity chunk, int memslot, int type)
{
	for(entity e = chunk.list_cubicobjchain; e; e = e.cubicobjchain)
	{
		if(e.cubicmemslot == memslot)
			return e;
	}	
	
	entity e = spawn();
	e.enttype = ENT_CUBICOBJ;
	SetModelForCubicObject(e, type, TRUE);
	setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
	SetYawForCubicObject(e, chunk.cubic_blockrotation[memslot]);
	e.solid = SOLID_BBOX;
	setorigin(e, chunk.origin + GetCubicOffset(memslot) + GetModelOffsetForBlockType(type));
	e.drawmask = MASK_NORMAL;
	e.blocktype = type;
	e.cubicmemslot = memslot;
	e.parentchunk = chunk;
	e.ob_flags = e.oldblockflags = chunk.cubic_flags[memslot];
	
	e.staticrgb = e.colormod = ambientlight_modified;			
	RelightEntChain_Add(e); // this removes once lit
	LightEntChain_Add(e); //this is referenced every frame for dynamic lights
	
	CubicObjChain_Add(chunk, e);
	return e;
}

// for adding new cubic objects like the torch to mods
int LoadCubic_Wrap_Pre(entity chunk, int memslot, int type, int returnvalue)
{
	return returnvalue;
}

void LoadCubic_Wrap_Post(entity chunk, int memslot, int type, entity modelent){}

void LoadCubic(entity chunk, int memslot, int type)
{
	entity typegroup = __NULL__, modelent = __NULL__;	
	
	if(LoadCubic_Wrap_Pre(chunk, memslot, type, FALSE))
		return;
	
	switch(type)
	{
		// EXAMPLE CUBIC OBJECT : Light
		case BLOCKTYPE_TORCH:	modelent = SetChunkCubicObject(chunk,  memslot, type);
								SetChunkLight(modelent, chunk, 416, '1 0.9 0.7', 2, CUBICFLAG_ON);	 // adds a light to the chunk of specified type (BLOCKTYPE_TORCH in this case)
								modelent.lightofs = '0 0 4';
								SetAnimation(modelent, 0, 6, 0.1, TRUE, FALSE, TRUE);	// Sets up the animation for this model.
								modelent.predraw = Predraw_Torch;	// set predraw func if necessary
							//	modelent.parentchunk = chunk;
								break;
		
		// default trisoup_simple cubic
		default:				for(typegroup = chunk.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
									if(typegroup.blocktype == type)
										break;
								if(!typegroup)	// texture set group for chunk
								{
									CreateTypeGroup(chunk, type);
								//	chunk.list_typegroupchain.lightcolor = ambientlight;		// NOTE: the .list_ chain entity is always the last added to the list (but this should only be trusted if it was just added)
								}
								
								break;
	}	
	
	LoadCubic_Wrap_Post(chunk, memslot, type, modelent);
}