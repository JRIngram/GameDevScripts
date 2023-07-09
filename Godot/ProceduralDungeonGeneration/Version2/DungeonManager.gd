extends Node2D
var dungeon_generator = load('res://Scenes/DungeonGenerator.tscn');
var room = load('res://Scenes/Room.tscn');

@export
var target_room_count = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var generator = dungeon_generator.instantiate();
	var dungeon = generator.generate_dungeon(target_room_count)
	_render_dungeon(dungeon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _render_dungeon(dungeon: Array) -> void:
	for dungeon_row_count in dungeon.size():
		var row = dungeon[dungeon_row_count];
		for node_count in row.size():
			var room_dict = dungeon[dungeon_row_count][node_count];
			var room_node = room.instantiate();
			room_node.position = Vector2((node_count + 1) * (1.5*40), (dungeon_row_count + 1) * (1.5*40));
			room_node.remove_doors(room_dict);
			if(room_node.room_has_exits(room_dict)):
				add_child(room_node)				
