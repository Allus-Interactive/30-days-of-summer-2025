extends Control


@export var prev_scene: String


@onready var mute_button: Button = $CanvasLayer/HBoxContainer/VBoxContainer/MuteButton
@onready var back_button: Button = $CanvasLayer/HBoxContainer/VBoxContainer/BackButton


func _ready() -> void:
	back_button.grab_focus()
	set_mute_button_text()


func set_mute_button_text():
	if GameManager.is_muted:
		mute_button.text = "Unmute"
	else:
		mute_button.text = "Mute"


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(prev_scene)


func _on_mute_button_pressed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	GameManager.is_muted = !GameManager.is_muted
	AudioServer.set_bus_mute(bus_index, GameManager.is_muted)
	
	set_mute_button_text()
