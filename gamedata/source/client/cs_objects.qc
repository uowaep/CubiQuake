.entity	typegroup_faces;
.entity	typegroup_damage;

float DEG2RAD = 0.0174532925199432957692369076848861271344287188854172545609719144;
//float RAD2DEG = 57.2957795130823208767981548141051703324054724665643215491602438612;
float PI      = 3.1415926535897932384626433832795028841971693993751058209749445923;

void RollObject(entity e)
{
	float slidelimit = max(1, e.physics_maxslidespeed); 

	if(e.velocity_z > -1 && e.velocity_z < 1)
	if(e.velocity*e.velocity <= slidelimit*slidelimit)
		return;

	float ang = 0, rad = 0;
	vector vec = '0 0 0';
	vector axis_forward = '0 0 0', axis_up = '0 0 0';

	float escale = 1;
	if(e.scale)
		escale = escale;
	float objectradius = 16*escale;
	float cir = 2*PI*objectradius;
	
	makevectors([e.angles_x*-1, e.angles_y, e.angles_z]);
	axis_forward = v_forward;
	axis_up = v_up;
	
	float vertical_vel = 0;		// use this for rolling on ramps
	
	// Roll X axis.
	rad = vlen([axis_forward_x, axis_forward_z, 0]);
	vec = [axis_forward_x, axis_forward_z, 0];
	ang = FixAngle(vectoyaw(vec) - (e.velocity_x+vertical_vel)/cir*360*frametime);
	axis_forward_x = cos(ang*DEG2RAD) * rad;
	axis_forward_z = sin(ang*DEG2RAD) * rad;

	rad = vlen([axis_up_x, axis_up_z, 0]);
	vec = [axis_up_x, axis_up_z, 0];
	ang = FixAngle(vectoyaw(vec) - (e.velocity_x+vertical_vel)/cir*360*frametime);
	axis_up_x = cos(ang*DEG2RAD) * rad;
	axis_up_z = sin(ang*DEG2RAD) * rad;

	// Roll Y axis.
	rad = vlen([axis_forward_y, axis_forward_z, 0]);
	vec = [axis_forward_y, axis_forward_z, 0];
	ang = FixAngle(vectoyaw(vec) - (e.velocity_y+vertical_vel)/cir*360*frametime);
	axis_forward_y = cos(ang*DEG2RAD) * rad;
	axis_forward_z = sin(ang*DEG2RAD) * rad;

	rad = vlen([axis_up_y, axis_up_z, 0]);
	vec = [axis_up_y, axis_up_z, 0];
	ang = FixAngle(vectoyaw(vec) - (e.velocity_y+vertical_vel)/cir*360*frametime);
	axis_up_y = cos(ang*DEG2RAD) * rad;
	axis_up_z = sin(ang*DEG2RAD) * rad;
	
	e.angles = vectoangles(axis_forward, axis_up);
}	

void Predraw_Obj_Wrap() {}
float Predraw_Obj()
{
	UpdateEntityOrientation(self);
	self.drawmask = MASK_NORMAL;	// why is this here and not at the update?
//	AnimateModel(self);

	if(self.obj_roll)
		RollObject(self);

	if(self.origin != self.origin_previous)	// if moved, add to relight chain
		RelightEntChain_Add(self);
	self.origin_previous = self.origin;
	self.origin_previous_set = TRUE;

	Predraw_Obj_Wrap();

	return PREDRAW_AUTOADD;	
}

float Predraw_ObjBlock()
{
	UpdateEntityOrientation(self);
	return PREDRAW_AUTOADD;	
}

int ReadObjectData_Wrap(int nomodel) {return nomodel;}
void SpawnObjectEffects_Wrap(vector org, int isnew) {}
void UpdateObj(float isnew)
{
	vector org = '0 0 0';
	float mdlindex = 0;
	int nomodel = 0, gibflags = 0, numparticles = 0, getrotation = 0;
	
	float sendflags = readshort();
	
	if(sendflags & SFL_ISNEW)
	{
		self.enttype = ENT_OBJ;
		self.objtype = readbyte();
	//	self.modelindex = readshort();
		mdlindex = readshort();
		
	//	self.solid = SOLID_BBOX;		// probably don't need a solid here
	//	setsize(self, '-32 -32 -32', '32 32 32');
		
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();  // z? maybe if server needs to actually roll the object

		if(self.objtype == OBJ_BLOCK)
		{
			self.blocktype = readbyte();		

			if(!NonSolidType(self.blocktype))
			{
				self.ob_shape = readbyte();			
				self.ob_health = readbyte();
				
				if(self.ob_shape != BLOCKSHAPE_CUBE)
					getrotation = TRUE;
			}	
			else
				getrotation = TRUE;
		
			if(getrotation)
				self.ob_rotation = readbyte();	
			
		//	BuildFacesForShape(self, self.ob_shape, self.ob_rotation, 0, self.origin, 1, 1, DRAWLIST_EDIT);
			BlockObjectChain_Add(self);
			setmodel(self, "null");
			self.drawmask = MASK_NORMAL;
			self.predraw = Predraw_ObjBlock;
			nomodel = TRUE;
		}
		
		nomodel = ReadObjectData_Wrap(nomodel);

		if(!nomodel)
		{
			setmodel(self, modelnameforindex(mdlindex));
			self.drawmask = MASK_NORMAL;
			self.movementcorrection = '0 0 0';	// seems like i could delete this line (also in ai code)
			self.predraw = Predraw_Obj;
			self.staticrgb = self.colormod = ambientlight_modified;			
			RelightEntChain_Add(self); // this removes once lit
			LightEntChain_Add(self); //this is referenced every frame for dynamic lights
		}
		
	//	ResetStaticLights(FALSE);	// FALSE makes it use the static light delay for spawn in (for performance and and all that)
	}	
		
	if((sendflags & SFL_ISNEW) || (sendflags & SFL_MOVE) || (sendflags & SFL_STOP))
	{		
		org_x = readcoord();
		org_y = readcoord();
		org_z = readcoord();
	
		if(sendflags & SFL_ISNEW)
			setorigin(self, org);
		else
		if((sendflags & SFL_MOVE) || (sendflags & SFL_STOP))
		{
			self.movementcorrection = org - self.origin;
			self.movetime = time;
			
			if(sendflags & SFL_STOP)
				self.velocity = '0 0 0';
		}
		
		self.sharedorigin = org;
	}
	
	if((sendflags & SFL_ISNEW) || (sendflags & SFL_MOVE))
	{		
		self.velocity_x = readcoord();
		self.velocity_y = readcoord();
		self.velocity_z = readcoord();
	}
	
	SpawnObjectEffects_Wrap(org, isnew);
	
	if(sendflags & SFL_ANIMATE)
		ReadAnimation(self);	
}

// call this every frame while they are moving or whenever health changes
void RebuildObjectFaces()
{
	entity e = __NULL__, typegroup = __NULL__, facegroup = __NULL__, nexte = __NULL__;
	
	for(e = list_blockobjectchain; e; e = e.blockobjectchain)
		for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
			for(facegroup = typegroup.list_facegroupchain; facegroup; facegroup = nexte)
			{
				nexte = facegroup.facegroupchain;
				RemoveFaceGroup(typegroup, facegroup, FALSE);
			}
		
	for(e = list_blockobjectchain; e; e = e.blockobjectchain)
	{
		if(!e.typegroup_faces)
		{
			e.typegroup_faces = spawn();
			e.typegroup_faces.blocktype = e.blocktype;
			TypeGroupChain_Add(e, e.typegroup_faces);
		}
		
		if(!e.typegroup_damage)
		{
			e.typegroup_damage = spawn();
			TypeGroupChain_Add(e, e.typegroup_damage);
		}
		
		e.typegroup_damage.blocktype = GetFaceTypeForDamage(e.ob_health);
		
		BuildFacesForShape(e.typegroup_faces, e.ob_shape, e.ob_rotation, 0, e.origin, 1, 1, DRAWLIST_CHUNK);
		if(e.ob_health <= maxdmghealth)
			BuildFacesForShape(e.typegroup_damage, e.ob_shape, e.ob_rotation, 0, e.origin, 1, 1, DRAWLIST_DMG);
	}
}