extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(startButtonPressed)
	$VBoxContainer/SettingsButton.pressed.connect(settingsButtonPressed)

func startButtonPressed():
	get_tree().change_scene_to_file("res://scenes/map_gen/map_gen.tscn")

func settingsButtonPressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/settings.tscn")
