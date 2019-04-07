entity	cubeselector;
float	updatehudtooltime;

void UpdateCubicInterface()
{
	if(time < updatehudtooltime)
		return;
	
	updatehudtooltime = time+0.06;		// TraceCubic kills fps, no need to update every single frame
	
	int tool = getstati(STAT_TOOL);
	int toolsize = getstati(STAT_TOOLSIZE);
	int playerclusterid = getstati(STAT_PLAYERCLUSTERID);
	float toolscale = GetToolScale(toolsize);
	int toolonedge;
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
		
		setorigin(cubeselector, org);
		cubeselector.scale = toolscale;
		cubeselector.drawmask = MASK_NORMAL;
		
		float buffersize = clustersize*chunksize*cubicradius;
		
		if(toolonedge)
			cubeselector.colormod = '1 0 0';
		else
			cubeselector.colormod = '0.3 1 0.3';
	}
	else
		cubeselector.drawmask = FALSE;
}

void InitializeCubicInterface()
{
	cubeselector = spawn();
	setmodel(cubeselector, "models/editor/cubeselector.mdl");
	cubeselector.alpha = 0.4;
	cubeselector.renderflags = RF_ADDITIVE;
}