void SharedPrecaches()
{
//	precache_model("null");
	#ifdef CSQC
	precache_model("models/objects/torch.mdl");
	#endif

	precache_model("models/player/player.mdl");
	precache_model("models/player/h_player.mdl");
	precache_model("models/editor/cubeselector.mdl");
	
	#ifdef SSQC
	precache_model("models/collision/cube.bsp");
	precache_model("models/collision/ramp.bsp");
	precache_model("models/collision/ramp_cw.bsp");
	precache_model("models/collision/ramp_ud.bsp");
	precache_model("models/collision/wedge.bsp");
	precache_model("models/collision/wedge_cw.bsp");
	precache_model("models/collision/wedge_ud.bsp");
	precache_model("models/collision/wedge_ccw.bsp");
	precache_model("models/collision/wedge_fw.bsp");
	precache_model("models/collision/wedge_bw.bsp");
	precache_model("models/collision/wedgetip.bsp");
	precache_model("models/collision/wedgetip_cw.bsp");
	precache_model("models/collision/wedgetip_ud.bsp");
	precache_model("models/collision/wedgetip_ccw.bsp");
	precache_model("models/collision/wedgetip_fw.bsp");
	precache_model("models/collision/wedgetip_bw.bsp");
	precache_model("models/collision/slab.bsp");
	precache_model("models/collision/slab_cw.bsp");
	precache_model("models/collision/slab_ud.bsp");	
	#endif
}