// PROJECTILE EXAMPLE

/*void FireballTouch()
{
	if(other == self.owner)
		return;

	// do stuff
	
	LeaveSolidCubics(self, self.lastsolidcubicorigin);
	Remove(self);
}

void FireFireball(entity attacker)
{
	entity fb = spawn();
	fb.owner = attacker;
	setmodel(fb, "models/player/h_player.mdl");
	fb.movetype = MOVETYPE_FLY;
	fb.solid = SOLID_BBOX;
	setsize(fb, '-1 -1 -1', '1 1 1');
	makevectors(attacker.v_angle);
	setorigin(fb, attacker.origin + attacker.view_ofs + v_forward*16);
	fb.velocity = v_forward*800;
	fb.touch = FireballTouch;
	fb.think = Remove_self;
	fb.nextthink = time+2.5;
	ProjectileChain_Add(fb);
}*/

void ProjectileUpdate()
{
	for(entity e = list_projectilechain; e; e = e.projectilechain)
	{
		#ifdef DEBUG
		if(wasfreed(e))
			print("ProjectileUpdate A wasfreed.\n");	
		#endif
		
		LeaveSolidCubics(e, e.lastsolidcubicorigin);
		SetSolidCubics(e, e.origin);
		e.lastsolidcubicorigin = e.origin;
	}
	
	RemoveUnusedCubicBBoxes();
}