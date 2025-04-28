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
	"grassland": 0,  # Green tile
	"desert": 0,     # Orange/sand tile
	"snow": 0,       # Light blue/white tile
	"mountains": 0   # Gray tile
}

# Click detection
func _ready():
	# Set up input
	$Area2D.input_event.connect(_on_input_event)
	
	# Make label visible for debugging
	if has_node("Label"):
		$Label.visible = true
	
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
	
	# Important: Force the frame to update
	if sprite is Sprite2D:
		sprite.frame = frame
		
		# Verify the frame was set correctly
		print("Tile at ", grid_position, " set to frame: ", sprite.frame, " for biome: ", tile_type)
	
	# Apply slight tint variation based on biome color
	sprite.modulate = biome_data.top_color
	
	# Update decorations based on biome
	if decoration and decoration.has_node("TreeSprite"):
		var tree_sprite = decoration.get_node("TreeSprite")
		if biome_data.tree_chance > 0 and randf() < biome_data.tree_chance:
			decoration.visible = true
			tree_sprite.modulate = biome_data.tree_color
		else:
			decoration.visible = false

func add_building(building_scene):
	# Remove any existing building
	if building:
		building.queue_free()
	
	# Add new building
	building = building_scene
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
	
	# Print selection info
	print("Tile selected: ", grid_position, " Type: ", tile_type)
	
	# Try to find the direct ancestor with the tile_selected method
	var current = self
	while current:
		current = current.get_parent()
		if current and current.has_method("tile_selected"):
			current.tile_selected(self)
		return
	
	# If we get here, we didn't find a parent with tile_selected
	print("Warning: Could not find parent with tile_selected method")
