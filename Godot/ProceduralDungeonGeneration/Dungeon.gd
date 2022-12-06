extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(PackedScene) var room_scene;
export var dungeon_room_count = 10;

enum Directions { UP, DOWN, LEFT, RIGHT }


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	_generate_dungeon();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _generate_dungeon():
	print('Generating dungeon...');
	# build a 2d array of rooms
	# while roomsGenerate < dungeon_room_count:
		# add room to the room list
		# generate room exits:
		#	each room needs at least one exit from the direction it was created.
		# 	One in 4 chance of exit room being generated. Double check if exits are valid and do not collide.
	
	var dungeon = [];
	var rooms_to_process_list = []
	var current_coordinates = Vector2(0,0); # set starting coodinates

	while dungeon.size() < dungeon_room_count:
		var room_to_process =  rooms_to_process_list.pop_front();
		var entrance_direction = null;

		if room_to_process != null:
			entrance_direction = room_to_process.entrance_direction
			current_coordinates = room_to_process.room_coordinates

		var further_rooms_to_process = rooms_to_process_list.size() > 0;

		var new_room = _generate_room(current_coordinates, !further_rooms_to_process);

		if new_room.up:
			var coordinates = Vector2(current_coordinates.x, current_coordinates.y - 1);
			if !_is_room_in_dungeon(dungeon, coordinates):
				rooms_to_process_list.push_front({
					"entrance_direction": Directions.UP,
					"room_coordinates": coordinates
				})
		if new_room.down:
			var coordinates = Vector2(current_coordinates.x, current_coordinates.y + 1);
			if !_is_room_in_dungeon(dungeon, coordinates):
				rooms_to_process_list.push_front({
					"entrance_direction": Directions.DOWN,
					"room_coordinates": coordinates
				})
		if new_room.left:
			var coordinates = Vector2(current_coordinates.x - 1, current_coordinates.y);
			if !_is_room_in_dungeon(dungeon, coordinates):
				rooms_to_process_list.push_front({
					"entrance_direction": Directions.LEFT,
					"room_coordinates": coordinates
				})
		if new_room.right:
			var coordinates = Vector2(current_coordinates.x + 1, current_coordinates.y);
			if !_is_room_in_dungeon(dungeon, coordinates):
				rooms_to_process_list.push_front({
					"entrance_direction": Directions.RIGHT,
					"room_coordinates": coordinates
				})

		dungeon.push_back(new_room)
		# TODO:
		# Evalulate "dead" entrances, i.e. entrances that aren't matched on both rooms.
		
	for room in dungeon:
		print(room)
		var room_node = room_scene.instance()
		room_node.init(room)
		room_node.position.x = room.room_coordinates.x * 100;
		room_node.position.y = room.room_coordinates.y * 100;
		add_child(room_node)

func _generate_room(coordinates: Vector2, force_exit: bool):
	var has_at_least_one_exit = false;
	var room = {};
	room.room_coordinates = coordinates
	
	_generate_room_exits(room)

	if force_exit:
		while !_room_has_at_least_one_exit(room):
			_generate_room_exits(room)
	
	return room;

func _generate_room_exits(room):
	var cloned_room = room;
	var coordinates = cloned_room.room_coordinates;
	
	var up_exit = randi() % 4;
	var down_exit = randi() % 4;
	var left_exit = randi() % 4;
	var right_exit = randi() % 4;
	# can't go up if at top of coordinate space
	room.up = true if up_exit == 0 && coordinates.y != 0 else false; 
	room.down = true if down_exit == 0 else false;
	#can't go left if at left of coordinate space
	room.left = true if left_exit == 0 && coordinates.x != 0 else false;
	room.right = true if right_exit == 0 else false;
	
	return cloned_room

func _room_has_at_least_one_exit(room):
	if !room.up && !room.down && !room.left && !room.right:
		return false;
	else:
		return true;

func _is_room_in_dungeon(dungeon: Array, coordinates: Vector2):
	for room in dungeon:
		var room_coordinates = room.room_coordinates;
		if coordinates == room_coordinates:
			return true;
	return false;
	
