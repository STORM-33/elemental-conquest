extends Node3D

@onready var trees := $Trees

func set_color(color: Color):

	for child in trees.get_children():
		if child is MeshInstance3D:
			var mat := StandardMaterial3D.new()
			mat.albedo_color = color
			child.material_override = mat
