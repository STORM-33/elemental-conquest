extends Node2D

const TILE_SCENE = preload("res://scenes/map_gen/hex_tile.tscn")

# Tile Assets
const TILESET_PATH = "res://assets/sprites/tileset_hex.png"
const BUILDINGS_TILESET_PATH = "res://assets/sprites/tileset_buildings.png"

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
		"top_color": Color(0.13, 0.55, 0.13),  # Darker, more natural green
		"tree_color": Color(0.1, 0.4, 0.1),
		"tree_chance": 0.7
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"top_color": Color(0.65, 0.55, 0.32),  # Further darkened, very muted yellow sand
		"tree_color": Color(0.35, 0.25, 0.1),
		"tree_chance": 0.2
	},
	BiomeType.SNOW: {
		"name": "Snow",
		"top_color": Color(0.6, 0.6, 0.8),  # Slightly grayer white
		"tree_color": Color(0.3, 0.3, 0.3),
		"tree_chance": 0.4
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"top_color": Color(0.2, 0.22, 0.22),  # Grayish brown for mountain tops
		"tree_color": Color(0.25, 0.2, 0.15),  # Darker trees
		"tree_chance": 0.3
	}
}

# Noise generators for procedural generation
var noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
var biome_blend_noise = FastNoiseLite.new()

# Map properties
@export var map_size: Vector2i = Vector2i(15, 15)

# Distribution tracking
var biome_counts = {
	BiomeType.GRASSLAND: 0,
	BiomeType.DESERT: 0,
	BiomeType.SNOW: 0,
	BiomeType.MOUNTAINS: 0
}
var total_tiles = 0

# Biome coverage goals
@export var mountain_coverage := 0.2
@export var desert_coverage := 0.25
@export var snow_coverage := 0.25
@export var grassland_coverage := 0.3

# Tile grid storage
var tile_grid = {}
var selected_tile = null

func _ready():
	# Initialize noise generators
	setup_noise()
	
	# Generate the map
	generate_map()
	
	# Debug output
	print("Map generation complete. Tile count: ", total_tiles)

func setup_noise():
	# Main terrain noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.08  # Lower frequency for broader patterns
	
	# Moisture noise affects biome selection
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	moisture_noise.seed = randi() + 100
	moisture_noise.frequency = 0.1
	
	# Temperature noise affects biome selection
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.seed = randi() + 200
	temperature_noise.frequency = 0.07
	
	# Fractal settings for temperature
	temperature_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	temperature_noise.fractal_octaves = 3
	temperature_noise.fractal_lacunarity = 2.0
	temperature_noise.fractal_gain = 0.5
	
	# Biome blend noise for smoother transitions
	biome_blend_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	biome_blend_noise.seed = randi() + 400
	biome_blend_noise.frequency = 0.2

func get_biome_at(x: int, y: int) -> int:
	# Get base noise values
	var base_elevation = (noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var moisture = (moisture_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var base_temperature = (temperature_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var blend_factor = (biome_blend_noise.get_noise_2d(x, y) + 1) * 0.5  # For biome blending
	
	# Apply temperature-elevation relationship (higher = colder)
	var elevation_temp_factor = 0.4 * pow(base_elevation, 1.5)
	var temperature = max(0.0, base_temperature - elevation_temp_factor)
	
	# Add distance from equator effect
	var distance_from_equator = abs((y - map_size.y/2) / (map_size.y/2))
	temperature -= 0.2 * distance_from_equator
	temperature = clamp(temperature, 0.0, 1.0)
	
	# Calculate biome scores
	var mountain_score = base_elevation * 0.8 + (1.0 - moisture) * 0.2 + blend_factor * 0.1
	var desert_score = temperature * 0.6 + (1.0 - moisture) * 0.4 + blend_factor * 0.1
	var snow_score = (1.0 - temperature) * 0.7 + base_elevation * 0.3 + blend_factor * 0.1
	var temp_factor = 1.0 - abs(temperature - 0.5) * 2.0
	var grassland_score = moisture * 0.6 + temp_factor * 0.4 + blend_factor * 0.1
	
	# Apply some noise to scores
	mountain_score += biome_blend_noise.get_noise_2d(x + 50, y + 50) * 0.1
	desert_score += biome_blend_noise.get_noise_2d(x + 100, y + 100) * 0.1
	snow_score += biome_blend_noise.get_noise_2d(x + 150, y + 150) * 0.1
	grassland_score += biome_blend_noise.get_noise_2d(x + 200, y + 200) * 0.1
	
	# Dynamic thresholds based on target coverage
	var mountain_threshold = mountain_coverage * (1.0 + float(biome_counts[BiomeType.MOUNTAINS]) / max(1, total_tiles))
	var desert_threshold = desert_coverage * (1.0 + float(biome_counts[BiomeType.DESERT]) / max(1, total_tiles))
	var snow_threshold = snow_coverage * (1.0 + float(biome_counts[BiomeType.SNOW]) / max(1, total_tiles))
	
	# Score-based biome selection with dynamic adjustment
	var scores = [
		{"biome": BiomeType.MOUNTAINS, "score": mountain_score, "threshold": mountain_threshold},
		{"biome": BiomeType.DESERT, "score": desert_score, "threshold": desert_threshold},
		{"biome": BiomeType.SNOW, "score": snow_score, "threshold": snow_threshold},
		{"biome": BiomeType.GRASSLAND, "score": grassland_score, "threshold": grassland_coverage}
	]
	
	# Sort scores from highest to lowest
	scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Select biome with highest score but apply dynamic thresholds
	for score_data in scores:
		var biome_type = score_data.biome
		var target_ratio = 0
		
		match biome_type:
			BiomeType.MOUNTAINS: target_ratio = mountain_coverage
			BiomeType.DESERT: target_ratio = desert_coverage
			BiomeType.SNOW: target_ratio = snow_coverage
			BiomeType.GRASSLAND: target_ratio = grassland_coverage
		
		var current_ratio = float(biome_counts[biome_type]) / max(1, total_tiles)
		
		# If this biome is underrepresented, choose it
		if current_ratio < target_ratio * 1.1 or biome_type == BiomeType.GRASSLAND:
			return biome_type
	
	# Fallback to grassland
	return BiomeType.GRASSLAND

func generate_map():
	# Clear any existing tiles
	if $TileContainer:
		for child in $TileContainer.get_children():
			child.queue_free()
	else:
		var tile_container = Node2D.new()
		tile_container.name = "TileContainer"
		add_child(tile_container)
	
	# Reset biome counts
	for biome in BiomeType.values():
		biome_counts[biome] = 0
	
	# Calculate total tiles
	total_tiles = map_size.x * map_size.y
	
	# Hex grid dimensions
	var hex_width = 36  # Fixed width between centers
	var hex_height = 32  # Fixed height between centers
	
	# Offset to center the map
	var start_x = 50
	var start_y = 50
	
	# Generate tiles
	for y in range(map_size.y):
		for x in range(map_size.x):
			# Create tile instance
			var tile = TILE_SCENE.instantiate()
			$TileContainer.add_child(tile)
			
			# Calculate position with offset for odd rows
			var pos_x = start_x + x * hex_width
			var pos_y = start_y + y * hex_height
			
			# Offset odd rows
			if y % 2 == 1:
				pos_x += hex_width / 2
			
			tile.position = Vector2(pos_x, pos_y)
			tile.grid_position = Vector2i(x, y)
			
			# Store in grid
			if not tile_grid.has(y):
				tile_grid[y] = {}
			tile_grid[y][x] = tile
			
			# Determine biome and set properties
			var biome_type = get_biome_at(x, y)
			var biome = BIOME_DATA[biome_type]
			biome_counts[biome_type] += 1
			tile.set_biome(biome)
			
			# Show coordinates for debugging
			if tile.has_node("Label"):
				var label = tile.get_node("Label")
				label.visible = false  # Set to true for debugging
				label.text = str(x) + "," + str(y)
	
	# Position camera to see the whole map
	var map_width = map_size.x * hex_width
	var map_height = map_size.y * hex_height
	$Camera2D.position = Vector2(start_x + map_width/2, start_y + map_height/2)
	
	# Print biome distribution statistics
	print("Biome Distribution:")
	for biome_type in BiomeType.values():
		var biome_name = BIOME_DATA[biome_type].name
		var count = biome_counts[biome_type]
		var percentage = (float(count) / total_tiles) * 100
		print("%s: %d tiles (%.1f%%)" % [biome_name, count, percentage])

func tile_selected(tile):
	# Handle tile selection
	if selected_tile:
		# Deselect previous tile if needed
		pass
	
	selected_tile = tile
	print("Tile selected: ", tile.grid_position, " Type: ", tile.tile_type)
	
	# Show UI info panel
	if has_node("UI/TileInfo"):
		var info_panel = get_node("UI/TileInfo")
		info_panel.visible = true
		if info_panel.has_node("BiomeLabel"):
			info_panel.get_node("BiomeLabel").text = "Biome: " + tile.tile_type.capitalize()
		if info_panel.has_node("CoordLabel"):
			info_panel.get_node("CoordLabel").text = "Coord: " + str(tile.grid_position)
