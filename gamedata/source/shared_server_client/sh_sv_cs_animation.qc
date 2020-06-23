#ifdef SSQC
.float frame2;	// already defined in csqc
#endif

.float	anim_frameduration;
.float	lastframe;
.float	beginframe;
.float	finalframe;
.float	restartanim;
.float	loopframes;
.float	lerpframes;
.float	animlooped;
.float	frameendtime;
.float	frameoffset;
float	lerpdur = 0.1;

void AnimateModel(entity e)
{	
	if(!e.anim_frameduration)
		return;

	if(time >= e.frameendtime)	
	{
		e.frame = e.frame2;
		#ifdef CSQC
		if(e.frameendtime)
			e.frame1time = e.frameendtime;
		else
			e.frame1time = time;
		e.frame2time = e.frame1time+e.frameoffset*e.anim_frameduration;
		#endif
		
	//	if(e.frameendtime)
	//		e.frameendtime += e.anim_frameduration;
	//	else
			e.frameendtime = time+e.anim_frameduration;	
		
		if(e.frame2 < e.beginframe || e.frame2 > e.finalframe || e.restartanim)
			e.frame2 = e.beginframe;
		else
		if(e.loopframes && e.frame2 == e.finalframe)
		{
				e.frame2 = e.beginframe;
				e.animlooped = TRUE;
		}
		else			
			e.frame2 = min(e.finalframe, e.frame2+1);
			
		e.restartanim = FALSE;
	}

	#ifdef CSQC
	if(e.lerpframes)
		e.lerpfrac = (time-e.frame1time)/e.anim_frameduration;
	#endif
}

void SetAnimation(entity e, float startframe, float endframe, float framedur, float looping, float lerping, int randomstartframe)
{
	if(!e.restartanim)
	if(startframe == e.beginframe)
	if(endframe == e.finalframe)
	if(looping == e.loopframes)
		return;
	
	if(!randomstartframe)
		e.restartanim = TRUE;
	e.beginframe = startframe;
	e.finalframe = endframe;
	e.loopframes = looping;
	#ifdef CSQC
	e.lerpframes = lerping;
	#endif
	
	e.animlooped = FALSE;
	if(framedur)
		e.anim_frameduration = framedur;
	else
		e.anim_frameduration = lerpdur;
	
	if(randomstartframe)
		e.frameoffset = min(floor(random(e.finalframe-e.beginframe+1)), e.finalframe-e.beginframe);
}