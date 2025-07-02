extends Control


var success_msg: String = "New High Score!"
var failure_msg: String = "Try Again!"


@export var game_scene: String


@onready var your_score_label: Label = $CanvasLayer/YourScoreLabel
@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel
@onready var message_label: Label = $CanvasLayer/MessageLabel


func _ready() -> void:
	your_score_label.text = "Your Score: %d" % GameManager.current_score
	high_score_label.text = "High Score: %d" % GameManager.high_score
	
	if GameManager.current_score == GameManager.high_score:
		message_label.text = success_msg
	else:
		message_label.text = failure_msg


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file.call_deferred(game_scene)
