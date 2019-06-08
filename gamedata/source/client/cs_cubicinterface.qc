entity	cubeselector;
float	updatehudtooltime;

void UpdateCubicInterface()
{
	int tool = getstati(STAT_TOOL);	
	
	if(time >= updatehudtooltime)
	{
		updatehudtooltime = time+0.06;		// TraceCubic kills fps, no need to update every single frame
		

		int toolsize = getstati(STAT_TOOLSIZE);
		int playerclusterid = getstati(STAT_PLAYERCLUSTERID);
		float toolscale = GetToolScale(toolsize);
		int type = getstati(STAT_EDITOR_BLOCKTYPE);	
		int	toolshape = getstati(STAT_EDITOR_BLOCKSHAPE);
		int	toolrotation = getstati(STAT_EDITOR_BLOCKROTATION);
		int toolonedge;
		entity facegroup, nexte;
		vector cubicpos, clusterpos;
		vector org = '0 0 0';
		int	drawingnonsolid = FALSE;
		
		if(tool >= TOOL_EDITOR_REMOVE && tool <= TOOL_EDITOR_PASTE)
		{
			int getinside = FALSE;
			if(tool == TOOL_EDITOR_REMOVE || tool == TOOL_EDITOR_COPY)
				getinside = TRUE;
			
			makevectors(view_ang);
		//	traceline(view_org, view_org+v_forward*cubicradius*2*20, 0, cubeselector);
			
		//	if(trace_fraction < 1)
		//		org = GetNearestCubicOrigin(trace_ent.origin, chunksize_iseven);
		//	else
		//	{
				cubicpos = TraceCubic(view_org, view_org + v_forward*cubicradius*2*20, getinside);

				switch(toolsize)
				{
					case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(cubicpos, chunksize_iseven);	break;
					case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(cubicpos);							break;
					case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(cubicpos);							break;
				}
		//	}
			
			clusterpos = GetClusterOffset(playerclusterid);
			toolonedge = ToolIsOnEdge(clusterpos, org);
			
			if(getinside || toolscale > 1)
			{
				if(cubeselector.blocktype)
					setmodel(cubeselector, "models/editor/cubeselector.mdl");
				setorigin(cubeselector, org);
				cubeselector.scale = toolscale;
				cubeselector.drawmask = MASK_NORMAL;
				cubeselector.alpha = 0.4;
				cubeselector.blocktype = 0;
			}
			else
			if(type > numblocktypes-numobjectblocktypes)
			{
				if(cubeselector.blocktype != type)
					SetModelForCubicObject(cubeselector, type, FALSE);
				setorigin(cubeselector, org);
				cubeselector.scale = 1;
				cubeselector.drawmask = MASK_NORMAL;
				cubeselector.alpha = 0.4;
				cubeselector.blocktype = type;
				drawingnonsolid = TRUE;
			}			
			else
			{
				for(facegroup = cubeselector.list_facegroupchain; facegroup; facegroup = nexte)
				{
					nexte = facegroup.facegroupchain;
					RemoveFaceGroup(cubeselector, facegroup);
				}

				cubeselector.drawmask = FALSE;
				cubeselector.blocktype = type;	// cubeselector acts as the typegroup entity
				cubeselector.alpha = 1;
				BuildFacesForShape(cubeselector, toolshape, toolrotation, 0, org, 1);	// could call this less somehow
			}
			
			float buffersize = clustersize*chunksize*cubicradius;
			
			if(drawingnonsolid)
				cubeselector.colormod = '0 0 0';
			else
			if(toolonedge)
				cubeselector.colormod = '1 0 0';
			else
				cubeselector.colormod = '0.3 1 0.3';
		}
		else
			cubeselector.drawmask = FALSE;
	}
	
	if(tool)
	if(cubeselector.blocktype)
	if(!cubeselector.drawmask)
	for(facegroup = cubeselector.list_facegroupchain; facegroup; facegroup = facegroup.facegroupchain)
		DrawFaceGroup(facegroup, cubeselector.origin);	
}

void InitializeCubicInterface()
{
	cubeselector = spawn();
	setmodel(cubeselector, "models/editor/cubeselector.mdl");
	cubeselector.lightcolor = '1 1 1';
	cubeselector.renderflags = RF_ADDITIVE;
}