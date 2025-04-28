extends Node2D

# Tile type and position
@export var tile_type: String = "grass"
@export var grid_position: Vector2i

# Biome properties
var biome_data = null

# Visual representation
@onready var sprite = $Sprite2D
@onready var decoration = $Decoration

# Optional building reference
var building = null

# Biome to tileset frame mapping
const TILE_FRAMES = {
	"grassland": 2,  # Green tile
	"desert": 3,     # Orange/sand tile
	"snow": 5,       # Light blue/white tile
	"mountains": 0   # Gray tile
}

# Click detection
func _ready():
	# Set up input
	$Area2D.input_event.connect(_on_input_event)
	
	# Apply initial visual settings
	update_appearance()

func set_biome(new_biome_data):
	biome_data = new_biome_data
	tile_type = biome_data.name.to_lower()
	update_appearance()

func update_appearance():
	if not is_instance_valid(sprite) or not biome_data:
		return
	
	# Set the appropriate frame from the tileset based on tile type
	var frame = 0  # default frame
	if TILE_FRAMES.has(tile_type):
		frame = TILE_FRAMES[tile_type]
	
	if sprite is Sprite2D and sprite.hframes > 1:
		sprite.frame = frame
	
	# Apply slight tint variation based on biome color for more variety
	sprite.modulate = biome_data.top_color
	
	# Update decorations based on biome
	if decoration and biome_data.tree_chance > 0 and randf() < biome_data.tree_chance:
		decoration.visible = true
		decoration.modulate = biome_data.tree_color
	elif decoration:
		decoration.visible = false

func add_building(building_scene):
	# Remove any existing building
	if building:
		building.queue_free()
	
	# Add new building
	building = building_scene.instantiate()
	add_child(building)
	
	# Position building at center of hex
	building.position = Vector2.ZERO

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Handle tile selection
		select()

func select():
	# Visual feedback for selection
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Print selection info instead of calling a function that might not exist
	print("Tile selected: ", grid_position, " Type: ", tile_type)
	
	# Find the map generator parent to call its function
	var parent = get_parent()
	while parent and not parent.has_method("tile_selected"):
		parent = parent.get_parent()
	
	# If we found a parent with the method, call it
	if parent and parent.has_method("tile_selected"):
		parent.tile_selected(self)
