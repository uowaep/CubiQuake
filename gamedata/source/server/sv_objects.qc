void SendObjectData_Wrap() {}

float SendObj(entity viewer, float sendflags)
{
	int sendrotation = 0;
	
	WriteByte(MSG_ENTITY, ENT_OBJ);	
	WriteShort(MSG_ENTITY, sendflags);	

	if(sendflags & SFL_ISNEW)
	{
		WriteByte(MSG_ENTITY, self.objtype);
		WriteShort(MSG_ENTITY, self.modelindex);
		
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);			
		
		if(self.objtype == OBJ_BLOCK)
		{
			WriteByte(MSG_ENTITY, self.blocktype);

			if(!NonSolidType(self.blocktype))
			{
				WriteByte(MSG_ENTITY, self.blockshape);
				if(self.blockshape != BLOCKSHAPE_CUBE)
					sendrotation = TRUE;
				WriteByte(MSG_ENTITY, self.blockhealth);
			}
			else
				sendrotation = TRUE;
			
			if(sendrotation)
				WriteByte(MSG_ENTITY, self.blockrotation);			
		}
		
		SendObjectData_Wrap();		
	}
	
	if((sendflags & SFL_ISNEW) || (sendflags & SFL_MOVE) || (sendflags & SFL_STOP))
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	
	if((sendflags & SFL_ISNEW) || (sendflags & SFL_MOVE))
	{
		WriteCoord(MSG_ENTITY, self.realvelocity_x);
		WriteCoord(MSG_ENTITY, self.realvelocity_y);
		WriteCoord(MSG_ENTITY, self.realvelocity_z);	
	}

	if((sendflags & SFL_ISNEW) || (sendflags & SFL_ANIMATE))	// why not
		SendAnimation(self);

	return TRUE;	
}

void UpdateBlockObjects()
{
	entity e = __NULL__;
	vector org = '0 0 0', chunkorg = '0 0 0';
	
	while(list_blockobjectremovechain)
	{
		e = list_blockobjectremovechain;
		org = GetNearestCubicOrigin(e.origin, chunksize_iseven);
		chunkorg = GetNearChunkOrg(org);
		AddCubic(org, e.blocktype, e.blockshape, e.blockrotation, TRUE);
		entity chunk = GetChunkForLocation(__NULL__, chunkorg, __FUNC__);
		if(chunk)
			chunk.cubic_health[GetCubicRef(org-chunkorg)] = e.blockhealth;
		
		BlockObjectRemoveChain_Remove(e);
		Remove(e);	
	}
}

void Obj_Block_NetworkEntityFunc_Stop(entity e)
{
	ObjChain_Remove(e); // we can remove from the chain once the network is done with it
	BlockObjectRemoveChain_Add(e);
	// move values to chunk

}

void Obj_NetworkEntityFunc_Stop(entity e)
{
	if(!e.slide)
	if(e.flags & FL_ONGROUND) // on the ground
		ObjChain_Remove(e); // we can remove from the chain once the network is done with it
}

void Obj_Think(entity e)
{
	CheckWorldBounds(e);	// make corrections here before setting .realvelocity	
	
//	RollObject(e);	// csqc is handling this, but if the server needs to for some reason, uncomment this
	
	Movetype_BounceSlide(e);

// START COLLISION UPDATING

	if(e.flags & FL_ONGROUND)		
	if(!e.slide)// || e.velocity*e.velocity <= 50*50)	// not in a sliding state, or not trying to move
	if(e.physicssolidsset)
	{
		e.velocity = '0 0 0';
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		e.flags = e.flags | FL_FINDABLE_NONSOLID;
		LeaveSolidCubics(e, e.lastsolidcubicorigin);
		e.physicssolidsset = FALSE;
	}	

// END COLLISION UPDATING

	if(e.objtype == OBJ_BLOCK)
		NetworkEntity(e, Obj_Block_NetworkEntityFunc_Stop);
	else
		NetworkEntity(e, Obj_NetworkEntityFunc_Stop);
}