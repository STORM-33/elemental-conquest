extends Node3D

@export var tile_type: String = "grass"
@export var grid_position: Vector2i
@export var biome_color := Color(0, 0, 0)
@export var side_color := Color(0, 0, 0)

@onready var mesh_instance := $TopColor
@onready var mesh_instance2 := $SideColor

func set_tile_type(new_type: String):
	tile_type = new_type

func _ready():
	var top_material = StandardMaterial3D.new()
	top_material.albedo_color = biome_color
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	
	var side_material = StandardMaterial3D.new()
	side_material.albedo_color = side_color
	mesh_instance2.mesh = mesh_instance2.mesh.duplicate()
	mesh_instance2.mesh.material = side_material
	
	# Apply color to decorations
	var deco = $ForestDeco
	if deco and deco.has_method("set_color"):
		deco.set_color(biome_color)
