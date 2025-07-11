extends Node2D


@export var prev_scene: String


@onready var back_button: Button = $CanvasLayer/BackButton


func _ready() -> void:
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(prev_scene)
