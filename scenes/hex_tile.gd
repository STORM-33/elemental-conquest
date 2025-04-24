extends Node3D

@export var tile_type: String = "grass"
@export var grid_position: Vector2i
@export var biome_color := Color(0.1, 0.8, 0.2)
@export var side_color := Color(0.1, 0.1, 0.1)

func set_tile_type(new_type: String):
	tile_type = new_type

func _ready():
	if has_node("MeshInstance3D"):
		var mesh_instance_top = $TopColor
		var mesh_instance_side = $SideColor
		var mat := StandardMaterial3D.new()
		mat.albedo_color = biome_color
		mesh_instance_top.material_override = mat
		var mat2 := StandardMaterial3D.new()
		mat2.albedo_color = side_color
		mesh_instance_side.material_override = mat2
		
	
	var deco = $ForestDeco
	if deco.has_method("set_color"):
		deco.set_color(biome_color)
