void SharedPrecaches()
{
//	precache_model("null");
	#ifdef CSQC
	precache_model("models/editor/cubeselector.mdl");
	#endif
	
	precache_model("models/player/player.mdl");
//	precache_model("models/player/h_player.mdl");

	#ifdef SSQC
	precache_model("models/collision/ramp.bsp");
	precache_model("models/collision/wedge.bsp");
	precache_model("models/collision/wedgetip.bsp");
	precache_model("models/collision/wedge.bsp");
	#endif
}