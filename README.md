# CubiQuake
Cubic Game Framework for the FTE Engine

### Controls:
- "impulse 1" - Tool Size: Cubic (1x)
- "impulse 2" - Tool Size: Chunk (6x)
- "impulse 3" - Tool Size: Cluster (18x) (each world file is 1 cluster of chunks, which is 5832 cubics at default settings)
- "impulse 4" - No Tool
- "impulse 100" - Tool Mode: Add Cubic(s)
- "impulse 101" - Tool Mode: Remove Cubic(s)
- "impulse 102" - Tool Mode: Copy/Save Cubics(s)
- "impulse 103" - Tool Mode: Paste/Load Cubics(s)
- "+attack" - Use Tool

### CVAR prefabname
The Copy and Paste tools use a file as a clipboard. This tool works with the Chunk and Cluster size options, and saves to different directories per size. The filename can be set in the cvar "prefabname". This tool is intended to save several different prefabs for world generation. The generator is yet take advantage of these prefabs.

### Modify Source
Look for this function to modify settings such as cubic size, chunk size, physics, etc.
- shared_server_client/sh_sv_cs_cubics.qc -> void InitGameVariables(){}

Other files of intereset include:
- server/sv_cubicgen.qc - world generation
- server/sv_cubics.qc - the major portion of cubic handling on the server
- client/cs_cubics.qc - client cubic handling

### Playing
- set worldname
- start a game running map world.ent
- if the world files don't exist they will generate into their directory

### ToDo (before code release)
- set up cvars and functionality for generating new worlds (worldsize, worldname)(you currently have to edit code to switch between generation and play mode, and you can't set a world name)
- prevent editing on edge of visible world (causes face cull issues)
- rename a bunch of variables and functions :P
- separate menu code for a clean base branch
- probably some other stuff
