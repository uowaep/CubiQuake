# CubiQuake
Cubic Game Framework for the FTE Engine

### Playing/Generation
- open the console (SHIFT-ESC) and run the following (or just run map world.hmp)
- "worldname name" (default: world1)
- "worldsize size" (default: 9 - there is no max, but beware of long generation times)
- "map world"
- If the world files don't exist they will generate into /gamedata/data/worlds/worldname and the world will spawn after generation.

### Controls
- "+attack" - Use Tool  (default mouse1)
- "impulse 1" - Tool Size: Cubic (1x)
- "impulse 2" - Tool Size: Chunk (6x)
- "impulse 3" - Tool Size: Cluster (18x) (each world file is 1 cluster of chunks, which is 5832 cubics at default settings)
- "impulse 4" - No Tool
- "impulse 100" - Tool Mode: Add Cubic(s) (default e)
- "impulse 101" - Tool Mode: Remove Cubic(s) (default q)
- "impulse 102" - Tool Mode: Copy/Save Cubics(s) (default c)
- "impulse 103" - Tool Mode: Paste/Load Cubics(s) (default v)

### CVAR prefabname
The Copy and Paste tools use a file as a clipboard. This tool works with the Chunk and Cluster size options, and saves to different directories per size. The filename can be set in the **cvar prefabname**. This tool is intended to save several different prefabs for world generation. The generator is not yet coded to take advantage of these files.

### Modify Source
Look for this function to modify settings such as cubic size, chunk size, physics, etc.
- void InitGameVariables(){} in shared_server_client/sh_sv_cs_cubics.qc

Other files of intereset include:
- server/sv_cubicgen.qc - world generation
- server/sv_cubics.qc - the major portion of cubic handling on the server
- client/cs_cubics.qc - client cubic handling

### ToDo (before code release)
- performance tests

### ToDo (after code release)
- move code out of server/sv_client.qc functions to a new file
- another pass at cleaning up code
