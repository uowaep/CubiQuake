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
		e.solid = SOLID_BBOX;
		setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
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
				
				if(GetCubicStatus(chunk, cubicorg) == -1)
					continue;
								
				for(e = chunk.list_cubicbboxchain; e; e = e.cubicbboxchain)
					if(e.origin == cubicorg)
						break;
				
				func(chunk, e, cubicorg);
			}
		}
	}	
}

void SetSolidCubics(vector org)		{	CallPhysicsFunctionForCubic(org, SetSolidCubic_Func);	}
void LeaveSolidCubics(vector org)	{	CallPhysicsFunctionForCubic(org, LeaveSolidCubic_Func);	}
