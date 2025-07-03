extends Control


@export var prev_scene: String


@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel
@onready var back_button: Button = $CanvasLayer/BackButton


func _ready() -> void:
	back_button.grab_focus()
	
	GameManager.high_score = GameManager.load_high_score()
	if GameManager.high_score <= 0:
		high_score_label.visible = false
	high_score_label.text = "Your High Score: %d" % GameManager.high_score


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(prev_scene)
