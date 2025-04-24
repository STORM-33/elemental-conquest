extends Node3D

@onready var trees := $Trees

func set_color(color: Color, y_offset := 0):
	trees.position.y = y_offset

	for child in get_children():
		if child is MeshInstance3D:
			var mat := StandardMaterial3D.new()
			mat.albedo_color = color
			child.material_override = mat
