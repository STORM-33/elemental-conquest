extends Camera3D

var sensitivity = Globals.camera_sensitivity
func _input(event):
	if event is InputEventScreenDrag:
		var rel = event.relative
		global_translate(Vector3(-rel.x, 0, -rel.y)*sensitivity)
	elif event is InputEventMagnifyGesture:
		var zoom_factor = event.factor
		var zoom_amount = (1.0 - zoom_factor)
		global_translate(Vector3(0, 0, zoom_amount))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			global_translate(Vector3(0, -0.25, 0))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			global_translate(Vector3(0, 0.25, 0))
