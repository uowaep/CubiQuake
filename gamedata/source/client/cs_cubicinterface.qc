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
		
		if(tool >= TOOL_EDITOR_REMOVE && tool <= TOOL_EDITOR_PASTE)
		{
			int getinside = FALSE;
			if(tool == TOOL_EDITOR_REMOVE || tool == TOOL_EDITOR_COPY)
				getinside = TRUE;
			
			makevectors(view_ang);
			cubicpos = TraceCubic(view_org, view_org + v_forward*cubicradius*2*20, getinside);

			switch(toolsize)
			{
				case TOOLSIZE_EDITOR_CUBIC:		org = GetNearestCubicOrigin(cubicpos, chunksize_iseven);	break;
				case TOOLSIZE_EDITOR_CHUNK:		org = GetNearChunkOrg(cubicpos);							break;
				case TOOLSIZE_EDITOR_CLUSTER:	org = GetNearClusterOrg(cubicpos);							break;
			}
			
			clusterpos = GetClusterOffset(playerclusterid);
			toolonedge = ToolIsOnEdge(clusterpos, org);
			
			if(getinside || toolscale > 1)
			{
				setorigin(cubeselector, org);
				cubeselector.scale = toolscale;
				cubeselector.drawmask = MASK_NORMAL;
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
				BuildFacesForShape(cubeselector, toolshape, toolrotation, 0, org, 1);
			}
			
			float buffersize = clustersize*chunksize*cubicradius;
			
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
		DrawFaceGroup(facegroup);	
}

void InitializeCubicInterface()
{
	cubeselector = spawn();
	setmodel(cubeselector, "models/editor/cubeselector.mdl");
	cubeselector.alpha = 0.4;
	cubeselector.renderflags = RF_ADDITIVE;
}