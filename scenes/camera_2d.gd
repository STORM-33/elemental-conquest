extends Camera2D

var sensitivity = Globals.camera_sensitivity
var is_dragging = false
var drag_start_position = Vector2.ZERO
var zoom_speed = 0.1
var min_zoom = Vector2(0.5, 0.5)
var max_zoom = Vector2(2.0, 2.0)

func _ready():
	# Enable camera dragging on mobile and desktop
	set_process_input(true)

func _input(event):
	# Handle pinch to zoom on mobile
	if event is InputEventMagnifyGesture:
		var zoom_factor = event.factor
		var new_zoom = zoom - Vector2(zoom_speed, zoom_speed) * (zoom_factor - 1)
		new_zoom = new_zoom.clamp(min_zoom, max_zoom)
		zoom = new_zoom
	
	# Handle drag on mobile
	elif event is InputEventScreenDrag:
		position -= event.relative * sensitivity / zoom
	
	# Handle mouse wheel for zoom on desktop
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
			zoom = new_zoom.clamp(min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
			zoom = new_zoom.clamp(min_zoom, max_zoom)
		
		# Handle drag with mouse
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
			else:
				is_dragging = false
	
	# Handle mouse movement while dragging
	elif event is InputEventMouseMotion and is_dragging:
		position -= event.relative * sensitivity / zoom
