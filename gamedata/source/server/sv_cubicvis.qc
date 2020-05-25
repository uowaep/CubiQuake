void SetNumVisibleCubics(entity chunk, int val)
{
	int count = 0;
	int numbloatents = ceil((float)val/maxcubicupdates)-1;
	
//	chunk.updateref++;
	
	if(!chunk.networkbloat_allocated)
	{
		chunk.networkbloat = memalloc(sizeof(entity)*maxbloatents);
		chunk.networkbloat_allocated = TRUE;
	}
	
	for(count = 0; count < maxbloatents; count++)
	{
		if(chunk.networkbloat[count] == __NULL__)
			break;
		
		Remove(chunk.networkbloat[count]);
		chunk.networkbloat[count] = __NULL__;
	}
	
	chunk.numvisiblecubics = val;
	
	if(val > maxcubicupdates)
	{
		for(count = 0; count < numbloatents; count++)
		{
			if(!chunk.networkbloat[count])
			{
				chunk.networkbloat[count] = spawn();
				chunk.networkbloat[count].parentchunk = chunk;
				chunk.networkbloat[count].flags = FL_FINDABLE_NONSOLID;
				chunk.networkbloat[count].enttype = ENT_CHUNKBLOAT;
				chunk.networkbloat[count].bloatlevel = count+1;
				setorigin(chunk.networkbloat[count], chunk.origin);
				chunk.networkbloat[count].updateref = chunk.updateref;
				chunk.networkbloat[count].SendEntity = SendChunkBloat;
			//	chunk.networkbloat[count].SendFlags = chunk.networkbloat[count].SendFlags | SFL_ISNEW | SFL_BUILD;
			}
		}
	}
}

void SetCubicVisibility(entity chunk, int memslot)
{
	// .cubic_cullbits on modified blocks should be set to the old cullbits and new partial cullbits before calling this or UpdateChunkAreaVisibility functions. example below:
	// chunk.cubic_cullbits[i] = (chunk.cubic_cullbits[i] & CULLBITS_ALL) + GetPartialSideCullBitsForShape(type, shape, rotation);
	
	if(chunk.cubic_blocktype[memslot] == 0)
		return;	
	
	int cullbits = 0, nearcullbits = 0, partialside = 0;
	vector nearcubicorg = '0 0 0', cubicchunkorg = '0 0 0', ofs = '0 0 0';
	entity originalchunk = chunk;
	int	originalcullbits = originalchunk.cubic_cullbits[memslot];

	vector cubicorg = chunk.origin + GetCubicOffset(memslot);	
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	partialside = CULLBITS_PARTIAL_D;	break;
			case 1:	ofs = VECOFS_W;	partialside = CULLBITS_PARTIAL_E;	break;
			case 2:	ofs = VECOFS_S;	partialside = CULLBITS_PARTIAL_N;	break;
			case 3:	ofs = VECOFS_E;	partialside = CULLBITS_PARTIAL_W;	break;
			case 4:	ofs = VECOFS_N;	partialside = CULLBITS_PARTIAL_S;	break;
			case 5:	ofs = VECOFS_D;	partialside = CULLBITS_PARTIAL_U;	break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		cubicchunkorg = GetNearChunkOrg(nearcubicorg);
		chunk = GetChunkForLocation(__NULL__, cubicchunkorg);
		
		
		if(!chunk)	// this needs to be split up or not?
			cullbits = cullbits | bitshift(1, sidecount);
		else
		if(GetCubicStatus(chunk, nearcubicorg, TRUE) != -1)
		{
			nearcullbits = chunk.cubic_cullbits[GetCubicRef(nearcubicorg-chunk.origin, __FUNC__)];			
			if(!(nearcullbits & partialside))
				cullbits = cullbits | bitshift(1, sidecount);
		}
	}

	if((cullbits & CULLBITS_ALL) == CULLBITS_ALL)
	if((originalcullbits & CULLBITS_ALL) != CULLBITS_ALL)		
		SetNumVisibleCubics(originalchunk, originalchunk.numvisiblecubics-1);
	
	if((cullbits & CULLBITS_ALL) != CULLBITS_ALL)
	if((originalcullbits & CULLBITS_ALL) == CULLBITS_ALL)
		SetNumVisibleCubics(originalchunk, originalchunk.numvisiblecubics+1);

	originalchunk.cubic_cullbits[memslot] = cullbits + (originalcullbits & CULLBITS_PARTIAL_ALL);
}

void UpdateChunkAreaVisibility(entity chunk, vector cubicorg, int markmodified)
{
	vector ofs = '0 0 0', nearcubicorg = '0 0 0', cubicchunkorg = '0 0 0';
	
	int cubicid = GetCubicRef(cubicorg-chunk.origin, __FUNC__);
	SetCubicVisibility(chunk, cubicid);
	if(markmodified)
		SetChunkAsModified(chunk);
	
	entity originalchunk = chunk;
	
	for(int sidecount = 0; sidecount < 6; sidecount++)
	{
		switch(sidecount)
		{
			case 0:	ofs = VECOFS_U;	break;
			case 1:	ofs = VECOFS_W;	break;
			case 2:	ofs = VECOFS_S;	break;
			case 3:	ofs = VECOFS_E;	break;
			case 4:	ofs = VECOFS_N;	break;
			case 5:	ofs = VECOFS_D;	break;
		}
		
		nearcubicorg = cubicorg + ofs*cubicradius*2;
		cubicchunkorg = GetNearChunkOrg(nearcubicorg);
		chunk = GetChunkForLocation(chunk, cubicchunkorg);
		
		if(!chunk)
			continue;
		
		cubicid = GetCubicRef(nearcubicorg - chunk.origin, __FUNC__);
		SetCubicVisibility(chunk, cubicid);
		if(chunk != originalchunk)
			SetChunkAsModified(chunk);
	}
}

void UpdateChunkAreaVisibility_OuterEdge(entity chunk)
{
	vector pos = '0 0 0', cubicpos = '0 0 0';
		
	for(pos_x = 0; pos_x < chunksize; pos_x++)
		for(pos_y = 0; pos_y < chunksize; pos_y++)
			for(pos_z = 0; pos_z < chunksize; pos_z++)
			{
				if(pos_x > 0 && pos_x < chunksize-1)
				if(pos_y > 0 && pos_y < chunksize-1)
				if(pos_z > 0 && pos_z < chunksize-1)
					continue;	
					
				cubicpos = pos - ('1 1 1'*((chunksize - !chunksize_iseven)*0.5 - 0.5*chunksize_iseven));
				cubicpos = cubicpos*cubicradius*2;
				cubicpos += chunk.origin;
				
				UpdateChunkAreaVisibility(chunk, cubicpos, FALSE);
			}	
}

vector GetCubicOffsetFromGrid(vector pos)
{
	vector cubicpos = pos - ('1 1 1'*((chunksize - !chunksize_iseven)*0.5 - 0.5*chunksize_iseven));
	cubicpos = cubicpos*cubicradius*2;
	return cubicpos;
}

vector GetChunkOffsetFromGrid(vector pos)
{
	vector org = pos - 0.5*'1 1 1'*(clustersize-1);
	org *= chunksize*cubicradius*2;
	return org;
}

void UpdateClusterAreaVisibility_OuterEdge(entity cluster)
{
	vector pos = '0 0 0', cpos = '0 0 0', checked = '0 0 0', chunkorg = '0 0 0';
	entity chunk = __NULL__;
	
	for(pos_x = 0; pos_x < clustersize; pos_x++)
		for(pos_y = 0; pos_y < clustersize; pos_y++)
			for(pos_z = 0; pos_z < clustersize; pos_z++)
			{
				chunkorg = GetChunkOffsetFromGrid(pos)+cluster.origin;	
				chunk = GetChunkForLocation(__NULL__, chunkorg);	
				
				if(!chunk)
					continue;
						
				checked = '0 0 0';
				
				if(pos_x == 0)
				{
					cpos_x = 0;
					checked_x = 1;
					
					for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
				}
				else
				if(pos_x == clustersize-1)
				{
					cpos_x = chunksize-1;
					checked_x = chunksize;
					
					for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
				}
				
				if(pos_y == 0)
				{
					cpos_y = 0;
					checked_y = 1;
					
					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
					}
				}				
				else
				if(pos_y == clustersize-1)
				{
					cpos_y = chunksize-1;
					checked_y = chunksize;
					
					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_z = 0; cpos_z < chunksize; cpos_z++)
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
					}
				}				

				if(pos_z == 0)
				{
					cpos_z = 0;

					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						{
							if(cpos_y == checked_y-1)
								continue;
							
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
						}
					}
				}				
				else
				if(pos_z == clustersize-1)
				{
					cpos_z = chunksize-1;

					for(cpos_x = 0; cpos_x < chunksize; cpos_x++)
					{
						if(cpos_x == checked_x-1)
							continue;
						
						for(cpos_y = 0; cpos_y < chunksize; cpos_y++)
						{
							if(cpos_y == checked_y-1)
								continue;
							
							UpdateChunkAreaVisibility(chunk, GetCubicOffsetFromGrid(cpos)+chunkorg, FALSE);
						}
					}
				}
				
				SetChunkAsModified(chunk);
			}	
}