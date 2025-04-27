extends Control
@onready var vBox = $VBoxContainer
func _ready():
	$VBoxContainer/StartButton.pressed.connect(startButtonPressed)
	$VBoxContainer/SettingsButton.pressed.connect(settingsButtonPressed)
	vBox.anchor_top = 0
	vBox.anchor_bottom = 1
	vBox.anchor_left = 0.5
	vBox.anchor_right = 0.5
	vBox.offset_left = -Globals.screen_width/4
	vBox.offset_right = Globals.screen_width/4
	
func startButtonPressed():
	get_tree().change_scene_to_file("res://scenes/map_gen/map_gen.tscn")

func settingsButtonPressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/settings.tscn")
