extends Node2D


@export var prev_scene: String


@onready var local_leaderboard_container: VBoxContainer = $CanvasLayer/HBoxContainer/LocalLeaderboardContainer
@onready var back_button: Button = $CanvasLayer/BackButton


func _ready() -> void:
	back_button.grab_focus()
	GameManager.load_local_leaderboard()
	var label = Label.new()
	label.theme = preload("res://assets/themes/leaderboard.tres")
	for i in GameManager.leaderboard["scores"].size():
		var entry = GameManager.leaderboard["scores"][i]
		label.text += str(i + 1) + ": " + entry["name"] + " - " + str(entry["score"]) + "\n"
		local_leaderboard_container.add_child(label)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(prev_scene)
