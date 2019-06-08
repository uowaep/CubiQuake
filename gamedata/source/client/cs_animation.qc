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

void AnimateModel(entity e)	// this is all hacked in, needs to be done properly.
{	
	if(time >= e.frameendtime)	
	{
		e.frame1time = time+e.frameoffset*e.anim_frameduration;	// FIXME this is a hack
		e.frameendtime = time+e.anim_frameduration;

		if(e.frame < e.beginframe || e.frame > e.finalframe || e.restartanim)
			e.frame = e.beginframe;
		else
		if(e.loopframes && e.frame == e.finalframe)
		{
				e.frame = e.beginframe;
				e.animlooped = TRUE;
		}
		else			
			e.frame = min(e.finalframe, e.frame+1);
			
		e.restartanim = FALSE;
	}

	if(e.lerpframes)	// This is probably all wrong. Not sure how to lerp properly in FTE yet.
		e.frame1time = (time+e.frameoffset*e.anim_frameduration)*(0.1/e.anim_frameduration);
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
	e.lerpframes = lerping;
	e.animlooped = FALSE;
	if(framedur)
		e.anim_frameduration = framedur;
	else
		e.anim_frameduration = lerpdur;
	
	if(randomstartframe)
		e.frameoffset = min(floor(random(e.finalframe-e.beginframe+1)), e.finalframe-e.beginframe);
}