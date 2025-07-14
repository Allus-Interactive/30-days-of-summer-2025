extends Control


@export var game_scene: String


@onready var your_score_label: Label = $CanvasLayer/YourScoreLabel


func _ready() -> void:
	your_score_label.text = "Your Score: %d" % GameManager.current_score


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("replay"):
		get_tree().change_scene_to_file.call_deferred(game_scene)
