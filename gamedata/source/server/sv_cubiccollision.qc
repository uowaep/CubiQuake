.vector	lastsolidcubicorigin;
.int	collisioncount;
.int	physicssolidsset;

void RemoveUnusedCubicBBoxes()
{
	entity e, nexte;
	for(e = list_unusedcubicbboxchain; e; e = nexte)
	{
		nexte = e.unusedcubicbboxchain;
		Remove(e);	
	}
}

void LeaveSolidCubic_Func(entity chunk, entity e, vector org)
{
	if(e)
	{
		e.collisioncount -= 1;
		if(!e.collisioncount)
			UnusedCubicBBoxChain_Add(e);
	}
}

void SetSolidCubic_Func(entity chunk, entity e, vector org)
{
	if(!e)
	{
		e = spawn();
		e.enttype = ENT_CUBICBBOX;
		e.parentchunk = chunk;
		setorigin(e, org);
		e.effects = EF_NODRAW;
		
		int id = GetCubicRef(org-chunk.origin);
		int shape = chunk.cubic_blockshape[id];
		int rotation = chunk.cubic_blockrotation[id];
		
		if(shape > BLOCKSHAPE_CUBE)
		{
			e.solid = SOLID_BSP;
	
			if(shape == BLOCKSHAPE_RAMP)
				setmodel(e, "models/collision/ramp.bsp");
			else
			if(shape == BLOCKSHAPE_WEDGETIP)
				setmodel(e, "models/collision/wedgetip.bsp");
			else
			if(shape == BLOCKSHAPE_WEDGE)
				setmodel(e, "models/collision/wedge.bsp");
			
			e.angles_y = ((rotation/4)-floor(rotation/4))*4*90;
			
			if(rotation >= BLOCKROTATION_BW_E)
				e.angles_x = -90;
			else
			if(rotation >= BLOCKROTATION_FW_E)
				e.angles_x = 90;
			else				
				e.angles_z = floor(rotation/4)*90;				
		}
		else
		{
			e.solid = SOLID_BBOX;
			setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
		}
		
		CubicBBoxChain_Add(chunk, e);
	}
	else
		UnusedCubicBBoxChain_Remove(e);
	
	e.collisioncount+=1;
}

void CallPhysicsFunctionForCubic(vector org, void(entity, entity, vector) func)
{
	vector cubicorg, cubicchunkorg, physicsorg, pos;
	entity e, chunk;
	
	physicsorg = GetNearestCubicOrigin(org, chunksize_iseven != physicssize_iseven);
	
	for(pos_x = 0; pos_x < physicssize; pos_x++)
	{
		for(pos_y = 0; pos_y < physicssize; pos_y++)
		{
			for(pos_z = 0; pos_z < physicssize; pos_z++)
			{
				cubicorg = physicsorg + ('-1 -1 -1'*physicssize*0.5 + pos)*cubicradius*2 + '1 1 1'*cubicradius;

				cubicchunkorg = GetNearChunkOrg(cubicorg);
				chunk = GetChunkForLocation(chunk, cubicchunkorg);
				
				if(!chunk)
					continue;
				
				if(GetCubicStatus(chunk, cubicorg, TRUE) == -1)
					continue;
								
				for(e = chunk.list_cubicbboxchain; e; e = e.cubicbboxchain)
					if(e.origin == cubicorg)
						break;
				
				func(chunk, e, cubicorg);
			}
		}
	}	
}

void SetSolidCubics(entity e, vector org)	{	CallPhysicsFunctionForCubic(org, SetSolidCubic_Func);	e.physicssolidsset = TRUE;	}
void LeaveSolidCubics(entity e, vector org)	{	if(e.physicssolidsset)	CallPhysicsFunctionForCubic(org, LeaveSolidCubic_Func);	}
