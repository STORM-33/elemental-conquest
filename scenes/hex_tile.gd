extends Node3D

@export var tile_type: String = "grass"
@export var grid_position: Vector2i

var _biome_color := Color(0, 0, 0)
var _side_color := Color(0, 0, 0)

@export var biome_color: Color:
	get:
		return _biome_color
	set(value):
		_biome_color = value
		_update_top_color()

@export var side_color: Color:
	get:
		return _side_color
	set(value):
		_side_color = value
		_update_side_color()

@onready var mesh_instance := $TopColor
@onready var mesh_instance2 := $SideColor

func set_tile_type(new_type: String):
	tile_type = new_type

func _ready():
	call_deferred("_update_colors")
	
	var deco = $ForestDeco
	if deco and deco.has_method("set_color"):
		deco.set_color(_biome_color)

func _update_colors():
	_update_top_color()
	_update_side_color()

func _update_top_color():
	if not is_instance_valid(mesh_instance):
		return
		
	var mat = mesh_instance.material_override
	if not mat:
		mat = StandardMaterial3D.new()
		mesh_instance.material_override = mat
	
	mat.albedo_color = _biome_color

func _update_side_color():
	if not is_instance_valid(mesh_instance2):
		return
		
	var mat = mesh_instance2.material_override
	if not mat:
		mat = StandardMaterial3D.new()
		mesh_instance2.material_override = mat
	
	mat.albedo_color = _side_color
