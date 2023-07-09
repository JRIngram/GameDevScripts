extends Node2D

signal dungeon_generation_complete;

# draw t by t grid of empty room
# until target (t) is reached
	# process_room:
		#	roll 1d10 for down
		#		if 1d10 roll <= 8 add entrance
		#	roll 1d0 for right
		#		if dice roll <= 8 add entrance
	# add rooms with entrances to back of queue
	# check if new rooms to process are:
	#	1. already in list: in which case do not add to list
	# 	2. already processed: in which case do not add to list
	# if no entrances and no room in queue. Force down entrance


func generate_dungeon(target_room_count: int) -> Array:
	var grid = _generate_initial_grid(target_room_count);
	var nodes_to_process_queue = [Vector2(0,0)]
	_process_rooms(grid, target_room_count, nodes_to_process_queue);
	_prune_exits(grid, target_room_count);
	_resize_grid(grid)
	return grid;
	
# Generates a t by t array of rooms
func _generate_initial_grid(target: int) -> Array:
	var grid = [];
	var row = [];
	grid.resize(target);
	row.resize(target);
	
	for grid_row_count in grid.size():
		grid[grid_row_count] = []
		grid[grid_row_count].resize(target);
		for cell_count in row.size():
			var room = {
				'up': false,
				'down': false,
				'left': false,
				'right': false,
			}
			grid[grid_row_count][cell_count] = room;
	return grid;

func _process_rooms(grid: Array, target: int, nodes_to_process_queue: Array) -> void:
	var total_room_count = 0;
	while total_room_count < target:
		var room_added_on_pass = false;
		for node_to_process in nodes_to_process_queue:
			if(total_room_count == target):
				break;

			var new_room = nodes_to_process_queue.pop_front()
			var additional_nodes_to_process = _generate_room_exits(grid, new_room)

			for node in additional_nodes_to_process:
				if !_is_node_in_queue(node, nodes_to_process_queue):
					nodes_to_process_queue.push_back(node);
			
			# Check if room has at least one exit
			if _node_has_an_exit(grid, new_room):
				total_room_count += 1;
				room_added_on_pass = true;
		if room_added_on_pass == false && nodes_to_process_queue.size() == 0:
			var forced_exit_data = _force_new_random_exit(grid);
			if(forced_exit_data.is_new_room):
				total_room_count += 1;
			nodes_to_process_queue.push_back(forced_exit_data.new_node_to_process)

# Randomly generates a right or down exit for the room at the given coordinates
func _generate_room_exits(grid, coordinates: Vector2) -> Array:
	# first check if adjacent rooms have exits into current room
	var current_room = grid[coordinates.y][coordinates.x];
	var room_above = grid[coordinates.y - 1][coordinates.x];
	var room_to_left = grid[coordinates.y][coordinates.x - 1];
	if room_above.down == true:
		current_room.up = true;
	if room_to_left.right == true:
		current_room.left = true;
	
	# then generate new exits
	var down_entrance = randi() % 100;
	var right_entrance = randi() % 100;
	var additional_rooms_to_process = [];
	if down_entrance <= 66:
		current_room.down = true;
		additional_rooms_to_process.push_front(Vector2(coordinates.x, coordinates.y + 1,))
	if right_entrance <= 66:
		current_room.right = true;
		additional_rooms_to_process.push_front(Vector2(coordinates.x + 1, coordinates.y))
	grid[coordinates.y][coordinates.x] = current_room
	return additional_rooms_to_process;

# Check if the node is already present in the node_queue
func _is_node_in_queue(node: Vector2, node_queue: Array) -> bool:
	var _is_in_queue = node_queue.has(node);
	return _is_in_queue;

# Checks if the cell has an exit
func _node_has_an_exit(grid: Array, node_coordinates: Vector2):
	var node = grid[node_coordinates.y][node_coordinates.x];
	for exit in node:
		if node[exit]:
			return true;
	return false;

# forces an exit at a randomly selected bottom-most or right-most node
func _force_new_random_exit(grid: Array) -> Dictionary:
	# randomly pick down-most row or right-most column
	# randomly pick a cell
	# if right-most: add right exit
	# if down-most: add down exit
	
	var rand_direction = randi() % 2
	var expand_downwards = true;
	if(rand_direction > 0):
		expand_downwards = false;
	if(expand_downwards):
		var random_bottom_cell_coordinates = _get_random_bottom_cell_coordinates(grid)
		var is_new_room = !_node_has_an_exit(grid, random_bottom_cell_coordinates)
		grid[random_bottom_cell_coordinates.y][random_bottom_cell_coordinates.x].down = true;
		var new_node_to_process = Vector2(random_bottom_cell_coordinates.x, random_bottom_cell_coordinates.y + 1);
		var new_exit_data = {
			'is_new_room': is_new_room,
			'new_node_to_process': new_node_to_process
		}
		return new_exit_data;
	else:
		var random_right_cell_coordinates = _get_random_right_cell_coordinates(grid)
		var is_new_room = !_node_has_an_exit(grid, random_right_cell_coordinates)
		grid[random_right_cell_coordinates.y][random_right_cell_coordinates.x].right = true;
		var new_node_to_process = Vector2(random_right_cell_coordinates.x + 1, random_right_cell_coordinates.y);
		var new_exit_data = {
			'is_new_room': is_new_room,
			'new_node_to_process': new_node_to_process
		}
		return new_exit_data;

# gets coordinates of a random cell on the bottom row
func _get_random_bottom_cell_coordinates(grid: Array) -> Vector2:
	var bottom_row_coord = _get_bottom_grid_row(grid);
	var bottom_cell_coordinates_list = [];
	
	for cell_count in grid[bottom_row_coord].size():
		var cell = grid[bottom_row_coord][cell_count]
		for key in cell:
			if(cell[key] == true):
				bottom_cell_coordinates_list.push_back(Vector2(cell_count, bottom_row_coord));
	if(bottom_cell_coordinates_list.size() == 0):
		bottom_cell_coordinates_list.push_back(Vector2(0, bottom_row_coord))
	var random_cell_coordinates = bottom_cell_coordinates_list[randi() % bottom_cell_coordinates_list.size()]
	return random_cell_coordinates

# Gets the bottom row of the grid with a processed cell
func _get_bottom_grid_row(grid: Array) -> int:
	var reverse_row_count = grid.size() - 1;

	while reverse_row_count > 0:
		var grid_row = grid[reverse_row_count]
		for cell in grid_row:
			for key in cell:
				if(cell[key] == true):
					return reverse_row_count;
		reverse_row_count = reverse_row_count - 1;
			
	return 0;

# gets coordinates of a random cell on the right row
func _get_random_right_cell_coordinates(grid: Array) -> Vector2:
	var right_column_coord = _get_rightmost_grid_column(grid)
	var right_cell_coordinates_list = [];
	
	for row_count in grid[right_column_coord].size():
		var cell_coordinates = Vector2(right_column_coord, row_count)
		var cell_has_exit = _node_has_an_exit(grid, cell_coordinates)
		if cell_has_exit == true:
			right_cell_coordinates_list.push_back(cell_coordinates)
	if(right_cell_coordinates_list.size() == 0):
		right_cell_coordinates_list.push_back(Vector2(right_column_coord, 0))
		
	var random_cell_coordinates = right_cell_coordinates_list[randi() % right_cell_coordinates_list.size()]
	return random_cell_coordinates;

# Gets the rightmost row of the grid with a processed cell
func _get_rightmost_grid_column(grid: Array) -> int:
	var reverse_column_count = grid.size() - 1;
	
	while reverse_column_count > 0:
		for row in grid.size():
			var is_cell_with_exits = _node_has_an_exit(grid, Vector2(reverse_column_count, row))
			if(is_cell_with_exits):
				return reverse_column_count;
		reverse_column_count = reverse_column_count - 1;

	return 0;
	

# Removes dead ends from the grid.
func _prune_exits(grid: Array, target_room_count: int) -> void:
	for row_count in grid.size():
		for cell_count in grid.size():
			# if cell count = 0 don't check room to left
			if(cell_count == 0 || grid[row_count][cell_count - 1].right == false):
				grid[row_count][cell_count].left = false;
			# if cell count = t don't check room to right
			if((cell_count + 1) == target_room_count || grid[row_count][cell_count + 1].left == false):
				grid[row_count][cell_count].right = false;
			# row count = 0 don't check up
			if(row_count == 0 || grid[row_count - 1][cell_count].down == false):
				grid[row_count][cell_count].up = false;
			# row count = t don't check down
			if((row_count + 1) == target_room_count || grid[row_count + 1][cell_count].up == false):
				grid[row_count][cell_count].down = false;

# Resize the grid to remove rows and columns with null entries				
func _resize_grid(grid: Array):
	var prior_size = grid.size() * grid.size();
	var bottom_column_with_nodes = _get_bottom_grid_row(grid) + 1;
	var right_most_column_with_nodes = _get_rightmost_grid_column(grid) + 1;
	var resized_grid = []
	grid.resize(bottom_column_with_nodes)
	for row in grid:
		row.resize(right_most_column_with_nodes)
	var new_size = bottom_column_with_nodes * bottom_column_with_nodes;
	var shrinkage_rate = float((new_size / prior_size) * 100)
	print('old size: ', prior_size, '; new size:', new_size);
	print('shrinkage: ', shrinkage_rate);
