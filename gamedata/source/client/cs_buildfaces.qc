int ConvertRotation(int rotation, int xzoffset, int yawoffset)
{
	rotation += xzoffset*4;
	int xzrotation = floor(rotation/4)*4;
	int yaw = rotation-xzrotation;
	
	yaw+=yawoffset;
	if(yaw > 3)
		yaw -= 4;
	
	rotation = xzrotation+yaw;
	return rotation;
}

void BuildFacesForShape(entity typegroup, int blockshape, int blockrotation, int cullbits, vector cubicposition, int numchunkcubics, float facescale)
{
	switch(blockshape)
	{
		case BLOCKSHAPE_CUBE:														BuildFaces_Cube(typegroup, cullbits, cubicposition, numchunkcubics, facescale);						break;
		
		case BLOCKSHAPE_RAMP:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Ramp(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);			else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Ramp_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Ramp_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Ramp_CW(typegroup, ConvertRotation(blockrotation, -2, -1), cullbits, cubicposition, numchunkcubics, facescale);	break;
							//		if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Ramp_UD(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics);	break;
									
		case BLOCKSHAPE_WEDGETIP:	if(blockrotation <= BLOCKROTATION_S)			BuildFaces_WedgeTip(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale); 		else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_WedgeTip_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);	else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_WedgeTip_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);	else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_WedgeTip_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);	else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_WedgeTip_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);	else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_WedgeTip_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);	break;
									
		case BLOCKSHAPE_WEDGE:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Wedge(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale); 		else	
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Wedge_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale); 		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Wedge_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale); 		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Wedge_CCW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Wedge_FW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_BW_S)			BuildFaces_Wedge_BW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		break;

		case BLOCKSHAPE_SLAB:		if(blockrotation <= BLOCKROTATION_S)			BuildFaces_Slab(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);			else
									if(blockrotation <= BLOCKROTATION_CW_S)			BuildFaces_Slab_CW(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_UD_S)			BuildFaces_Slab_UD(typegroup, blockrotation, cullbits, cubicposition, numchunkcubics, facescale);		else
									if(blockrotation <= BLOCKROTATION_CCW_S)		BuildFaces_Slab_CW(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics, facescale);	break;
							//		if(blockrotation <= BLOCKROTATION_FW_S)			BuildFaces_Slab_UD(typegroup, ConvertRotation(blockrotation, -2, 2), cullbits, cubicposition, numchunkcubics, facescale);	break;	
	}
}

void QueueFaceBuildChain_Remove(entity e)
{
	if(buildchunkfaces_chunk == e)
	{
		buildchunkfaces_builtcount = 0;
		buildchunkfaces_cubiccount = 0;
		buildchunkfaces_chunk = __NULL__;
	}
	
	QueueFaceBuildChain_Remove_(e);
}

void BuildChunkFaces(entity chunk, int distant)
{
	entity typegroup = __NULL__;
	int blockshape = 0, blockrotation = 0, cullbits = 0, cubiccount = 0, numchunkcubics = 0, builtcount = 0, type = 0;
	vector cubicposition = '0 0 0';

	numchunkcubics = chunk.numvisiblecubics;
	
	if(distant)
	{
		cubiccount = buildchunkfaces_cubiccount;
		builtcount = buildchunkfaces_builtcount;
	}
	else
	{
		cubiccount = 0;
		builtcount = 0;
	}
	
	for(; builtcount < numchunkcubics && !(distant && numcubicsbuiltforframe >= autocvar_cq_maxcubicsperbuild); cubiccount++)
	{
		if(cubiccount >= pow(chunksize, 3))
		{
			dprint("Warning: Lost chunk data over the network.\n");
			localcmd(strcat("cmd cq_resendchunk ", itos(GetChunkOriginRef(chunk.origin, __FUNC__)), "\n"));
			break;
		}
		
		type = chunk.cubic_blocktype[cubiccount];

		if(type == __NULL__)
			continue;
		
		typegroup = GetTypeGroup(chunk, type);
		
		if(typegroup)
		{
			blockshape = chunk.cubic_blockshape[cubiccount];
			blockrotation = chunk.cubic_blockrotation[cubiccount];
			cullbits = chunk.cubic_cullbits[cubiccount];
			cubicposition = chunk.origin + GetCubicOffset(cubiccount);
			BuildFacesForShape(typegroup, blockshape, blockrotation, cullbits, cubicposition, numchunkcubics, 1);
			numcubicsbuiltforframe++;
		}
		
		builtcount++;
	}
	
	if(distant)
	{
		if(numcubicsbuiltforframe >= autocvar_cq_maxcubicsperbuild) // save place for next frame
		{
			numcubicsbuiltforframe = -1;
			
			if(builtcount < numchunkcubics)	// don't set these if the chunk finished right at the max per build
			{
				buildchunkfaces_chunk = chunk;
				buildchunkfaces_builtcount = builtcount;
				buildchunkfaces_cubiccount = cubiccount;
				return;
			}
		}
		
		buildchunkfaces_builtcount = 0;
		buildchunkfaces_cubiccount = 0;
		buildchunkfaces_chunk = __NULL__;
		QueueFaceBuildChain_Remove(chunk);
	}
	else
		QueueNearFaceBuildChain_Remove(chunk);
	
	TriggerStaticLightReset(chunk.origin);
	
	if(chunk.resetlights)
	{
		ResetStaticLights(TRUE);	// cubics were added or removed so chunk faces need to be relit
		chunk.resetlights = FALSE;
	}

	
}

float	buildfacetime;
void BuildQueuedFaces()
{
	entity e = __NULL__, nexte = __NULL__;
	int numbuilds = 0;
	
	if(time < buildfacetime)
		return;

	buildfacetime = time+frametime*autocvar_cq_framesperfacebuild;	

	for(e = list_queuefacebuildchain; e && numbuilds < autocvar_cq_maxfacegroupsperbuild && numcubicsbuiltforframe != -1; e = nexte)
	{
		nexte = e.queuefacebuildchain;

	/*	if(e.lastupdatetime)
		if(time-e.lastupdatetime > 10)
		{
			e.lastupdatetime = 0;
			localcmd(strcat("cmd cq_resendchunk ", itos(GetChunkOriginRef(e.origin, __FUNC__)), "\n"));
			print("a chunk took too long to render\n");
			continue;
		}*/
		
		if(e.findnetworkbloatent)
			continue;
		
		numbuilds++;		
		BuildChunkFaces(e, TRUE);
	}
	
	numcubicsbuiltforframe = 0;
}

void BuildNearQueuedFaces()
{
	entity e = __NULL__, nexte = __NULL__;

	for(e = list_queuenearfacebuildchain; e; e = nexte)
	{
		nexte = e.queuenearfacebuildchain;
		
		if(e.findnetworkbloatent)
			continue;
		
		BuildChunkFaces(e, FALSE);
	}
}

void QueueChunkFaceBuild(entity chunk, float sendflags)
{
	vector ofs = chunk.origin - GetNearChunkOrg(view_org);
	float dist = ofs*ofs;
	float proximitydist = chunksize*cubicradius*2*autocvar_cq_bgload_dist;
	proximitydist = proximitydist*proximitydist;
	
	if(dist <= proximitydist)
	{
		QueueNearFaceBuildChain_Add(chunk);
		
		if(!(sendflags & SFL_ISNEW))
			if(sendflags & SFL_BUILD)
				chunk.resetlights = TRUE; // i guess we don't care about far lights? we'll see
		
		return;
	}

	QueueFaceBuildChain_Add(chunk);
	
	entity e = __NULL__, lastchain = __NULL__, oldlist = __NULL__;
	for(e = list_queuefacebuildchain; e; e = e.queuefacebuildchain)
	{
		if(!e.queuefacebuildchain)
			lastchain = e;
	}
	
	if(lastchain != list_queuefacebuildchain)
	{
		oldlist = list_queuefacebuildchain;
		list_queuefacebuildchain = list_queuefacebuildchain.queuefacebuildchain;
		list_queuefacebuildchain.queuefacebuildchain_prev = __NULL__;
		lastchain.queuefacebuildchain = oldlist;
		oldlist.queuefacebuildchain_prev = lastchain;
		oldlist.queuefacebuildchain = __NULL__;
	}
}

vector	oldplayerchunkpos;
void UpdateFaceQueuesForPlayerPosition()
{
	vector ofs = '0 0 0';
	float dist = 0;
	entity e = __NULL__, nexte = __NULL__, typegroup = __NULL__;
//	entity firstmovedchunk = __NULL__;
	
	vector currentplayerchunkpos = GetNearChunkOrg(view_org);
	if(currentplayerchunkpos == oldplayerchunkpos)
		return;
	
	float proximitydist = chunksize*cubicradius*2*autocvar_cq_bgload_dist;
	proximitydist = proximitydist*proximitydist;	
	
	for(e = list_queuefacebuildchain; e; e = nexte)
	{
		nexte = e.queuefacebuildchain;

		ofs = e.origin - currentplayerchunkpos;
		dist = ofs*ofs;
		
		if(dist <= proximitydist)	// this moves facegroups from the slow bg queue to the fast local queue if the player gets closer to them
		{
		//	if(!firstmovedchunk)
		//		firstmovedchunk = e;
	
			if(e == buildchunkfaces_chunk)
			for(typegroup = e.list_typegroupchain; typegroup; typegroup = typegroup.typegroupchain)
				while(typegroup.list_facegroupchain)
					RemoveFaceGroup(typegroup, typegroup.list_facegroupchain);
		
			QueueFaceBuildChain_Remove(e);
			QueueNearFaceBuildChain_Add(e);
		}
	}
	
/*	if(firstmovedchunk)
		e = firstmovedchunk;
	else
		e = list_queuenearfacebuildchain;
	
	for(; e; e = nexte)
	{
		nexte = e.queuenearfacebuildchain;
		
		ofs = e.origin - currentplayerchunkpos;
		dist = ofs*ofs;		
		
		if(dist > proximitydist)
		{
			QueueNearFaceBuildChain_Remove(e);
			QueueFaceBuildChain_Add(e);			
		}
	}*/
	
	oldplayerchunkpos = currentplayerchunkpos;
}