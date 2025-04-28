extends Node

# Camera settings
var camera_sensitivity = 10.0  # Adjusted for 2D movement

# Screen properties
@onready var screen_size = get_viewport().get_visible_rect().size
@onready var screen_width = screen_size.x
@onready var screen_height = screen_size.y

# Hex grid constants
const HEX_SIZE = 64  # Size of hexagon in pixels
const HEX_WIDTH = HEX_SIZE * 2   # Width of a hex tile
const HEX_HEIGHT = HEX_SIZE * sqrt(3)  # Height of a hex tile
