extends Node2D

enum Directions { UP, DOWN, LEFT, RIGHT }
const PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED = 25;
export var dungeon_room_count: int = 10;
export(PackedScene) var room_scene;

var dungeon

# Called when the node enters the scene tree for the first time.
func _ready():
	print('starting');
	randomize();
	dungeon = _generate_dungeon();
	for row in dungeon:
		for room in row:
			if room != null:
				var room_node = room_scene.instance()
				room_node.init(room)
				room_node.position.x = room.room_coordinates.x * 100;
				room_node.position.y = room.room_coordinates.y * 100;
				add_child(room_node)

func _generate_dungeon():
	print('Generating dungeon...');
	# build a 2d array of null
	# while roomsGenerated < dungeon_room_count:
		# add room to the room list
		# generate room exits:
		#	each room needs at least one exit from the direction it was created.
		# 	One in 4 chance of exit room being generated. Double check if exits are valid and do not collide.
	
	# generate an n by n 2d, where n = dungeon_room_count;
	dungeon = [];
	for row in dungeon_room_count:
		var dungeon_row = [];
		for column in dungeon_room_count:
			dungeon_row.push_back(null);
		dungeon.push_back(dungeon_row);	

	var rooms_to_process_list = [];
	var previously_processed_room_coords = [];
	var current_coordinates = Vector2(0,0); # set starting coodinates

	while get_dungeon_room_count(dungeon) < dungeon_room_count:
		var room_coords_to_process =  rooms_to_process_list.pop_front();

		if room_coords_to_process != null:
			current_coordinates = room_coords_to_process;

		var further_rooms_to_process = rooms_to_process_list.size() > 0;
	
		# check if valid exit exists on current room being processed
		# if not current_coorindates = previously_process_rooms.pop_front().room_coordinates
		var reprocessing_room = false;
		while room_coords_to_process && !_room_has_valid_exits(dungeon, room_coords_to_process):
			print('moving back')
			#print(dungeon)
			#print(dungeon[10][0]) # change with each debug attempt
			#print(room_coords_to_process)
			current_coordinates = previously_processed_room_coords.pop_front();
			room_coords_to_process = current_coordinates;
			reprocessing_room = true
			# need to ensure when reprocessing a room we don't destroy old exits
		
		var new_room
		if reprocessing_room:
			var room_to_reprocess = dungeon[current_coordinates.y][current_coordinates.x]
			new_room = _reprocess_room(dungeon, room_to_reprocess);
			reprocessing_room = false;
		else:
			new_room = _generate_room(current_coordinates, !further_rooms_to_process, dungeon);
	
		rooms_to_process_list = _add_adjacent_rooms_to_process(rooms_to_process_list, new_room)

		dungeon[current_coordinates.y][current_coordinates.x] = new_room
		if !previously_processed_room_coords.has(current_coordinates):
			previously_processed_room_coords.push_front(current_coordinates);
	
	dungeon = _knock_through_entrances(dungeon);
	return dungeon;

func _generate_room(coordinates: Vector2, force_exit: bool, dungeon):
	var room = {};
	room.room_coordinates = coordinates
	
	room = _generate_room_exits(room)

	if force_exit:
		while !_room_has_at_least_one_exit(room):
			room = _generate_room_exits(room)
			if _is_valid_addable_room_exit(dungeon, coordinates, Directions.UP):
				room.up = true;
			if _is_valid_addable_room_exit(dungeon, coordinates, Directions.DOWN):
				room.down = true;
			if _is_valid_addable_room_exit(dungeon, coordinates, Directions.LEFT):
				room.left = true;
			if _is_valid_addable_room_exit(dungeon, coordinates, Directions.RIGHT):
				room.right = true;
	return room;

func _generate_room_exits(room):
	var cloned_room = room;
	var coordinates = cloned_room.room_coordinates;
	
	var up_exit = randi() % 100;
	var down_exit = randi() % 100;
	var left_exit = randi() % 100;
	var right_exit = randi() % 100;

	# can't go up if at top of coordinate space
	room.up = true if up_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && coordinates.y != 0 else false; 
	room.down = true if down_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED else false;
	#can't go left if at left of coordinate space
	room.left = true if left_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && coordinates.x != 0 else false;
	room.right = true if right_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED else false;
	
	return cloned_room

# Returns true if room has at least one exit. Else returns false.
func _room_has_at_least_one_exit(room):
	if !room.up && !room.down && !room.left && !room.right:
		return false;
	else:
		return true;

# Returns true if a room with the same coordinates exists in the passed dungeon array. Else returns false
func _is_room_in_dungeon(dungeon: Array, coordinates: Vector2):
	var room_to_check = dungeon[coordinates.y][coordinates.x];
	
	if room_to_check != null:
		return true;
	return false;
	
# If there is an adjacent room in a given direction (where there is an entrance in the current room), then create an entrance in the adjacent room in the opposite direction
# Else destroy the entrance
func _knock_through_entrances(dungeon):
	var cloned_dungeon = dungeon;
	var row_count = 0;

	for row in cloned_dungeon:
		var room_count = 0;
		for room in row:			
			var room_coordinates = Vector2(room_count, row_count);
			if room != null:
				if room.up && room_coordinates.y - 1 >= 0:
					var up_room = dungeon[room_coordinates.y - 1][room_coordinates.x];
					if up_room != null:
						dungeon[room_coordinates.y - 1][room_coordinates.x].down = true;

				if room.down && room_coordinates.y < dungeon_room_count:
					var down_room = dungeon[room_coordinates.y + 1][room_coordinates.x];
					if down_room != null:
						dungeon[room_coordinates.y + 1][room_coordinates.x].up = true;

				if room.left && room_coordinates.x - 1 >= 0:
					var left_room = dungeon[room_coordinates.y][room_coordinates.x - 1];
					if left_room != null:
						left_room.right = true;

				if room.right && room_coordinates.x < dungeon_room_count:
					var right_room = dungeon[room_coordinates.y][room_coordinates.x + 1];
					if right_room != null:
						dungeon[room_coordinates.y][room_coordinates.x + 1].left = true;
						
			room_count = room_count + 1;
		row_count = row_count + 1;
	
	return cloned_dungeon

# Returns the index of the room within the dungeon array with the given coordinates or null if no such room exists
func _find_index_of_room_with_coords(dungeon, coordinates: Vector2):
	for i in dungeon.size():
		var room = dungeon[i]
		if coordinates == room.room_coordinates:
			return i;
	return null;

func _add_adjacent_rooms_to_process(rooms_to_process_list, new_room):
	var cloned_rooms_to_process_list = rooms_to_process_list;
	var current_coordinates = new_room.room_coordinates;
	if new_room.up:
		var coordinates = Vector2(current_coordinates.x, current_coordinates.y - 1);
		if !_is_room_in_dungeon(dungeon, coordinates):
			cloned_rooms_to_process_list.push_front(coordinates)
	if new_room.down:
		var coordinates = Vector2(current_coordinates.x, current_coordinates.y + 1);
		if !_is_room_in_dungeon(dungeon, coordinates):
			cloned_rooms_to_process_list.push_front(coordinates)
	if new_room.left:
		var coordinates = Vector2(current_coordinates.x - 1, current_coordinates.y);
		if !_is_room_in_dungeon(dungeon, coordinates):
			cloned_rooms_to_process_list.push_front(coordinates)
	if new_room.right:
		var coordinates = Vector2(current_coordinates.x + 1, current_coordinates.y);
		if !_is_room_in_dungeon(dungeon, coordinates):
			cloned_rooms_to_process_list.push_front(coordinates)
	
	return cloned_rooms_to_process_list

func get_dungeon_room_count(dungeon):
	var _room_count = 0;
	for row in dungeon:
		if row != null:
			for room in row:
				if room != null:
					_room_count = _room_count + 1;
	return _room_count;

# Returns true if the room in a given direction does not yet exist and if an exit does not already exist in that direction
# Else returns false
func _is_valid_addable_room_exit(dungeon, room_coordinates, exit_direction):
	var room = dungeon[room_coordinates.y][room_coordinates.x]

	if exit_direction == Directions.UP && room_coordinates.y - 1 >= 0:
		if room:
			return !room.up && !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x, room_coordinates.y - 1));
		else:
			return !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x, room_coordinates.y - 1));

	if exit_direction == Directions.DOWN && room_coordinates.y < dungeon_room_count:
		if room:
			return !room.down && !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x, room_coordinates.y + 1))
		else:
			return !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x, room_coordinates.y + 1))

	if exit_direction == Directions.LEFT && room_coordinates.x - 1 >= 0:
		if room:
			return !room.left && !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x - 1, room_coordinates.y));
		return !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x - 1, room_coordinates.y))

	if exit_direction == Directions.RIGHT && room_coordinates.x < dungeon_room_count:
		if room:
			return !room.right && !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x + 1, room_coordinates.y))
		return !_is_room_in_dungeon(dungeon, Vector2(room_coordinates.x + 1, room_coordinates.y))

# Returns true if either up, down, left or right is a valid exit. Else returns false.
func _room_has_valid_exits(dungeon, room_coordinates):
		return _is_valid_addable_room_exit(dungeon, room_coordinates, Directions.UP) || _is_valid_addable_room_exit(dungeon, room_coordinates, Directions.DOWN) || _is_valid_addable_room_exit(dungeon, room_coordinates, Directions.LEFT) || _is_valid_addable_room_exit(dungeon, room_coordinates, Directions.RIGHT)	

func _reprocess_room(dungeon, room):
	var exit_added = false;
	
	while !exit_added:
		var up_exit = randi() % 100;
		var down_exit = randi() % 100;
		var left_exit = randi() % 100;
		var right_exit = randi() % 100;

		if !room.up && up_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && _is_valid_addable_room_exit(dungeon, room.room_coordinates, Directions.UP):
			room.up = true;
			exit_added = true;
		if !room.down && down_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && _is_valid_addable_room_exit(dungeon, room.room_coordinates, Directions.DOWN):
			room.down = true;
			exit_added = true;
		if !room.left && left_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && _is_valid_addable_room_exit(dungeon, room.room_coordinates, Directions.LEFT):
			room.left = true;
			exit_added = true;
		if !room.right && right_exit < PERCENTAGE_CHANCE_OF_ROOM_EXIT_GENERATED && _is_valid_addable_room_exit(dungeon, room.room_coordinates, Directions.RIGHT):
			room.right = true;
			exit_added = true;
	return room;
