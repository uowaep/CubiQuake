# CubiQuake
Cubic Game Framework for the FTE Engine

### Playing/Generation
- set **cvar worldname**
- set **cvar worldsize**
- start **map world.ent**
- if the world files don't exist they will generate into their directory and the world will spawn after generation

### Controls
- "impulse 1" - Tool Size: Cubic (1x)
- "impulse 2" - Tool Size: Chunk (6x)
- "impulse 3" - Tool Size: Cluster (18x) (each world file is 1 cluster of chunks, which is 5832 cubics at default settings)
- "impulse 4" - No Tool
- "impulse 100" - Tool Mode: Add Cubic(s) (default e)
- "impulse 101" - Tool Mode: Remove Cubic(s) (default q)
- "impulse 102" - Tool Mode: Copy/Save Cubics(s) (default c)
- "impulse 103" - Tool Mode: Paste/Load Cubics(s) (default v)
- "+attack" - Use Tool  (default mouse1)

### CVAR prefabname
The Copy and Paste tools use a file as a clipboard. This tool works with the Chunk and Cluster size options, and saves to different directories per size. The filename can be set in the cvar "prefabname". This tool is intended to save several different prefabs for world generation. The generator is yet take advantage of these prefabs.

### Modify Source
Look for this function to modify settings such as cubic size, chunk size, physics, etc.
- void InitGameVariables(){} in shared_server_client/sh_sv_cs_cubics.qc

Other files of intereset include:
- server/sv_cubicgen.qc - world generation
- server/sv_cubics.qc - the major portion of cubic handling on the server
- client/cs_cubics.qc - client cubic handling

### ToDo (before code release)
- probably some other stuff :)
