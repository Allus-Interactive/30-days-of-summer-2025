extends Node2D


@export var game_scene: String
@export var settings_scene: String
@export var high_score_scene: String


@onready var start_button: Button = $CanvasLayer/VBoxContainer/StartButton


func _ready() -> void:
	start_button.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(game_scene)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(settings_scene)


func _on_high_score_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(high_score_scene)
