extends Node3D

const TILE_SCENE = preload("res://scenes/map_gen/hex_tile.tscn")
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
		"top_color": Color(0.13, 0.55, 0.13),  # Darker, more natural green
		"side_color": Color(0.08, 0.06, 0.04),  # Earthy brown for sides
		"tree_color": Color(0.1, 0.1, 0.1),
		"tree_chance": 0.7,
		"elevation": 0.0
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"top_color": Color(0.65, 0.55, 0.32),  # Further darkened, very muted yellow sand
		"side_color": Color(0.25, 0.2, 0.3),  # Sandy brown sides
		"tree_color": Color(0.1, 0.1, 0.1),
		"tree_chance": 0.2,
		"elevation": 0.0
	},
	BiomeType.SNOW: {
		"name": "Snow",
		"top_color": Color(0.6, 0.6, 0.8),  # Slightly grayer white
		"side_color": Color(0.3, 0.3, 0.4),  # Light blue-gray for snow sides
		"tree_color": Color(0.3, 0.3, 0.3),
		"tree_chance": 0.4,
		"elevation": 0.0
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"top_color": Color(0.2, 0.22, 0.22),  # Grayish brown for mountain tops
		"side_color": Color(0.1, 0.1, 0.1),  # Darker mountain sides
		"tree_color": Color(0.25, 0.2, 0.15),  # Darker trees
		"tree_chance": 0.3,
		"elevation": 0.0
	}
}

# Noise generators
var noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
var elevation_noise = FastNoiseLite.new()  # New noise for elevation relief
var biome_blend_noise = FastNoiseLite.new()  # For smoothing biome transitions

# Elevation parameters
@export var elevation_levels := 10  # Number of distinct elevation levels
@export var elevation_per_level := 0.07  # Height increase per elevation level
@export var elevation_noise_frequency := 0.1  # Controls how smooth or rough the elevation changes are

# Biome distribution parameters
@export var mountain_threshold := 0.75
@export var desert_temperature_threshold := 0.6
@export var snow_temperature_threshold := 0.35
@export var mountain_coverage := 0.2
@export var desert_coverage := 0.25
@export var snow_coverage := 0.25
@export var grassland_coverage := 0.3

# Distribution tracking
var biome_counts = {
	BiomeType.GRASSLAND: 0,
	BiomeType.DESERT: 0,
	BiomeType.SNOW: 0,
	BiomeType.MOUNTAINS: 0
}
var total_tiles = 0

func _ready():
	# Initialize noise generators
	setup_noise()
	
	# Print elevation parameters for debugging
	print("Elevation levels: ", elevation_levels)
	print("Elevation per level: ", elevation_per_level)
	print("Elevation noise frequency: ", elevation_noise_frequency)
	
	# Generate map with biomes and elevation
	generate_map()

func setup_noise():
	# Main terrain noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.08  # Lower frequency for broader patterns
	
	# Moisture noise affects biome selection
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	moisture_noise.seed = randi() + 100
	moisture_noise.frequency = 0.1  # Lower frequency for more coherent moisture regions
	
	# Temperature noise affects biome selection
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.seed = randi() + 200
	temperature_noise.frequency = 0.07  # Lower frequency for smoother temperature transitions
	
	# Adding fractal settings to temperature for more realistic patterns
	temperature_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	temperature_noise.fractal_octaves = 3
	temperature_noise.fractal_lacunarity = 2.0
	temperature_noise.fractal_gain = 0.5
	
	# Elevation noise for terrain relief
	elevation_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	elevation_noise.seed = randi() + 300
	elevation_noise.frequency = elevation_noise_frequency
	
	# Fractal settings for elevation
	elevation_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	elevation_noise.fractal_octaves = 4
	elevation_noise.fractal_lacunarity = 2.0
	elevation_noise.fractal_gain = 0.5
	
	# Biome blend noise for smoother transitions
	biome_blend_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	biome_blend_noise.seed = randi() + 400
	biome_blend_noise.frequency = 0.2
	
	# Fractal settings for biome blending
	biome_blend_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	biome_blend_noise.fractal_octaves = 2
	biome_blend_noise.fractal_lacunarity = 2.0
	biome_blend_noise.fractal_gain = 0.5

func get_biome_at(x: int, y: int) -> int:
	# Get base noise values
	var base_elevation = (noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var moisture = (moisture_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var base_temperature = (temperature_noise.get_noise_2d(x, y) + 1) * 0.5  # 0 to 1
	var blend_factor = (biome_blend_noise.get_noise_2d(x, y) + 1) * 0.5  # For biome blending
	
	# Apply temperature-elevation relationship (higher = colder)
	# Adjust temperature based on elevation with a smooth curve
	var elevation_temp_factor = 0.4 * pow(base_elevation, 1.5)  # Stronger effect at higher elevations
	var temperature = max(0.0, base_temperature - elevation_temp_factor)
	
	# Add distance from equator effect (assuming y=0 is equator)
	var map_size = 15.0  # Estimated from generate_map function
	var distance_from_equator = abs((y - map_size/2) / (map_size/2))  # 0 at equator, 1 at poles
	temperature -= 0.2 * distance_from_equator  # Colder at poles
	temperature = clamp(temperature, 0.0, 1.0)  # Keep in range
	
	# Use Whittaker-inspired biome calculation with soft thresholds
	
	# Mountain score - higher elevation and lower moisture increases chance
	var mountain_score = base_elevation * 0.8 + (1.0 - moisture) * 0.2 + blend_factor * 0.1
	
	# Desert score - higher temperature and lower moisture increases chance
	var desert_score = temperature * 0.6 + (1.0 - moisture) * 0.4 + blend_factor * 0.1
	
	# Snow score - lower temperature and higher elevation increases chance
	var snow_score = (1.0 - temperature) * 0.7 + base_elevation * 0.3 + blend_factor * 0.1
	
	# Grassland score - higher moisture and moderate temperature increases chance
	var temp_factor = 1.0 - abs(temperature - 0.5) * 2.0  # Peaks at temperature 0.5
	var grassland_score = moisture * 0.6 + temp_factor * 0.4 + blend_factor * 0.1
	
	# Apply some noise to the scores for more variation
	mountain_score += biome_blend_noise.get_noise_2d(x + 50, y + 50) * 0.1
	desert_score += biome_blend_noise.get_noise_2d(x + 100, y + 100) * 0.1
	snow_score += biome_blend_noise.get_noise_2d(x + 150, y + 150) * 0.1
	grassland_score += biome_blend_noise.get_noise_2d(x + 200, y + 200) * 0.1
	
	# Dynamic thresholds based on target coverage and current counts
	var mountain_threshold = mountain_coverage * (1.0 + float(biome_counts[BiomeType.MOUNTAINS]) / max(1, total_tiles))
	var desert_threshold = desert_coverage * (1.0 + float(biome_counts[BiomeType.DESERT]) / max(1, total_tiles))
	var snow_threshold = snow_coverage * (1.0 + float(biome_counts[BiomeType.SNOW]) / max(1, total_tiles))
	
	# Decide biome based on highest score, with dynamic adjustment based on coverage goals
	var scores = [
		{"biome": BiomeType.MOUNTAINS, "score": mountain_score, "threshold": mountain_threshold},
		{"biome": BiomeType.DESERT, "score": desert_score, "threshold": desert_threshold},
		{"biome": BiomeType.SNOW, "score": snow_score, "threshold": snow_threshold},
		{"biome": BiomeType.GRASSLAND, "score": grassland_score, "threshold": grassland_coverage}
	]
	
	# Sort scores from highest to lowest
	scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Select biome with highest score, but apply dynamic thresholds to maintain balance
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

func get_elevation_at(x: int, y: int) -> float:
	# Get elevation noise value between -1 and 1
	var noise_value = elevation_noise.get_noise_2d(x, y)
	
	# Use the full range by enhancing contrast
	var normalized_value = (noise_value + 1) * 0.5
	
	# Apply a curve to the normalized value for better distribution
	normalized_value = pow(normalized_value, 0.8)
	
	# Force the range to stay within bounds
	normalized_value = clamp(normalized_value, 0.0, 0.999)
	
	# Convert to discrete levels
	var level = floor(normalized_value * elevation_levels)
	
	# Debug print for first tile only
	if x == 0 && y == 0:
		print("Noise value: ", noise_value, " Normalized: ", normalized_value, " Level: ", level)
	
	# Calculate final elevation based on level
	return level * elevation_per_level

func generate_map():
	var map_size := Vector2i(15, 15)
	var elevation_counts = []
	
	# Initialize counter arrays
	for i in range(elevation_levels):
		elevation_counts.append(0)
	
	# First pass: count total tiles
	total_tiles = map_size.x * map_size.y
	
	# Second pass: generate actual tiles
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
			
			# Count biome for tracking distribution
			biome_counts[biome_type] += 1
			
			# Get terrain elevation
			var terrain_elevation = get_elevation_at(x, y)
			
			# Count elevation level for debugging
			var level = int(terrain_elevation / elevation_per_level)
			if level >= 0 && level < elevation_levels:
				elevation_counts[level] += 1
			
			# Apply biome-specific elevation adjustments
			var final_elevation = biome.elevation + terrain_elevation
			
			if biome_type == BiomeType.MOUNTAINS:
				# Mountains get extra elevation
				final_elevation += elevation_per_level * 1.5
			elif biome_type == BiomeType.DESERT:
				# Deserts can have dunes (slight variations)
				final_elevation += sin(x * 0.5 + y * 0.7) * 0.02
			elif biome_type == BiomeType.SNOW:
				# Snow areas can have slight height variation
				final_elevation += elevation_per_level * 0.5
			
			# Set tile position and properties
			tile.position = Vector3(pos_x, final_elevation, pos_z)
			tile.grid_position = Vector2i(x, y)
			tile.tile_type = biome.name.to_lower()
			tile.biome_color = biome.top_color
			tile.side_color = biome.side_color
					
			# Handle forest decoration
			if tile.has_node("ForestDeco"):
				var deco = tile.get_node("ForestDeco")
				if deco.has_method("set_color"):
					# Adjust tree chance based on biome and location for more natural forests
					var tree_chance = biome.tree_chance
					
					# More trees in areas with higher moisture (except mountains)
					if biome_type != BiomeType.MOUNTAINS:
						var moisture = (moisture_noise.get_noise_2d(x, y) + 1) * 0.5
						tree_chance *= (0.7 + moisture * 0.6)
					
					# Fewer trees at high elevations
					tree_chance *= (1.0 - terrain_elevation * 0.5)
					
					# No trees in very high mountains
					if biome_type == BiomeType.MOUNTAINS && terrain_elevation > 0.5:
						tree_chance *= 0.3
					
					if randf() < tree_chance:
						# Add trees with the biome's tree color
						deco.set_color(biome.tree_color)
					else:
						deco.queue_free()
	
	# Print biome distribution statistics
	print("Biome Distribution:")
	for biome_type in BiomeType.values():
		var biome_name = BIOME_DATA[biome_type].name
		var count = biome_counts[biome_type]
		var percentage = (float(count) / total_tiles) * 100
		print("%s: %d tiles (%.1f%%)" % [biome_name, count, percentage])
		
	# Print elevation distribution
	print("Elevation distribution:")
	for i in range(elevation_levels):
		print("Level ", i, ": ", elevation_counts[i], " tiles")
