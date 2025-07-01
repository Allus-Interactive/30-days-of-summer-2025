extends Control


@export var next_scene: String


@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel


func _ready() -> void:
	GameManager.high_score = GameManager.load_high_score()
	if GameManager.high_score <= 0:
		high_score_label.visible = false
	high_score_label.text = "High Score: %d" % GameManager.high_score


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file.call_deferred(next_scene)
