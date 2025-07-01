extends Node2D


var current_position: Vector2
var max_left_pos: float = 180.0
var max_right_pos: float = 780.0
var move_gap: float = 150.0


func _ready() -> void:
	# start position of (480, 400)
	current_position = global_position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		if current_position.x > max_left_pos:
			global_position = Vector2(current_position.x - move_gap, 400)
			current_position = global_position
	if Input.is_action_just_pressed("move_right"):
		if current_position.x < max_right_pos:
			global_position = Vector2(current_position.x + move_gap, 400)
			current_position = global_position
