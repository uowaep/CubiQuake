void RemoveUnusedCubicBBoxes()
{
	entity e, nexte;
	for(e = list_unusedcubicbboxchain; e; e = nexte)
	{
		#ifdef DEBUG
		if(wasfreed(e))
			print("RemoveUnusedCubicBBoxes A wasfreed.\n");	
		#endif
		
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
	float yawofs = 0;
	
	if(!e)
	{
		e = spawn();
		e.enttype = ENT_CUBICBBOX;
		e.parentchunk = chunk;
		setorigin(e, org);
		e.effects = EF_NODRAW;
		
		int id = GetCubicRef(org-chunk.origin, __FUNC__);
		int shape = chunk.cubic_blockshape[id];
		int rotation = chunk.cubic_blockrotation[id];
		
		if(shape > BLOCKSHAPE_CUBE)
		{
			e.solid = SOLID_BSP;
			
			if(shape == BLOCKSHAPE_RAMP)
			{
				if(rotation <= BLOCKROTATION_S)
					setmodel(e, "models/collision/ramp.bsp");
				else
				if(rotation <= BLOCKROTATION_CW_S)
					setmodel(e, "models/collision/ramp_cw.bsp");
				else
				if(rotation <= BLOCKROTATION_UD_S)
					setmodel(e, "models/collision/ramp_ud.bsp");
				else
				if(rotation <= BLOCKROTATION_CCW_S)
				{
					setmodel(e, "models/collision/ramp_cw.bsp");
					yawofs = 90;
				}
			}
			else
			if(shape == BLOCKSHAPE_WEDGETIP)
			{
				if(rotation <= BLOCKROTATION_S)
					setmodel(e, "models/collision/wedgetip.bsp");
				else
				if(rotation <= BLOCKROTATION_CW_S)
					setmodel(e, "models/collision/wedgetip_cw.bsp");
				else
				if(rotation <= BLOCKROTATION_UD_S)
					setmodel(e, "models/collision/wedgetip_ud.bsp");
				else
				if(rotation <= BLOCKROTATION_CCW_S)
					setmodel(e, "models/collision/wedgetip_ccw.bsp");
				else
				if(rotation <= BLOCKROTATION_FW_S)
					setmodel(e, "models/collision/wedgetip_fw.bsp");
				else
				if(rotation <= BLOCKROTATION_BW_S)
					setmodel(e, "models/collision/wedgetip_bw.bsp");
			}
			else
			if(shape == BLOCKSHAPE_WEDGE)
			{
				if(rotation <= BLOCKROTATION_S)
					setmodel(e, "models/collision/wedge.bsp");
				else
				if(rotation <= BLOCKROTATION_CW_S)
					setmodel(e, "models/collision/wedge_cw.bsp");
				else
				if(rotation <= BLOCKROTATION_UD_S)
					setmodel(e, "models/collision/wedge_ud.bsp");
				else
				if(rotation <= BLOCKROTATION_CCW_S)
					setmodel(e, "models/collision/wedge_ccw.bsp");
				else
				if(rotation <= BLOCKROTATION_FW_S)
					setmodel(e, "models/collision/wedge_fw.bsp");
				else
				if(rotation <= BLOCKROTATION_BW_S)
					setmodel(e, "models/collision/wedge_bw.bsp");
			}
			else
			if(shape == BLOCKSHAPE_SLAB)
			{
				if(rotation <= BLOCKROTATION_S)
					setmodel(e, "models/collision/slab.bsp");
				else
				if(rotation <= BLOCKROTATION_CW_S)
					setmodel(e, "models/collision/slab_cw.bsp");
				else
				if(rotation <= BLOCKROTATION_UD_S)
					setmodel(e, "models/collision/slab_ud.bsp");
				else
				if(rotation <= BLOCKROTATION_CCW_S)
				{
					setmodel(e, "models/collision/slab_cw.bsp");
					yawofs = 180;
				}
			}
			
			e.angles_y = ((rotation/4)-floor(rotation/4))*4*90 + yawofs;
		}
		else
		{
			e.solid = SOLID_BSP;
			setmodel(e, "models/collision/cube.bsp");
		}
		
		CubicBBoxChain_Add(chunk, e);
		
		setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
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

				if(cubicorg_x >= worlddim_x*0.5 || cubicorg_x <= worlddim_x*-0.5
				|| cubicorg_y >= worlddim_y*0.5 || cubicorg_y <= worlddim_y*-0.5
				|| cubicorg_z >= worlddim_z*0.5 || cubicorg_z <= worlddim_z*-0.5)
					continue;

				cubicchunkorg = GetNearChunkOrg(cubicorg);
				chunk = GetChunkForLocation(__NULL__, cubicchunkorg);
				
				if(!chunk)
					continue;
				
				if(GetCubicStatus(chunk, cubicorg, TRUE) == -1)
					continue;
								
				for(e = chunk.list_cubicbboxchain; e; e = e.cubicbboxchain)
				{
					#ifdef DEBUG
					if(wasfreed(e))
						print("CallPhysicsFunctionForCubic A wasfreed.\n");	
					#endif
					
					if(e.origin == cubicorg)
						break;
				}
				
				func(chunk, e, cubicorg);
			}
		}
	}	
}

void SetSolidCubics(entity e, vector org)	{	CallPhysicsFunctionForCubic(org, SetSolidCubic_Func);	e.physicssolidsset = TRUE;	}
void LeaveSolidCubics(entity e, vector org)	{	if(e.physicssolidsset)	CallPhysicsFunctionForCubic(org, LeaveSolidCubic_Func);	}

entity GetCubicBBoxForLocation(vector cubicorg)
{
	for(entity bbox = findradius(cubicorg, 0); bbox; bbox = bbox.chain)
		if(bbox.enttype == ENT_CUBICBBOX)
			return bbox;

	return __NULL__;	
}