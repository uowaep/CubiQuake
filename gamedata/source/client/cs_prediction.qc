void UpdateEntityOrientation(entity e)
{
	vector correctionofs = '0 0 0', ang = '0 0 0';
	float lerptime = 1/60;

	// angles (sloppy)
	
	if(e.faceenemy & FACE_ORIENTYAW)
	if(e.faceenemy & FACE_LOCALPLAYER) // face local player
	{
		ang_y = vectoyaw(view_org - e.origin);
		e.angles_y = ang_y;
	}
	else
	if(!(e.faceenemy & FACE_NOUPDATE))	// not daed or otherwise
	if(e.velocity*e.velocity > 1*1)	// else if moving, face velocity direction // don't use velocity if value is small (probably doesn't match server exactly)
	{
		ang = vectoangles([e.velocity_x, e.velocity_y, 0]);
		e.angles_y = ang_y;
	}
	
	// otherwise just face the same direction
	
	// movement
	
	vector diff = e.sharedorigin - e.origin;	

//	if(e.origin != e.sharedorigin)

	if(e.movementcorrection != '0 0 0')
	if(diff*diff >= 1)	// not exactly where the object is supposed to be
	{		
		if(frametime <= 1/20)	// only try to interpolate and predict if fps is >= 20		
		{
			float maxcorrectionofs = 4; // more than this is likely overcompensation		
			
			correctionofs = e.movementcorrection * (1/lerptime)*frametime;

				// caught up, no need to keep adding prediction
				e.movementcorrection = '0 0 0';

			if(correctionofs*correctionofs > maxcorrectionofs*maxcorrectionofs)
				correctionofs = normalize(correctionofs)*maxcorrectionofs;

			// don't correct too far on a stop
			if(e.velocity == '0 0 0')		
			if(correctionofs*correctionofs >= diff*diff)
			{
				e.movementcorrection = '0 0 0';
				correctionofs = diff;	// move to the stopping point this frame
			}
		}
		else	// for people with slow machines
		{
			e.movementcorrection = '0 0 0';	// stopping now
			setorigin(e, e.sharedorigin); // just update to the last networked position network updates are bottlenecked by your framerate if it's this low
			return;
		}
	}
	else
		e.movementcorrection = '0 0 0';
	
	// set origin
	if(e.velocity != '0 0 0' || correctionofs != '0 0 0')
		setorigin(e, e.origin+(e.velocity*frametime)+correctionofs);	// this line uses prediction
//		setorigin(e, e.origin+correctionofs);							// this one just catches up	
}