extends GutTest

var Dungeon = load('res://Scripts/Dungeon.gd');
var _dungeon = null;
enum Directions { UP, DOWN, LEFT, RIGHT }

class TestRoomHasAtLeastOneExit:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	var _room = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		_room = null;

	func test_at_least_one_exit_with_no_exit():
		_room = { 'up': false, 'down': false, 'left': false, 'right': false}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_false(result)
		
	func test_at_least_one_exit_with_up_exit():
		_room = { 'up': true, 'down': false, 'left': false, 'right': false}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_true(result)

	func test_at_least_one_exit_with_down_exit():
		_room = { 'up': false, 'down': true, 'left': false, 'right': false}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_true(result)
		
	func test_at_least_one_exit_with_left_exit():
		_room = { 'up': false, 'down': false, 'left': true, 'right': false}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_true(result)
		
	func test_at_least_one_exit_with_right_exit():
		_room = { 'up': false, 'down': false, 'left': false, 'right': true}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_true(result)
		
	func test_at_least_one_exit_with_all_exits():
		_room = { 'up': true, 'down': true, 'left': true, 'right': true}
		var result = _dungeon._room_has_at_least_one_exit(_room);
		assert_true(result)

class TestIsRoomInDungeon:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	var _room = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		_room = null;
	
	func test_returns_false_if_dungeon_empty():
		var room_count = 10;
		var rooms = []
		rooms.resize(room_count);
		rooms.fill(null);
		
		var test_dungeon = []
		test_dungeon.resize(room_count)
		test_dungeon.fill(rooms);

		var result = _dungeon._is_room_in_dungeon(test_dungeon, Vector2(0,0))
		assert_false(result);

	func test_returns_true_room_in_dungeon():
		var _dungeon_array = [
			[
				{ "up": false, "down": false, "left": false, "right": false,},
				{ "up": false, "down": false, "left": false, "right": false },
			],
			[
				{ "up": false, "down": false, "left": false, "right": false},
				{ "up": false, "down": false, "left": false, "right": false}
			]
		]

		var result = _dungeon._is_room_in_dungeon(_dungeon_array, Vector2(1,0))
		
		assert_true(result);
	
	func test_returns_false_room_not_in_dungeon():
		var _dungeon_array = [
			[
				{ "up": false, "down": false, "left": false, "right": false,},
				{ "up": false, "down": false, "left": false, "right": false },
				null
			],
			[
				{ "up": false, "down": false, "left": false, "right": false},
				{ "up": false, "down": false, "left": false, "right": false},
				{ "up": false, "down": false, "left": false, "right": false },
			]
		]

		var result = _dungeon._is_room_in_dungeon(_dungeon_array, Vector2(2,0));
		
		assert_false(result);
	
class TestFindIndexOfRoomWithCoords:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	var _room = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		_room = null;
	
	func test_returns_null_if_no_such_coords():
		var _dungeon_array = []
		var _room = { "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(1,0)};
		_dungeon_array.push_front(_room);

		var result = _dungeon._find_index_of_room_with_coords(_dungeon_array, Vector2(0,0));
		
		assert_null(result);
	
	func test_returns_index_if_no_such_coords():
		var _dungeon_array = [
			{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(0,0)},
			{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(1,0)},
			{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(0,1)},
			{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(1,1)}
		]

		var result = _dungeon._find_index_of_room_with_coords(_dungeon_array, Vector2(0,1));
		
		assert_eq(result, 2)

class TestKnockThroughEntrances:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	var _room = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		_room = null;
	
	func test_central_room_with_four_exits():
		var dungeon_rooms = [
			[
				null,
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
				null,
			],
			[
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(0,1)},
				{ "up": true, "down": true, "left": true, "right": true, "room_coordinates": Vector2(1,1)},
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(2,1)},
			],
			[
				null,
				{"up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,2)},
				null,
			],
		]
		
		var result = _dungeon._knock_through_entrances(dungeon_rooms)
		
		assert_true(result[0][1].down); # up room
		assert_true(result[1][0].right); # left room
		assert_true(result[1][2].left); # right room
		assert_true(result[2][1].up); # down room
	
	func test_corner_room():
		var dungeon_rooms = [
			[
				{ "up": false, "down": true, "left": false, "right": true, "room_coordinates": Vector2(0,0)},
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
				null,
			],
			[
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(0,1)},
				null,
				null,
			]
		]
		
		var result = _dungeon._knock_through_entrances(dungeon_rooms)
		print(result)
		print(result[1][0])
		assert_true(result[0][0].down); # top-right corner room
		assert_true(result[0][0].right); # top-right corner room
		# assert_true(result[0][1].left); # right room
		assert_true(result[1][0].up); # down room

class TestGetDungeonRoomCount:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		
	func test_empty_dungeon():
		var rooms = []
		
		var expected = 0;
		var result = _dungeon.get_dungeon_room_count(rooms);
		
		assert_eq(result, expected);
	
	func test_dungeon_room_count_10_nulls():
		var room_count = 10;
		var rooms = []
		rooms.resize(room_count);
		rooms.fill(null);
		
		var test_dungeon = []
		test_dungeon.resize(room_count)
		test_dungeon.fill(rooms);
		
		var expected = 0;
		var result = _dungeon.get_dungeon_room_count(rooms);
		
		assert_eq(result, expected);
		
	
	func test_multiple_rooms():
		var rooms = [
			{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
			{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(0,1)},
			{ "up": true, "down": true, "left": true, "right": true, "room_coordinates": Vector2(1,1)},
		]
		
		var test_dungeon = [
			rooms,
			rooms,
			rooms,
		]
		
		var expected = 9;
		var result = _dungeon.get_dungeon_room_count(test_dungeon);
		
		assert_eq(result, expected);

class TestIsValidRoomExit:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		
	func test_central_room_no_valid_exit():
		var dungeon_rooms = [
			[
				null,
				{ "up": false, "down": true, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
				null,
			],
			[
				{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(0,1)},
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,1)},
				{ "up": false, "down": false, "left": true, "right": false, "room_coordinates": Vector2(2,1)},
			],
			[
				null,
				{"up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,2)},
				null,
			],
		]
		var central_room = dungeon_rooms[1][1];

		assert_false(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.UP))
		assert_false(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.DOWN))
		assert_false(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.LEFT))
		assert_false(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.RIGHT))

	func test_central_room_with_valid_exit():
		var dungeon_rooms = [
			[
				null,
				null,
				null,
			],
			[
				null,
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,1)},
				null,
			],
			[
				null,
				null,
				null,
			],
		]
		var central_room = dungeon_rooms[1][1];

		assert_true(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.UP))
		assert_true(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.DOWN))
		assert_true(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.LEFT))
		assert_true(_dungeon._is_valid_room_exit(dungeon_rooms, central_room, Directions.RIGHT))

class TestHasValidRoomExits:
	extends GutTest
	
	var Dungeon = load('res://Scripts/Dungeon.gd');
	var _dungeon = null;
	
	func before_each():
		_dungeon = Dungeon.new();
		
	func after_each():
		_dungeon.free();
		
	func test_central_room_no_valid_exits():
		var dungeon_rooms = [
			[
				null,
				{ "up": false, "down": true, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
				null,
			],
			[
				{ "up": false, "down": false, "left": false, "right": true, "room_coordinates": Vector2(0,1)},
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,1)},
				{ "up": false, "down": false, "left": true, "right": false, "room_coordinates": Vector2(2,1)},
			],
			[
				null,
				{"up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,2)},
				null,
			],
		]
		var central_room = dungeon_rooms[1][1];

		var result = _dungeon._room_has_valid_exits(dungeon_rooms, central_room)
		assert_false(result)


	func test_central_room_with_all_valid_exits():
		var dungeon_rooms = [
			[
				null,
				null,
				null,
			],
			[
				null,
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,1)},
				null,
			],
			[
				null,
				null,
				null,
			],
		]
		var central_room = dungeon_rooms[1][1];

		var result = _dungeon._room_has_valid_exits(dungeon_rooms, central_room)
		assert_true(result)

	func test_central_room_with_one_valid_exits():
		var dungeon_rooms = [
			[
				null,
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(1,0)},
				null,
			],
			[
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(0,1)},
				{ "up": true, "down": false, "left": true, "right": true, "room_coordinates": Vector2(1,1)},
				{ "up": false, "down": false, "left": false, "right": false, "room_coordinates": Vector2(2,1)},
			],
			[
				null,
				null,
				null,
			],
		]
		var central_room = dungeon_rooms[1][1];

		var result = _dungeon._room_has_valid_exits(dungeon_rooms, central_room)
		assert_true(result)
