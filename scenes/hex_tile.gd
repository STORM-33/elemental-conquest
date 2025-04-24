extends Node3D

@export var tile_type: String = "grass"
@export var grid_position: Vector2i
@export var biome_color := Color(0.1, 0.8, 0.2)

func set_tile_type(new_type: String):
	tile_type = new_type

func _ready():
	var deco = $ForestDeco
	if deco.has_method("set_color"):
		deco.set_color(biome_color)
