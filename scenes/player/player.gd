extends Node2D


var current_position: Vector2
var max_left_pos: float = 180.0
var max_right_pos: float = 780.0
var move_gap: float = 150.0
var player_y: float = 400.0
var food_y: float = 270.0
var is_animating: bool = false


@onready var player: Node2D = $"."
@onready var animation_timer: Timer = $AnimationTimer


func _ready() -> void:
	# start position of (480, 400)
	current_position = global_position


func _process(delta: float) -> void:
	if is_animating:
		return
	
	if Input.is_action_just_pressed("move_left"):
		if current_position.x > max_left_pos:
			global_position = Vector2(current_position.x - move_gap, 400)
			current_position = global_position
	if Input.is_action_just_pressed("move_right"):
		if current_position.x < max_right_pos:
			global_position = Vector2(current_position.x + move_gap, 400)
			current_position = global_position
	if Input.is_action_just_pressed("flip"):
		var tween = create_tween()
		is_animating = true
		animation_timer.start()
		tween.tween_property(player, "position", Vector2(global_position.x, food_y), 0.25)
		GameManager.emit_signal("flip_the_food", global_position.x)
		tween.tween_property(player, "position", Vector2(global_position.x, player_y), 0.25)


func _on_animation_timer_timeout() -> void:
	is_animating = false
