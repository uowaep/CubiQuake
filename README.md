![alt text](https://raw.githubusercontent.com/uowaep/CubiQuake/master/cubiquake.png "CubiQuake")

Cubic Game Framework for the FTEQW Engine __(Requires FTEQW revision 5424 or higher.)__

Cubiquake is a framework for quake mod developers to build cubic style (mistakenly referred to as voxel by some) games in the FTEQW engine. Cubiquake uses trisoup_simple to draw most surfaces, and dynamically spawns collision surfaces and calculates lighting as the player moves through the world. Multiple shapes are supported, currently cube, ramp, wedge, and wedge tip. Cubics types can also be set to designate the texture, or alternatively models for cubic spaces held by objects, currently using a torch as an example. Ambient, static, and dynamic light all work. You do not need to be a modder to use CubiQuake as is. Just follow the installation and playing/generation instructions.

### Recent Changes
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

### Installation
- Download CubiQuake https://github.com/uowaep/CubiQuake/archive/master.zip and extract the entire contents of the zip file anywhere.
- Download the appropriate client from FTEQW http://fte.triptohell.info/downloads and place it in your main CubiQuake directory.

Note: If sharing the same FTE install with other mods, the default.fmf file should not be installed.

### Updating
Extract the new files into your install directory. It's always good idea to start from scratch when updating, but you shouldn't need to. If anything is broken try clearing the data dir first. If that doesn't help, start from a clean install. If that doesn't help run debug mode in FTEQCC and get some screenshots.

### Playing/Generation
- Start FTEQW.
- Open the console. (SHIFT-ESC)
- Quick Start - Run '**map world**' and use default settings.
>
- Custom Start - Run the following:
- - 'worldname name' (default: world1)
- - 'worldsize size' (default: 9 - There is no max, but beware of long generation times.)
- - 'map world'

If the world files don't exist they will generate into /gamedata/data/worlds/worldname and the world will spawn after generation.

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
Command | Description
--- | ---
worlds | Lists existing worlds.
resetlights | For debugging lights if still necessary. Clears face light data and re-applies lighting values.

### CVARs
CVAR | Description
--- | ---
ambientlight | Sets the base light color applied to textures with a red green blue vector. '0 0 0' is black, '1 1 1' is full color.  ('0.2 0.2 0.6' in default.cfg)
prefabname | The Copy and Paste tools use a file as a clipboard. This tool works with the Chunk and Cluster size options, and saves to different directories per size. The filename can be set in the **cvar prefabname**. This tool is intended to save several different prefabs for world generation. Note: The generator is not yet coded to take advantage of these files, but you can still place them manually.
worldname | Sets the world name, which is also the directory where the files are stored within data/worlds/. (default: world1)
worldsize | Sets the world size in clusters. (default: 9 - There is no max, but beware of long generation times.)

### Files of Interest
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

### Multiplayer
It hasn't been tested yet, but CubiQuake is designed to be multiplayer.

### Known Issues
- minor collision hull weirdness
- animation code is temporary. (need to re-learn animation. been doing it wrong for too long.)

### ToDo
- test multiplayer
- update world generator to use cluster/chunk prefabs
- add alpha handling to the texture shader

### ChangeLog
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
