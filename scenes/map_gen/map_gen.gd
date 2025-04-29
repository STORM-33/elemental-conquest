extends Node2D

# Tile Assets paths
const TILESET_PATH = "res://assets/sprites/tileset_hex.png"
const BUILDINGS_TILESET_PATH = "res://assets/sprites/tileset_buildings.png"

# Layer indices
const TERRAIN_LAYER = 0
const DECORATION_LAYER = 1

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
		"tree_chance": 0.7,
		"atlas_coords": Vector2i(0, 2)
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"tree_chance": 0.2,
		"atlas_coords": Vector2i(0, 3)
	},
	BiomeType.SNOW: {
		"name": "Snow",
		"tree_chance": 0.4,
		"atlas_coords": Vector2i(0, 5)
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"tree_chance": 0.3,
		"atlas_coords": Vector2i(0, 6)
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

# Store tile data in dictionaries since we can't use custom data layers directly
var tile_biome_data = {}  # Format: "x,y" -> BiomeType
var tile_forest_data = {} # Format: "x,y" -> Boolean

# Current selected cell
var selected_coords = null

@onready var tile_map = $TileMapContainer/TileMap

func _ready():
	# DEBUG: Check if TileSet is valid
	if tile_map.tile_set == null:
		print("ERROR: TileSet is null!")
	else:
		print("TileSet is valid")
		
	# Check if the source exists in the TileSet
	if tile_map.tile_set != null:
		var source_count = tile_map.tile_set.get_source_count()
		print("TileSet has ", source_count, " sources")
		
		if source_count > 0:
			for i in range(source_count):
				var source_id = tile_map.tile_set.get_source_id(i)
				print("Source ID: ", source_id)
	
	# Make sure the decoration layer is properly set up
	ensure_decoration_layer_setup()
	
	setup_noise()
	generate_map()
	print("Map generation complete. Tile count: ", total_tiles)
	
	
func ensure_decoration_layer_setup():
	# Try multiple approaches to enable proper rendering
	
	# 1. Direct layer property access
	if tile_map.get_layers_count() > 1:
		# Make sure the decoration layer exists and is enabled
		tile_map.set_layer_enabled(DECORATION_LAYER, true)
		
		# Try different ways to set z-index
		# Method 1 - standard method
		tile_map.set_layer_z_index(DECORATION_LAYER, 10)
		
		# Method 2 - direct layered tile map access if available
		if tile_map.has_method("set_layer_z_index"):
			tile_map.call("set_layer_z_index", DECORATION_LAYER, 10)
		
		# Ensure modulate is set to fully visible
		tile_map.set_layer_modulate(DECORATION_LAYER, Color(1, 1, 1, 1))
		
		# Print layer properties
		print("Layer count:", tile_map.get_layers_count())
		print("Decoration layer enabled:", tile_map.is_layer_enabled(DECORATION_LAYER))
		print("Decoration layer z-index:", tile_map.get_layer_z_index(DECORATION_LAYER))
	else:
		print("ERROR: Not enough layers in TileMap!")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Convert mouse position to map coordinates
		var mouse_pos = get_global_mouse_position()
		var map_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))
		
		# Check if map_pos is valid
		if map_pos.x >= 0 and map_pos.x < map_size.x and map_pos.y >= 0 and map_pos.y < map_size.y:
			tile_selected(map_pos)

func setup_noise():
	# Main terrain noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.08
	
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
	var base_elevation = (noise.get_noise_2d(x, y) + 1) * 0.5
	var moisture = (moisture_noise.get_noise_2d(x, y) + 1) * 0.5
	var base_temperature = (temperature_noise.get_noise_2d(x, y) + 1) * 0.5
	var blend_factor = (biome_blend_noise.get_noise_2d(x, y) + 1) * 0.5
	
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
	# Clear the TileMap layers
	tile_map.clear_layer(TERRAIN_LAYER)
	tile_map.clear_layer(DECORATION_LAYER)
	
	# Reset biome counts
	for biome in BiomeType.values():
		biome_counts[biome] = 0
	
	# Calculate total tiles
	total_tiles = map_size.x * map_size.y
	
	# Debug counters
	var total_trees_placed = 0
	
	# Generate map using TileMap
	for y in range(map_size.y):
		for x in range(map_size.x):
			# Determine biome and set properties
			var biome_type = get_biome_at(x, y)
			var biome = BIOME_DATA[biome_type]
			biome_counts[biome_type] += 1
			
			# Store biome type in our dictionary
			var key = "%d,%d" % [x, y]
			tile_biome_data[key] = biome_type
			
			# Set the base terrain tile
			tile_map.set_cell(TERRAIN_LAYER, Vector2i(x, y), 0, biome.atlas_coords)
			
			# TREE GENERATION - only on certain coordinates for testing
			var should_place_tree = false
			
			# Place trees in a very visible pattern for testing
			if (x + y) % 2 == 0:
				should_place_tree = true
			
			# Store tree info
			tile_forest_data[key] = should_place_tree
			
			# Place trees using multiple methods to see which works
			if should_place_tree:
				# Try multiple tiles from the building atlas to see which ones work
				var tree_placed = false
				
				# Method 1: Try coordinate (0, 2) from source 1 (buildings)
				tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(0, 2))
				tree_placed = true
				
				# If in specific test region, try different tiles on different coordinates
				if x < 5 and y < 5:
					if x == 0 and y == 0:
						# Try (0, 3) from source 1
						tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(0, 3))
					elif x == 1 and y == 0:
						# Try (1, 3) from source 1
						tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(1, 3))
					elif x == 2 and y == 0:
						# Try (2, 3) from source 1
						tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(2, 3))
					elif x == 3 and y == 0:
						# Try (0, 4) from source 1
						tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(0, 4))
					elif x == 4 and y == 0:
						# Try (1, 4) from source 1
						tile_map.set_cell(DECORATION_LAYER, Vector2i(x, y), 1, Vector2i(1, 4))
				
				if tree_placed:
					total_trees_placed += 1
					
					# Debug output for specific tiles
					if x < 5 and y < 5:
						print("Placed tree at (", x, ",", y, ") using source 1")
	
	# Print tree generation statistics
	print("Total trees placed: ", total_trees_placed)
	print("Tree placement percentage: ", (float(total_trees_placed) / total_tiles) * 100, "%")
	
	# DEBUG: Check if any tiles were set in the decoration layer
	var decorated_cells = tile_map.get_used_cells(DECORATION_LAYER)
	print("Decoration layer has", decorated_cells.size(), "cells with tiles")
	if decorated_cells.size() > 0:
		print("First few decoration coordinates:")
		for i in range(min(5, decorated_cells.size())):
			var cell = decorated_cells[i]
			var tile_data = tile_map.get_cell_tile_data(DECORATION_LAYER, cell)
			var source_id = tile_map.get_cell_source_id(DECORATION_LAYER, cell)
			var atlas_coords = tile_map.get_cell_atlas_coords(DECORATION_LAYER, cell)
			print("  Cell", i, "at", cell, "- Source:", source_id, "Atlas:", atlas_coords, "Has data:", tile_data != null)
	
	# Position camera to see the whole map
	$Camera2D.position = tile_map.map_to_local(Vector2i(map_size.x / 2, map_size.y / 2))

func tile_selected(cell_coords):
	# Store selected coordinates
	selected_coords = cell_coords
	
	# Get biome type from our dictionary
	var key = "%d,%d" % [cell_coords.x, cell_coords.y]
	var biome_type = tile_biome_data.get(key, BiomeType.GRASSLAND) # Default to grassland if not found
	var has_forest = tile_forest_data.get(key, false)
	
	# Visual feedback for selection (could add a highlight tile later)
	print("Tile selected: ", cell_coords, " Biome Type: ", BIOME_DATA[biome_type].name)
	
	# Show UI info panel
	if has_node("UI/TileInfo"):
		var info_panel = get_node("UI/TileInfo")
		info_panel.visible = true
		if info_panel.has_node("BiomeLabel"):
			info_panel.get_node("BiomeLabel").text = "Biome: " + BIOME_DATA[biome_type].name
		if info_panel.has_node("CoordLabel"):
			info_panel.get_node("CoordLabel").text = "Coord: " + str(cell_coords)
		if info_panel.has_node("ForestLabel"):
			info_panel.get_node("ForestLabel").text = "Forest: " + ("Yes" if has_forest else "No")
