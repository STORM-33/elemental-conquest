extends Camera2D

var sensitivity = Globals.camera_sensitivity
var zoom_speed = 0.1
var min_zoom = Vector2(0.1, 0.1)
var max_zoom = Vector2(2.0, 2.0)

func _ready():
	# Make this the active camera
	make_current()
	
	# Default zoom level to see more of the map
	zoom = Vector2(0.5, 0.5)
	
	print("Camera2D initialized at position: ", position)
	print("Initial zoom: ", zoom)

func _input(event):
	# Handle screen drag (touch/mobile)
	if event is InputEventScreenDrag:
		var rel = event.relative
		position -= rel * sensitivity / zoom
		
	# Handle pinch to zoom (mobile)
	elif event is InputEventMagnifyGesture:
		var zoom_factor = event.factor
		var new_zoom = zoom * zoom_factor
		zoom = new_zoom.clamp(min_zoom, max_zoom)
		
	# Handle mouse wheel for zoom (desktop)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
			zoom = new_zoom.clamp(min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
			zoom = new_zoom.clamp(min_zoom, max_zoom)
