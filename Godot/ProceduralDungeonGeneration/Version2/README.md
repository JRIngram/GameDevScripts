# Dungeon Generator 2
A simplified interation on my first procedural dungeon generator ([blog post](https://ingram.technology/blogs/29-01-2023-procedural-dungeon-generation.html)). This has been built using Godot Engine and `GDScript`. The algorithm could be reimplemented for other engines.

There are three scripts in this directory: one is the algorithm itself and two are utilities.

## Scripts
### DungeonGenerator.gd
`DungeonGenerator.gd` - The algorithm itself. All other scripts aren't necessary to implement the algorithm, however are utilities to easily show a 2D dungeon. 

`DungeonGenerator.gd` needs to be attached to a DungeonGenerator scene.

The script runs through the algorithm and returns a 2D array of room objects. This array can then be rendered by another scene/script.

A blog post detailing the algorithm can be [found on my website](https://ingram.technology/blogs/09-07-2023-procedural-dungeon-gen-two.htm).

### `DungeonManager.gd`
This is the script for rendering the dungeon. This instantiates a Dungeon Generator scene to trigger the generation algorithm and then renders the dungeon by iterating over the output 2D array and rendering rooms.

### `Room.gd`
A script for rendering rooms. 

The room script should be attached a Room Scene. The Room Scene which has the following child nodes: Background, TopDoor, BottomDoor, LeftDoor, RightDoor. All these child nodes should be sprites. 

The Room scene acts as a way to show the dungeon layout.
