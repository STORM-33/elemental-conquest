extends Control

@onready var camSens_slider = $VBoxContainer/HBoxContainer/CameraSensitivitySlider
@onready var camSens_label = $VBoxContainer/HBoxContainer/Label
@onready var vBox = $VBoxContainer
func _ready():
	vBox.anchor_top = 0
	vBox.anchor_bottom = 1
	vBox.anchor_left = 0.5
	vBox.anchor_right = 0.5
	vBox.offset_left = -Globals.screen_width/4
	vBox.offset_right = Globals.screen_width/4
	
	camSens_slider.min_value = 0.01
	camSens_slider.max_value = 2
	camSens_slider.step = 0.01
	camSens_slider.value = Globals.camera_sensitivity
	
	camSens_slider.value_changed.connect(camSens_changed)
	camSens_label.text = str(camSens_slider.value)
	$VBoxContainer/BackButton.pressed.connect(backButtonPressed)
func backButtonPressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
func camSens_changed(value):
	Globals.camera_sensitivity = value
	camSens_label.text = str(value)
