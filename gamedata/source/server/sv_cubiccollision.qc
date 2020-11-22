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


void SetBlockModelAndAngles(entity e, int shape, int rotation)
{
	float yawofs = 0;
	
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
		
		SetBlockModelAndAngles(e, shape, rotation);
		setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
			
		CubicBBoxChain_Add(chunk, e);
		
//		setsize(e, '-1 -1 -1'*cubicradius, '1 1 1'*cubicradius);
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
				chunk = GetChunkForLocation(__NULL__, cubicchunkorg, __FUNC__);
				
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

void CheckWorldBounds(entity e)
{
	vector worldedgeoffset = '0 0 0', ofs = '0 0 0';
	
	if(e.movetype == MOVETYPE_NOCLIP)
		return;
	
	if(e.ignoreworldbounds)
		return;
	
	// very edge of world
	worldedgeoffset_x = worlddim_x*0.5 - cubicradius;
	worldedgeoffset_y = worlddim_y*0.5 - cubicradius;
	worldedgeoffset_z = worlddim_z*0.5 - cubicradius;	// z can potentially be different than x and y
	
	if(e.origin_x > worldedgeoffset_x)
		ofs_x = worldedgeoffset_x - e.origin_x;

	if(e.origin_x < worldedgeoffset_x*-1)
		ofs_x = worldedgeoffset_x*-1 - e.origin_x;
		
	if(e.origin_y > worldedgeoffset_y)
		ofs_y = worldedgeoffset_y - e.origin_y;
	
	if(e.origin_y < worldedgeoffset_y*-1)
		ofs_y = worldedgeoffset_y*-1 - e.origin_y;

	if(e.origin_z > worldedgeoffset_z)
		ofs_z = worldedgeoffset_z - e.origin_z;

	if(e.origin_z < worldedgeoffset_z*-1)
	if(e.flags & FL_CLIENT)
		ofs_z = worldedgeoffset_z*-1 - e.origin_z;	// players just slide around on the top of the void
	else
	{
		Remove(e);		// other entities remove
		return;
	}

// don't let anything out except players, but should unload objects when chunks unload too, which will happen anyway eventually but in the meantime the 10 second removal delay *should* prevent anything weird
	if(e.removepastworldbounds)
	if(ofs != '0 0 0')
	{
		Remove(e);
		return;
	}

	if(ofs != '0 0 0')
		setorigin(e, e.origin+ofs);
}

float	bs_minbounceveltogravratio	= 0.275;
void Movetype_BounceSlide(entity e)
{
	if(e.movetype != MOVETYPE_BOUNCESLIDE)
		return;

	vector tracetarget = '0 0 0';
	int slidestart = 0;
	float tracepadding = 1;
	
	if(e.bs_tracepadding)
		tracepadding = e.bs_tracepadding;
	
	if(!(e.bsflags & BSFLAG_NOGRAVITY))
	{
		tracebox(e.origin, e.mins, e.maxs, e.origin+'0 0 -2', MOVE_NORMAL, e);	// see what's under the object

		if(trace_fraction == 1) // nothing 1 unit below (not on the ground)
		{
			e.slide = FALSE;
			e.flags = e.flags - (e.flags & FL_ONGROUND);
		}
		else
			e.flags = e.flags | FL_ONGROUND;		
		
		if(!e.slide)
		if(!(e.flags & FL_ONGROUND))
			e.velocity_z = e.velocity_z - autocvar_sv_gravity*frametime;	// applies gravity from sv_gravity cvar unless the object is sliding or onground
	}
	
//	if((e.velocity*frametime)*(e.velocity*frametime) < tracepadding*tracepadding)
//		tracetarget = e.origin + normalize(e.velocity)*tracepadding;	// trace at least 1 unit
//	else
//		tracetarget = e.origin+e.velocity*frametime;

	vector padofs = normalize(e.velocity)*tracepadding;
	tracetarget = e.origin+e.velocity*frametime + padofs;

	tracebox(e.origin, e.mins, e.maxs, tracetarget, MOVE_NORMAL, e);	// see what's in front of the object's velocity for this frame

	vector org = e.origin;
	// check if object will hit something
	if(trace_fraction < 1)
	{
		vector vel = e.velocity;
		
		if(e.bsflags & BSFLAG_NOBOUNCE)	// don't bounce (stop)
		{
		//	if((trace_endpos-e.origin)*(trace_endpos-e.origin) > 1)
		//		trace_endpos - normalize(vel);
			
			if(trace_plane_normal_x)
				vel_x = 0;
					
			if(trace_plane_normal_y)
				vel_y = 0;
			
			if(trace_plane_normal_z)
				vel_z = 0;
			
			e.velocity = vel;
		}
		else
		{								// bounce off it at half speed
			if(trace_plane_normal_x)
				vel_x = vel_x*-1;
					
			if(trace_plane_normal_y)
				vel_y = vel_y*-1;
			
			if(trace_plane_normal_z)
				vel_z = vel_z*-1;

			e.velocity = vel*0.5;		
		}
		
		if(e.pushvelocity != '0 0 0')
			e.velocity = e.pushvelocity;
		
		org = trace_endpos - padofs;
	}

	// check to see if z bounce is weak, and if so, slide (or continue sliding)
	if(e.flags & FL_ONGROUND)
	if(e.velocity_z <= autocvar_sv_gravity*bs_minbounceveltogravratio)	// > 220 is min jump velocity because of this
	{
		slidestart = TRUE;
		e.slide = TRUE;
	}
	else	// if bouncing, stop sliding, remove FL_ONGROUND flag
	{
		e.slide = FALSE;
		e.flags = e.flags - (e.flags & FL_ONGROUND);
	}

	if(e.slide)
	{
		e.velocity_z = 0;	// make sure z velocity doesn't change from 0 during a slide
		e.velocity = e.velocity - normalize(e.velocity)*min(vlen(e.velocity), e.groundfriction*frametime);	// apply ground friction (make this use an entity field)

		// end the slide when movement stops. this allows collision detection and thinking to stop for the object (when .slide is FALSE and FL_ONGROUND is set)
		if(e.velocity*e.velocity <= 1)
			e.slide = FALSE;
	}
//	else
//		e.velocity = e.velocity - normalize(e.velocity)*min(vlen(e.velocity), 80*frametime);	// air friction (optional)
	
	// get movement offset for this frame
	vector ofs = e.velocity*frametime;// + normalize(e.velocity)*tracepadding;
		
	if(ofs != '0 0 0')
	{
		// if we bounced earlier, or began sliding, trace offset before applying movement
		if(trace_fraction < 1 || slidestart)
		{
			padofs = normalize(ofs)*tracepadding;
			tracetarget = org+ofs + padofs;			
			tracebox(org, e.mins, e.maxs, tracetarget, MOVE_NORMAL, e);	// make sure any bouncing doesn't put the object past a different surface	

			if(trace_fraction < 1)
				ofs = trace_endpos-org-padofs;
		}

		if(trace_fraction)
		{
		//	vector diff = ofs;//*trace_fraction;
		//	if(diff*diff > 1)
				setorigin(e, org+ofs);//*trace_fraction - normalize(e.velocity)*tracepadding);	// update origin
		}
	}
}