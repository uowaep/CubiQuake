![alt text](https://raw.githubusercontent.com/uowaep/CubiQuake/master/cubiquake.png "CubiQuake")

Cubic Game Framework for the FTEQW Engine __(Requires [FTEQW](http://fte.triptohell.info/downloads) revision 5424 or higher. 64bit strongly recommended.)__

CubiQuake is a Quake modification. It can be played as is in creative mode to build worlds, but it is also a framework for Quake mod developers. It is designed for building cubic worlds, which popular culture commonly misreferences as voxels, hence the name. Cubiquake uses trisoup_simple to draw most surfaces, and dynamically spawns collision surfaces and calculates lighting as the player moves through the world. Multiple rotatable shapes are supported: cube, ramp, wedge. Each cubic/shape can use any texture or instead use models for more decorative applications such as the example torches. Ambient, static, and dynamic light all work. You do not need to be a modder to use CubiQuake as is. Just follow the installation and playing/generation instructions.

### Recent Changes
r130
- fixed issues with odd sized chunks, by fixing several related functions that were using bad syntax
- increased chunk size from 6x6x6 to 7x7x7 (an odd value is good for designing prefabs with doorways centered.) This also effectively increases view range on default settings by about 7 cubics. Not a lot, but it's something.
- increased max light radius because increasing chunk size allows lights to run at a larger radius without major performance issues

### Installation
- Download CubiQuake https://github.com/uowaep/CubiQuake/archive/master.zip and extract the entire contents of the zip file into any directory. The directory you choose will be your main CubiQuake directory.
- Download the appropriate client from FTEQW http://fte.triptohell.info/downloads and place it in your main CubiQuake directory. (64bit strongly recommended.)

Note: If sharing the same FTE install with other mods, the default.fmf file should not be installed.

### Updating
Extract the new files into your install directory. It's always good idea to start from scratch when updating, but you shouldn't need to. If anything is broken try clearing the data dir first. If that doesn't help, start from a clean install. If that doesn't help run debug mode in FTEQCC and get some screenshots.

### Playing/Generation
- Start FTEQW.
- Open the console. (SHIFT-ESC)
>
- Quick Start:
- - Type "start" and use current settings.
>
- Custom Start:
- - Set 'worldname name'. (default: world1)
- - Set 'worldsize size'. (default: 9 - There is no max, but beware of long generation times.)
- - Type "start" or "map world.map".

If the world files don't exist they will generate into /gamedata/data/worlds/worldname and the world will spawn after generation.

### Multiplayer
Multiplayer seems to be working. Other player's cubcs load in your view, but that was expected. Fixing that is on the ToDo. Get the server from http://fte.triptohell.info/downloads. Use the cubiquakeserver.bat file or check the command line inside to run a dedicated server.

### Controls
Bind | Description | Default Key | Notes
--- | --- | --- | ---
+attack | Use Tool |  mouse1 | 
impulse 100 | Tool Size: Cubic | 1 | 1x
impulse 101 | Tool Size: Chunk | 2 | 6x
impulse 102 | Tool Size: Cluster | 3 | 18x
impulse 110 | Tool Mode: Remove Cubic(s) | Q | 
impulse 111 | Tool Mode: Add Cubic(s) | E | 
impulse 112 | Tool Mode: Copy/Save Cubics(s) | C | 
impulse 113 | Tool Mode: Paste/Load Cubics(s) | V | 
impulse 120 | Tool: Cubic Type/Texture Next | mwheelup |
impulse 121 | Tool: Cubic Type/Texture Prev | mwheeldown |
impulse 122 | Tool: Cubic Shape Next | . |
impulse 123 | Tool: Cubic Shape Prev | , |
impulse 124 | Tool: Cubic Rotation Y+ | \[ |
impulse 125 | Tool: Cubic Rotation Y- | ] |
impulse 126 | Tool: Cubic Rotation X/Z+ | = |
impulse 127 | Tool: Cubic Rotation X/Z- | - |
impulse 11 | Exit Edit Mode | X | Any non-cubiquake impulse will work as well.
impulse 150 | Toggle Player Light| T |

### Console Commands
(Other than 'start', until menuqc is implemented these can only work during gameplay.)

Command | Description
--- | ---
filename | Sets/displays the filename to use in the current game instance for saving/loading prefabs.
resetview | Resets all player's rendering to use new values from server cvars: viewdist1, viewheight1, viewdist2, viewheight2, ambientlight.
start | Starts world.map, using the current worldname and worldsize settings.
worlds | Lists existing worlds.

### CVARs
CVAR | Description
--- | ---
adminpass | Password required to access certain commands on the server. (resetview)
ambientlight | Sets the base light color applied to textures with a red green blue vector. '0 0 0' is black, '1 1 1' is full color.  ('0.2 0.2 0.6' in default.cfg)
viewdist1 | Number of clusters out horizontally from the player to draw on first pass.
viewheight1 | Number of clusters out vertically to draw on first pass.
viewdist2 | Number of clusters out horizontally from the player to draw on second pass.
viewheight2 | Number of clusters out vertically to draw on second pass.
worldname | Sets the world name, which is also the directory where the files are stored within /gamedata/data/worlds/. (default: world1)
worldsize | Sets the world size in clusters. (default: 9 - There is no max, but beware of long generation times.)

### Files of Interest (modders)
File | Description
--- | ---
server/sv_cubics.qc | the major portion of cubic handling on the server
server/sv_cubicgen.qc | world generation
server/sv_cubiccollision.qc | collision handling
server/sv_attacks.qc | projectile collision handling and example code for adding projectiles
client/cs_cubics.qc | client cubic handling
client/cs_cubicinterface.qc | hud / clientside tool drawing and positioning is handled here
shared_server_client/sh_sv_cs_cubics.qc | tools for working with the cubic framework, and general world settings
client/cs_cubicobjects.qc | for defining custom cubic objects, being cubics that are represented with models rather than trisoup_simple polygons

### Known Issues
- chunk sizes other than 6 seem to have issues, noticed weird lighting issues on size 8, odd numbers also have problems
- hull shape inconsistencies on x and z rotated cubics
- cubics/chunks/clusters can be placed on players
- players spawn inside of eachother on server restart and don't network chunks correctly (join an existing server!)
- players can get stuck in cubics if they move too fast for the loading speed

### ToDo
- more testing on chunk sizes, 7 or 9 would be ideal for prefabs (center doors etc with odd sizes)
- more testing on extended draw ranges
- copy/paste single cubics
- update world generator to use cluster/chunk prefabs
- add alpha handling to the texture shader
- make collision hulls for x and z rotation orientations to fix hull issues
- make player light visible to other players
- animation code is temporary. (need to re-learn animation.)
- don't let players place things on players

### ChangeLog
r130
- fixed issues with odd sized chunks, by fixing several related functions that were using bad syntax
- increased chunk size from 6x6x6 to 7x7x7 (an odd value is good for designing prefabs with doorways centered.) This also effectively increases view range on default settings by about 7 cubics. Not a lot, but it's something.
- increased max light radius because increasing chunk size allows lights to run at a larger radius without major performance issues

r126
- fixed: noclip was preventing the world from loading

r123
- lots of bug fixes mostly involving stability and multiplayer
- increased default ambient lights a little from '0.2 0.2 0.6' to '0.4 0.4 0.8'
- disabled cl_predict_players to stop other players from jittering around
- disabled r_fog_cullentities (just to avoid any potential interference. can test this later.)
- chunks no longer allocate more than once during an update (potential leak fixed)
- resetlights was still registered as a command, now removed
- added a ton of debugging code for finding bad entity references
- chunks are now networked correctly to the appropriate clients
- when players disconnect they update their chunks to know they can remove if no other players are viewing them
- the world loading loop now handles all players rather than each player using their own loop
- fixed a bad reference to previously removed cubic collision bbox ents
- fixed a bug where cubic collision bbox ents were trying to spawn outside of the world if the player gets too close to the edge
- no longer ghosting clusters as it tends to break networking
- renamed some functions to make more sense (Remove* to Clear* etc)
- intervals between unloads are now global rather than per player (prevents server choking)
- when removing clusters, chunk removal is no longer staggered as this was creating more potential bad entity references. this could be fixed, but isn't really necessary. the code is left in, just not used.
- changed all references to self outside of self's initial function call in sv_cubics.qc to player

r107
- tested multiplayer. it works. (still needs to not send/draw out of range cubics loaded by other players)
- added cubiquakeserver.bat to the main engine directory to run dedicated servers easily
- added support for individual clients to save prefab files into their own directories on the server (be sure to set your "name" field)
- use the "filename" cvar to set the desired prefab filename. it is set blank by default each game. use the cvar without any value to show the current filename
- the "prefabname" cvar is no longer used
- cvar "adminpass" added to prevent clients from calling commands such as resetview without permission
- the map file is now a .map instead of a .hmp
- added "start" command/alias to the console to avoid having to type out the map command
- ambient light is now controlled on the server.
- resetview now also resets ambient light levels (and draw ranges) across all clients
- fixed a bug that was causing the server to try to initialize the client endlessly after using resetview
- fixed some text prints to no longer broadcast to every player
- removed resetlights command

r101
- view distances can now be set in the console and modified during gameplay (they are server dependent though)
- added console commands to modify view ranges: viewdist1, viewheight1, viewdist2, viewheight2, resetview
- added some comments to default.cfg

r96
- added ambient, static, and dynamic light
- added a torch cubic object, using the torch model from Quake
- T toggles a dynamic light around the client (impulse 150)
- cvar ambientlight takes a vector ('0.2 0.2 0.6' in default.cfg)
- [ and ] keys for cubic Y rotation are swapped in default.cfg
- added console command "worlds" to list existing worlds
- added console command "resetlights" for debugging (don't need it anymore, but don't need to remove it)
- removed fog from the world.hmp map file
- added a very basic shader to allow csqc to light/color polygons drawn with trisoup_simple
- hacked in some animation code for the torch
- added chunk entities that can use models/lights or any custom code
- added cs_cubicobjects.qc for defining custom objects
- removed some draw sorting code. wasn't helping as much as perceived ;)
- added cluster matrix on client that is created as needed for chunks
- moved most csqc defs to cs_cubicdefs.qc
- moved most svqc defs to sv_cubicsdefs.qc
- the cubic tool can now place custom entity type cubics along with normal trisoup_simple polygon cubics
- added an arg to DrawFaceGroup() that is unnecessary. FIXME
- worldsize is sent with the first set of chunk csqc/svqc entities before running InitGameVariables()
- fixed a texture bug in wedge shape
- now drawing engine crosshair
- fixed a bug where chunks arriving out of order would arrive before worldsize is set on the client
- added maxchunksloadedperframe and maxchunksghostedperframe to smooth out cluster/chunk load in/out
- added maxlightradius setting. can be any value, but default is recommended for performance. (192 with default world settings)
- added ambientlight setting using autocvar_ambientlight acting as the base light color
- added lightupdatedelay_static settting. 0.5s default
- added lightupdatedelay_dynamic setting. 0.02s default
-  iseven settings are now automatic
- .lightradius .lightbrightness .lightcolor for lighting
- fixed some bugs with placing chunks and clusters
- added centerprint warning when trying to edit while chunks are loading

r83
- added wedge and wedgetip shapes
- added more angles of rotation to shapes (All angles are possible now with non-symmetrical shapes.)
- chunks are now drawn from closest to furthest for 25% ish FPS increase
- greatly improved chunk and cluster lookup speed by using entity references rather than findradius()
- chunk and cluster entities are re-used where possible to reduce allocations and memfree usage
- moved face rendering functions to their own file in csqc
- moved shape functions to their own files in csqc
- no longer using dpcompat_findradiusarealinks cvar
- changed some instances of world to NULL
- removed some unused variables

r78
- added ramp shape (with collision)
- added 2 axis block rotation (textures stay aligned to the world) (keys: [ ] -+)
- added texture tools (keys: mwheel)
- added shape tool (keys: <>)
- added revision text in upper right of screen
- updated surface culling to handle rotated shapes and partial cube sides (triangles)
