extends Node3D

const TILE_SCENE = preload("res://scenes/hex_tile.tscn")

const X_OFFSET := 1.73 
const Z_OFFSET := 1.5  

const BIOME_COLORS := [
	Color(0.2, 0.8, 0.2),  
	Color(1.0, 0.85, 0.4), 
	Color(0.9, 0.9, 1.0),  
	Color(0.4, 0.1, 0.1)   
]

func _ready():
	var map_size := Vector2i(10, 10)

	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile := TILE_SCENE.instantiate()
			add_child(tile)

			var pos_x := x * X_OFFSET
			var pos_z := y * Z_OFFSET
			if x % 2 == 1:
				pos_z += Z_OFFSET / 2

			tile.position = Vector3(pos_x, 0, pos_z)

			tile.grid_position = Vector2i(x, y)
			tile.tile_type = "grass"

			var biome_color: Color = BIOME_COLORS[randi() % BIOME_COLORS.size()]
			tile.biome_color = biome_color

			if tile.has_node("ForestDeco"):
				var deco = tile.get_node("ForestDeco")
				if deco.has_method("set_color"):
					if randf() < 0.5:
						deco.set_color(biome_color, 0.5)
					else:
						deco.queue_free()  
