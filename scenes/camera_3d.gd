extends Camera3D

var sensitivity = 0.05
func _input(event):
	if event is InputEventScreenDrag:
		var rel = event.relative
		global_position += Vector3(rel.x, 0, rel.y)*sensitivity
	elif event is InputEventMagnifyGesture:
		var zoom_factor = event.factor
		var zoom_amount = (1.0 - zoom_factor)
		global_translate(Vector3(0, 0, zoom_amount))
