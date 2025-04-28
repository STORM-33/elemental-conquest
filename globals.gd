extends Node

# Camera settings
var camera_sensitivity = 1.0

# Screen properties
@onready var screen_size = get_viewport().get_visible_rect().size
@onready var screen_width = screen_size.x
@onready var screen_height = screen_size.y

# Hex grid constants - adjusted for 2D tiles
const HEX_SIZE = 64  # Size of hexagon in pixels (radius)
const HEX_WIDTH = 64  # Width of a hex tile (point-to-point)
const HEX_HEIGHT = 64  # Height of a hex tile (flat-to-flat)
