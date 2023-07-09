extends Node

func remove_doors(room):
	if !room.up:
		$TopDoor.queue_free()
	if !room.down:
		$BottomDoor.queue_free()
	if !room.left:
		$LeftDoor.queue_free()
	if !room.right:
		$RightDoor.queue_free()

func room_has_exits(room):
	if (!room.up && !room.down && !room.left && !room.right):
		return false;
	return true;

func _ready():
	pass
