# CubiQuake
Cubic Game Framework for the FTE Engine (Requires FTEQW revision 5424 or higher.)

### Playing/Generation
- open the console (SHIFT-ESC) and run the following (or just run "**map world**" and use default settings)
- "worldname name" (default: world1)
- "worldsize size" (default: 9 - there is no max, but beware of long generation times)
- "map world"
- If the world files don't exist they will generate into /gamedata/data/worlds/worldname and the world will spawn after generation.

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
impulse 120 | Tool: Cubic Type Next | mwheelup |
impulse 121 | Tool: Cubic Type Prev | mwheeldown |
impulse 122 | Tool: Cubic Shape Next | . |
impulse 123 | Tool: Cubic Shape Prev | , |
impulse 124 | Tool: Cubic Rotation Y+ | ] |
impulse 125 | Tool: Cubic Rotation Y- | \[ |
impulse 126 | Tool: Cubic Rotation Z+ | = |
impulse 127 | Tool: Cubic Rotation Y- | - |
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
- test multiplayer
- update world generator to use cluster prefabs

### ChangeLog
r78
- added ramp shape (with collision)
- added 2 axis block rotation (textures stay aligned to the world) (keys: [ ] -+)
- added texture tools (keys: mwheel)
- added shape tool (keys: <>)
- added revision text in upper right of screen
- updated surface culling to handle rotated shapes and partial cube sides (triangles)
