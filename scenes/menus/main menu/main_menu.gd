extends Control


@export var game_scene: String
@export var options_scene: String

@onready var start_button: Button = $CanvasLayer/VBoxContainer/StartButton
@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel


func _ready() -> void:
	start_button.grab_focus()
	
	GameManager.high_score = GameManager.load_high_score()
	if GameManager.high_score <= 0:
		high_score_label.visible = false
	high_score_label.text = "High Score: %d" % GameManager.high_score


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(game_scene)


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(options_scene)
