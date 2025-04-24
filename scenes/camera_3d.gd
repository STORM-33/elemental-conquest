extends Camera3D


func _input(event):
	if event is InputEventScreenDrag:
		var rel = event.relative
		global_position += Vector3(rel.x, 0, rel.y)
