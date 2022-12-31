extends Node

func init(room):
	if !room.up:
		$TopDoor.queue_free()
	if !room.down:
		$BottomDoor.queue_free()
	if !room.left:
		$LeftDoor.queue_free()
	if !room.right:
		$RightDoor.queue_free()
