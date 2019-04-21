void SharedPrecaches()
{
//	precache_model("null");
	precache_model("models/editor/cubeselector.mdl");
	precache_model("models/player/player.mdl");
//	precache_model("models/player/h_player.mdl");

	#ifdef SSQC
	precache_model("models/collision/ramp.bsp");
	#endif
}