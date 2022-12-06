extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func init(room):
	print('constructing room');
	if !room.up:
		$TopDoor.queue_free()
	if !room.down:
		$BottomDoor.queue_free()
	if !room.left:
		$LeftDoor.queue_free()
	if !room.right:
		$RightDoor.queue_free()
	print("room constructed");
