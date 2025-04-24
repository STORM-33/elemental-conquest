extends Node3D

const TILE_SCENE = preload("res://scenes/hex_tile.tscn")

const M := 0.6
const X_OFFSET := 1.732 * M
const Z_OFFSET := 1.5 * M

# Define biomes with unique names
enum BiomeType {
	GRASSLAND,
	DESERT,
	SNOW,
	MOUNTAINS
}

# Define biome data (colors, tree density, etc.)
const BIOME_DATA = {
	BiomeType.GRASSLAND: {
		"name": "Grassland",
		"top_color": Color(0.2, 0.8, 0.2),
		"side_color": Color(0.1, 0.1, 0.1),
		"tree_color": Color(0.1, 0.1, 0.1),
		"tree_chance": 0.7,
		"elevation": 0.0
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"top_color": Color(1.0, 0.85, 0.4),
		"side_color": Color(0.1, 0.1, 0.1),
		"tree_color": Color(0.1, 0.1, 0.1),
		"tree_chance": 0.2,
		"elevation": 0.0
	},
	BiomeType.SNOW: {
		"name": "Snow",
		"top_color": Color(0.9, 0.9, 1.0),
		"side_color": Color(0.1, 0.1, 0.1),
		"tree_color": Color(0.4, 0.4, 0.4),
		"tree_chance": 0.4,
		"elevation": 0.0
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"top_color": Color(0.4, 0.1, 0.1),
		"side_color": Color(0.1, 0.1, 0.1),
		"tree_color": Color(0.4, 0.1, 0.1),
		"tree_chance": 0.3,
		"elevation": 0.0
	}
}

var noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()

func _ready():
	# Initialize noise generators
	setup_noise()
	
	# Generate map with biomes
	generate_map()

func setup_noise():
	# Main terrain noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.15  # Increased from 0.05
	
	# Moisture noise affects biome selection
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	moisture_noise.seed = randi() + 100  # Different seeds
	moisture_noise.frequency = 0.1  # Increased from 0.03
	
	# Temperature noise affects biome selection
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.seed = randi() + 200  # Different seeds
	temperature_noise.frequency = 0.08  # Increased from 0.02

func get_biome_at(x: int, y: int) -> int:
	# Get elevation, moisture and temperature values from noise
	var elevation = (noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var moisture = (moisture_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var temperature = (temperature_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	
	# More balanced biome distribution
	if elevation > 0.7:
		return BiomeType.MOUNTAINS
	elif temperature < 0.4:
		return BiomeType.SNOW
	elif moisture < 0.4 && temperature > 0.5:
		return BiomeType.DESERT
	else:
		return BiomeType.GRASSLAND

func generate_map():
	var map_size := Vector2i(15, 15)  # Larger map to see biome regions
	
	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile := TILE_SCENE.instantiate()
			add_child(tile)
			
			# Position the tile
			var pos_x := x * X_OFFSET * 0.75 
			var pos_z := y * Z_OFFSET
			
			if x % 2 == 1:
				pos_z += Z_OFFSET / 2
			
			# Determine the biome for this tile
			var biome_type = get_biome_at(x, y)
			var biome = BIOME_DATA[biome_type]
			
			# Set tile position and properties
			tile.position = Vector3(pos_x, biome.elevation, pos_z)
			tile.grid_position = Vector2i(x, y)
			tile.tile_type = biome.name.to_lower()
			tile.biome_color = biome.top_color
			tile.side_color = biome.side_color
			
			# Handle forest decoration
			if tile.has_node("ForestDeco"):
				var deco = tile.get_node("ForestDeco")
				if deco.has_method("set_color"):
					if randf() < biome.tree_chance:
						# Add trees with the biome's tree color
						deco.set_color(biome.tree_color)
					else:
						deco.queue_free()
