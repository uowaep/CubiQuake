![alt text](https://raw.githubusercontent.com/uowaep/CubiQuake/master/cubiquake.png "CubiQuake")

Cubic Game Framework for the FTEQW Engine __(Requires FTEQW revision 5424 or higher.)__

### Recent Changes
r83 (clear data dir if anything is broken)
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

### Installation
- Download the CubiQuake zip file from GitHub and extract the entire contents anywhere.
- Download FTEQW from http://fte.triptohell.info/downloads into your main CubiQuake directory.

Note: If sharing the same FTE install with other mods, the default.fmf file should not be installed.

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
impulse 124 | Tool: Cubic Rotation Y+ | ] |
impulse 125 | Tool: Cubic Rotation Y- | \[ |
impulse 126 | Tool: Cubic Rotation X/Z+ | = |
impulse 127 | Tool: Cubic Rotation X/Z- | - |
impulse 11 | Exit Edit Mode | X | Any impulse will work.

### CVAR prefabname
The Copy and Paste tools use a file as a clipboard. This tool works with the Chunk and Cluster size options, and saves to different directories per size. The filename can be set in the **cvar prefabname**. This tool is intended to save several different prefabs for world generation. The generator is not yet coded to take advantage of these files.

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

### Multiplayer
It hasn't been tested yet, but CubiQuake is designed to be multiplayer.

### Known Issues
- no known issues

### ToDo
- lighting shaders
- test multiplayer
- update world generator to use cluster/chunk prefabs

### ChangeLog
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
