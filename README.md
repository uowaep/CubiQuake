![alt text](https://raw.githubusercontent.com/uowaep/CubiQuake/master/cubiquake.png "CubiQuake")

Cubic Game Framework for the FTEQW Engine __(Requires [FTEQW](http://fte.triptohell.info/downloads) 64bit strongly recommended.)__

CubiQuake is a Quake modification. It can be played as is in creative mode to build worlds, but it is also a framework for Quake mod developers. It is designed for building cubic worlds, which popular culture commonly misreferences as voxels, hence the name. Cubiquake uses trisoup_simple to draw most surfaces, and dynamically spawns collision surfaces and calculates lighting as the player moves through the world. Multiple rotatable shapes are supported: cube, ramp, wedge. Each cubic/shape can use any texture or instead use models for more decorative applications such as the example torches. Ambient, static, and dynamic light all work. You do not need to be a modder to use CubiQuake as is. Just follow the installation and playing/generation instructions.

Use the F1-F4 Keys in-game for help!

### Recent Changes

Complete reinstall recommended. A health stat has been added to cubics, and breaks existing worlds. Old prefabs still work. They can be backed up and salvaged before wiping everything!

r158
+ set sky to use r_fastsky 1 by default and replaced placeholder sky with blank images
+ changed default cq_chunksperpassage from 7 to 5
+ chunks now save at 30 second increments by default (instead of the moment they are modified), and are saved on unload, mapchange, or quit
+ facegroup allocations are no longer freed, but instead kept around to be used by newly built chunks in csqc. this improved performance of chunk loading and updating by a large margin, and cubic building speed via cq_maxcubicsperbuild and cq_maxdamagecubicsperbuild (new) have been increased/set to 64 (normally 16)
+ cq_maxfacegroupsperbuild set to 64 for good measure
+ added cq_lights_models. 0 by default. set to 1 to enable engine lights for models
+ added radiant lighting. use cq_ambientlight_radiance and cq_lights_radiance to modify
+ changed default ambient light (while making skies in PDoD)
+ set r_shadow_realtime_dlight 1, r_shadow_realtime_dlight_shadows 0, and r_shadow_realtime_world_shadows 0
+ some fog settings, ignore these
+ pr_gc_threaded 1 just because
+ several minor tweaks to reduce hiccups
+ added cubic health and support and textures for 9 levels of damage for cubics 10% to 90% health (can do damage in PDoD, but added support to core)
+ added support for chunk textures to be modified dynamically without resending the entire chunk to the clients (dmg textures for example)
+ fixed bug with ambient light
+ facegroups no longer group different facing sides together
+ hardware mouse support via mousepos variable
+ fixed trace point for player client vs server
+ cubic objects can now be rotated
+ editor cubic object alpha set to 1 for visibility
+ added support for modifying ambient light and ambient light position dynamically (just don't do it every frame) variables: ambientlight_modified and ambientlight_position.
+ added mod support for csqc input SetInputID_Wrap_Prior()
+ added mod support for skies/environments/whatever DrawSky_Wrap()
+ changed cq_gen_type 1 (wasteland) to only use 3 blocktypes
+ made wasteland floor more flat to represent old streets/floors (the old generator was just an experiment, but looks kinda like an old city to me now)
+ rotation is no longer sent to the client for cube shapes
+ players no longert get their origin set at the floor at map start if they are in noclip mode
+ improved/utilized linked list append support (mainly for build queues)
+ increased available input keys for mods to 50 (numinputkeys variable)

### Installation
- Download CubiQuake https://github.com/uowaep/CubiQuake/archive/master.zip and extract the entire contents of the zip file into any directory. The directory you choose will be your main CubiQuake directory.
- Download the appropriate client from FTEQW http://fte.triptohell.info/downloads and place it in your main CubiQuake directory. (64bit strongly recommended.)

Note: If sharing the same FTE install with other mods, the default.fmf file should not be installed.

### Updating
Extract the new files into your install directory. It's always good idea to start from scratch when updating, but you shouldn't need to. If anything is broken try clearing the data dir first. If that doesn't help, start from a clean install. If that doesn't help run debug mode in FTEQCC and get some screenshots.

### Starting CubiQuake
- Start FTEQW.
- Click on "Start World"

### Multiplayer
Multiplayer is working. Get the server from http://fte.triptohell.info/downloads. Use the cubiquakeserver.bat file or check the command line inside to run a dedicated server.

WARNING: If a server restarts, players need to reconnect to get the world to network to them correctly. This is on the known issues list.

### Known Issues
- cubics/chunks/clusters can be placed on players
- players spawn inside of eachother on server restart and don't network chunks correctly (join an existing server!)
- players can get stuck in cubics if they move too fast for the loading speed (haven't seen this happen in a while)

### ToDo
- even more work on extended draw range performance
- copy/paste multiple cubics via custom selection tool
- make player light visible to other players
- don't let players place things on players

### ChangeLog

r158
+ set sky to use r_fastsky 1 by default and replaced placeholder sky with blank images
+ changed default cq_chunksperpassage from 7 to 5
+ chunks now save at 30 second increments by default (instead of the moment they are modified), and are saved on unload, mapchange, or quit
+ facegroup allocations are no longer freed, but instead kept around to be used by newly build chunks in csqc. this improved performance of chunk loading and updating by a large margin, and cubic building speed via cq_maxcubicsperbuild and cq_maxdamagecubicsperbuild (new) have been increased/set to 64 (normally 16)
+ cq_maxfacegroupsperbuild set to 64 for good measure
+ added cq_lights_models. 0 by default. set to 1 to enable engine lights for models
+ added radiant lighting. use cq_ambientlight_radiance and cq_lights_radiance to modify
+ changed default ambient light (while making skies in PDoD)
+ set r_shadow_realtime_dlight 1, r_shadow_realtime_dlight_shadows 0, and r_shadow_realtime_world_shadows 0
+ some fog settings, ignore these
+ pr_gc_threaded 1 just because
+ several minor tweaks to reduce hiccups
+ added cubic health and support and textures for 9 levels of damage for cubics 10% to 90% health (can do damage in PDoD, but added support to core)
+ added support for chunk textures to be modified dynamically without resending the entire chunk to the clients (dmg textures for example)
+ fixed bug with ambient light
+ facegroups no longer group different facing sides together
+ hardware mouse support via mousepos variable
+ fixed trace point for player client vs server
+ cubic objects can now be rotated
+ editor cubic object alpha set to 1 for visibility
+ added support for modifying ambient light and ambient light position dynamically (just don't do it every frame)
+ added mod support for csqc input SetInputID_Wrap_Prior()
+ added mod support for skies/environments/whatever DrawSky_Wrap()
+ changed cq_gen_type 1 (wasteland) to only use 3 blocktypes
+ made wasteland floor more flat to represent old streets/floors (the old generator was just an experiment, but looks kinda like an old city to me now)
+ rotation is no longer sent to the client for cube shapes
+ players no longert get their origin set at the floor at map start if they are in noclip mode
+ improved/utilized linked list append support (mainly for build queues)
+ increased available input keys for mods to 50 (numinputkeys variable)

r155
+ players now try to spawn in an open space along x0 y0 in the starting chunk near '0 0 0'

r153
+ moved core files to a .pk3 to make modding cleaner
+ added a flag for networking so distant chunks rebuild the same frame they update when damaged
+ actually allocate editor strings
+ removed projectile handlers to be updated to use more general object code
+ added a flag to remove certain objects that cross any world bounds (default would remove if the lower z boundary is crossed)
+ fixed a bug that was using setorigin on shared collision entities every frame on the server
+ fixed an issue with using ClearCubic() on cubics at the edge of the view range

r150
+ added a field in the default.cfg for the PDoD mod (
+ editor strings allocate to memory
+ fixed multiple major issues with chunks abusing memory allocations for networking purposes, and causing random crashes and issues when updating to csqc
+ included PDoD files in progs.src files (commented out, makes updating core easier.)
+ simplified projectile example slightly
+ added a world boundary for entities, including the player, unless in NOCLIP mode.
+ the ClearCubicArea() function used with the editor can now be used outside of the editor
+ removed some redundant code
+ modified some debug prints

r144
+ animation code is now shared between server and client
+ fixed a large amount of compiler warnings
+ set some developer into to use dprint
+ added some comments to try to help understand the code
+ fixed a wrong value during tracing in the prefab editor
+ removed some unused code
+ attempted to improve texture name lookup
+ fixed issue with player toggling lighting (player torch) before the world is loaded
+ added a function for modders to __wrap for access to cubiquake csqc lighting routines: void ApplyLighting_Wrap()
+ added a similar function for access to CSQC_Ent_Update, specifically to aceess the "int i = readbyte();" value: void Ent_Update_Wrap(float bIsNewEntity, int i)
+ added more similar functions to the server and client for entity removal cleanup, both with the same name: void CleanUp_Remove (entity e)
+ fixed a bug with removing lights from an empty chunk not relighting faces
+ consolidated collision bbox removal
+ fixed a bug with collision boxes completely removing and respawning every frame instead of leaving each bbox in the world until it isn't being used
+ expaded upon a specific dbug print related to referencing out of world bounds things
+ fixed a bug with narrow cubics not removing bboxes
+ added a function for modders to __wrap to effectively access StartFrame functionality before the RemoveUnusedCubicBBoxes() function is called: WorldLogic()
+ players and other physical entities now clear bbox usage on removal
+ actually fixed animation 

r137
+ added a start menu and help menus to the console (access with F1-F4)
+ the console opens by default on start to display the main help menu with shortcut links
+ included prefabs in the data/worldgen/ directory for building worlds with size 13 chunks
+ included a .pk3 with only shareware Quake textures, and removed the old textures
+ renamed all cvars and commands to use a cq_ prefix
+ added a world generation mode that just creates a flat world with the default block (cq_gen_type 0)
+ wasteland is specified with (cq_gen_type 1)
+ added a prefab world generation mode that uses saved chunks as prefabs (cq_gen_type 2)
+ added cq_dungeonsize cvar. it uses a vector rather than a single integer so you can specify a non-cube shaped bound area. This will cap at 2 less than worldsize to keep a layer of chunks between the generated world and the void.
+ fixed a major issue with chunk networking involving chunks displaying a large amount of cubics. this resulted in the ability to use much larger chunks. default chunk size is now 13, and default cluster size is now 1 to effectively remove them from use, while they can still be utilized for experimenting with smaller chunks.
+ added cq_chunksperpassage cvar for specifying the number of chunks between potential zone changes during prefab world generation
+ added cq_gen_step for debugging prefab world generation, and also shows a preview of the world (that doesn't remove until map restart)
+ added cq_gen_linear, an experimental cvar that specifies which end of the queue to add new chunks to during generation
+ changed view distances to reflect new chunk/cluster sizes and increased a bit since face building performance has increased
+ block, chunk, and cluster size can now be set via cvars: cq_blocksize, cq_chunksize, cq_clustersize
+ added cvar cq_maxchunksloadedperframe (default 24) to set maximum number of chunks to read from file per frame
+ added cvar cq_chunkremovaldelay (default 10) to speficy how many seconds to wait before removing an unused chunk to call less memory frees and re-load less if the chunk ends up being reloaded too quickly
+ added cvar cq_maxcubicupdates to experiment with the size of network data packs used in sending chunk info. Some complex chunks will require more than one shared entity to send the data.
+ addded an awesome cvar cq_bgload_dist (default 2.5 chunks) that sets the distance at which chunks can build faces in the background slowly. any faces less than that distance are built in a single frame to prevent the player from being too close to faces that are not built yet.
+ added another awesome cvar cq_maxcubicsperbuild that can specify a number of cubics to build faces for rather than a number of chunks. this reduces load-in stutter as the value is turned down. values around 16 or less seem to completely remove any stutter at all.
+ added cvar cq_maxfacegroupsperbuild. facegroups can be fairly large at times, so this acts as more of a backup when there are a lot of small groups being built. this cvar is likely completely unnecessary.
+ added cvar cq_framesperfacebuild (default 0) if cq_maxcubicsperbuild 1 isn't slow enough for you (also likely unnecessary)
+ added cq_lights_static_updateinterval and cq_lights_dynamic_updateinterval cvars to experiment with the lighting delays
+ added cvar cq_clientlightradius to set the radius of the player's dynamic light (T)
+ added cvar cq_showchunkoutline for help with chunk edges when editing
+ set pm_stepheight to 28 cuz parkour
+ console text size (con_textsize) is set to 4
+ vid_conautoscale is 2
+ crosshar is 16
+ crossharicolor is green
+ crosshair size is 6
+ pr_gc_threaded 1
+ cfg_save_aliases 0
+ cl_maxfps 250
+ shift is now bound to +speed
+ mouse2 is now an alternate tool function
+ alt toggles the tool selection size edit mode
+ now only impulse 11 will exit edit mode (X) rather than any non-CubiQuake-related impulses
+ remove mode is now edit mode (remove with alt tool, mouse2 in edit mode)
+ added a prefab edit mode (F, use chunk mode)
+ switched the cubic Y rotation keys
+ F5 is bound to a shortcut for starting the map
+ F6 is bound to noclip mode
+ fixed the collision for X/Z rotated cubics by adding .bsp collision boxes to match their rotation
+ actual texture names can now be specified inside the cubiquake.shader file rather than requiring a naming format ( so we can just use the default Quake textures without renaming any of them. )
afk
+ unhacked animation code
+ optimized cubic tracing code greatly (we now trace every frame when we need to)
+ different tools are represeted by color: edit: yellow, copy: green, paste: purple, prefab edit: blue, and add mode draws as the texture's base colors
+ the Edit and Add tools can now use custom selection sizes. toggle the selection size tool with the ALT key.
+ strings are now generated only when set or changed during hud drawing
+ torches outside of the chunk being edited in prefab edit mode are no longer drawn
+ you can paint values in edit mode by holding LMB and moving the mouse across multiple cubics. this also works with the selection box
+ textures no longer use strcat when looking up the name
improved handling of server to client chunk information to recognize when a pack of information is outdated
+ helped find a bug in FTE, and thus fixed a bad pointer issue in CubiQuake involving faces. Get the newest FTE :)
+ added a warning if somehow a facegroup gets too insanely large for the engine
+ increased default player torch light radius to 416 due to larger chunk sizes
+ fixed an issue related to lighting outside of world bounds
+ added editing cvars cq_zone cq_chance cq_fit
+ added debugging cvar cq_getchunkref
+ added some client key handling code for long keypresses
+ fixed a bug with freeing the same allocations more than once
+ fixed a bug with removing queued chunk network info
+ player now spawns at '0 0 0' (learn to swim)
+ player is set to noclip and isn't affected by gravity until the visible world has loaded from file
+i'm sure i'm missing a lot of stuff
+ prefabs with the filename "fill_#" will be used to fill spaces according to zone id # (need to add this note to the help screens)
+ fixed a bug involving partial sides, and faces not drawing when they should
+ separated sv_cubics.qc into several files in an attempt to organize things, while destroying any ability to recall what has changed in the last 6 or something months :P
+ fixed a bug in the AngleDifference() function that didn't account for angles greater than 360
+ worlds now save their clustersize and chunksize values, so modifying those cvars will not affect how a generated world loads
+ added a bunch of debugging messages
+ added tool information to the hud
+ fixed some bugs involving looking for chunks/clusters outside of the world bounds
+ edit tools are now drawn with trisoup_simple faces rather than using a the cubeselector.mdl model
+ massive stability fixes
+ performance improvement
+ probably other stuff...

r130
+ fixed issues with odd sized chunks, by fixing several related functions that were using bad syntax
+ increased chunk size from 6x6x6 to 7x7x7 (an odd value is good for designing prefabs with doorways centered.) This also effectively increases view range on default settings by about 7 cubics. Not a lot, but it's something.
+ increased max light radius because increasing chunk size allows lights to run at a larger radius without major performance issues

r126
+ fixed: noclip was preventing the world from loading

r123
+ lots of bug fixes mostly involving stability and multiplayer
+ increased default ambient lights a little from '0.2 0.2 0.6' to '0.4 0.4 0.8'
+ disabled cl_predict_players to stop other players from jittering around
+ disabled r_fog_cullentities (just to avoid any potential interference. can test this later.)
+ chunks no longer allocate more than once during an update (potential leak fixed)
+ resetlights was still registered as a command, now removed
+ added a ton of debugging code for finding bad entity references
+ chunks are now networked correctly to the appropriate clients
+ when players disconnect they update their chunks to know they can remove if no other players are viewing them
+ the world loading loop now handles all players rather than each player using their own loop
+ fixed a bad reference to previously removed cubic collision bbox ents
+ fixed a bug where cubic collision bbox ents were trying to spawn outside of the world if the player gets too close to the edge
+ no longer ghosting clusters as it tends to break networking
+ renamed some functions to make more sense (Remove* to Clear* etc)
+ intervals between unloads are now global rather than per player (prevents server choking)
+ when removing clusters, chunk removal is no longer staggered as this was creating more potential bad entity references. this could be fixed, but isn't really necessary. the code is left in, just not used.
+ changed all references to self outside of self's initial function call in sv_cubics.qc to player

r107
+ tested multiplayer. it works. (still needs to not send/draw out of range cubics loaded by other players)
+ added cubiquakeserver.bat to the main engine directory to run dedicated servers easily
+ added support for individual clients to save prefab files into their own directories on the server (be sure to set your "name" field)
+ use the "filename" cvar to set the desired prefab filename. it is set blank by default each game. use the cvar without any value to show the current filename
+ the "prefabname" cvar is no longer used
+ cvar "adminpass" added to prevent clients from calling commands such as resetview without permission
+ the map file is now a .map instead of a .hmp
+ added "start" command/alias to the console to avoid having to type out the map command
+ ambient light is now controlled on the server.
+ resetview now also resets ambient light levels (and draw ranges) across all clients
+ fixed a bug that was causing the server to try to initialize the client endlessly after using resetview
+ fixed some text prints to no longer broadcast to every player
+ removed resetlights command

r101
+ view distances can now be set in the console and modified during gameplay (they are server dependent though)
+ added console commands to modify view ranges: viewdist1, viewheight1, viewdist2, viewheight2, resetview
+ added some comments to default.cfg

r96
+ added ambient, static, and dynamic light
+ added a torch cubic object, using the torch model from Quake
+ T toggles a dynamic light around the client (impulse 150)
+ cvar ambientlight takes a vector ('0.2 0.2 0.6' in default.cfg)
+ [ and ] keys for cubic Y rotation are swapped in default.cfg
+ added console command "worlds" to list existing worlds
+ added console command "resetlights" for debugging (don't need it anymore, but don't need to remove it)
+ removed fog from the world.hmp map file
+ added a very basic shader to allow csqc to light/color polygons drawn with trisoup_simple
+ hacked in some animation code for the torch
+ added chunk entities that can use models/lights or any custom code
+ added cs_cubicobjects.qc for defining custom objects
+ removed some draw sorting code. wasn't helping as much as perceived ;)
+ added cluster matrix on client that is created as needed for chunks
+ moved most csqc defs to cs_cubicdefs.qc
+ moved most svqc defs to sv_cubicsdefs.qc
+ the cubic tool can now place custom entity type cubics along with normal trisoup_simple polygon cubics
+ added an arg to DrawFaceGroup() that is unnecessary. FIXME
+ worldsize is sent with the first set of chunk csqc/svqc entities before running InitGameVariables()
+ fixed a texture bug in wedge shape
+ now drawing engine crosshair
+ fixed a bug where chunks arriving out of order would arrive before worldsize is set on the client
+ added maxchunksloadedperframe and maxchunksghostedperframe to smooth out cluster/chunk load in/out
+ added maxlightradius setting. can be any value, but default is recommended for performance. (192 with default world settings)
+ added ambientlight setting using autocvar_ambientlight acting as the base light color
+ added lightupdatedelay_static settting. 0.5s default
+ added lightupdatedelay_dynamic setting. 0.02s default
+  iseven settings are now automatic
+ .lightradius .lightbrightness .lightcolor for lighting
+ fixed some bugs with placing chunks and clusters
+ added centerprint warning when trying to edit while chunks are loading

r83
+ added wedge and wedgetip shapes
+ added more angles of rotation to shapes (All angles are possible now with non-symmetrical shapes.)
+ chunks are now drawn from closest to furthest for 25% ish FPS increase
+ greatly improved chunk and cluster lookup speed by using entity references rather than findradius()
+ chunk and cluster entities are re-used where possible to reduce allocations and memfree usage
+ moved face rendering functions to their own file in csqc
+ moved shape functions to their own files in csqc
+ no longer using dpcompat_findradiusarealinks cvar
+ changed some instances of world to NULL
+ removed some unused variables

r78
+ added ramp shape (with collision)
+ added 2 axis block rotation (textures stay aligned to the world) (keys: [ ] -+)
+ added texture tools (keys: mwheel)
+ added shape tool (keys: <>)
+ added revision text in upper right of screen
+ updated surface culling to handle rotated shapes and partial cube sides (triangles)
