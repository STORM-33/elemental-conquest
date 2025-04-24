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
	# Apply color to the tile mesh
	var tile_material = StandardMaterial3D.new()
	tile_material.transparency = 1
	tile_material.albedo_color = biome_color
	mesh_instance.material_override = tile_material
	var tile_material2 = StandardMaterial3D.new()
	tile_material2.transparency = 1
	tile_material2.albedo_color = side_color
	mesh_instance2.material_override = tile_material2
	
	# Apply color to decorations
	var deco = $ForestDeco
	if deco.has_method("set_color"):
		deco.set_color(biome_color)
