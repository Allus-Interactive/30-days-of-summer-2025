extends Area2D


enum State { RAW, COOKING, READY, BURNED }

# var cook_time: float = randf_range(1.5, 3.0)
# var burn_time: float = randf_range(3.25, 4.0)
var current_state = State.RAW
# var flipped = false

@export var food_data: FoodData

# @onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# @onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooking_timer: Timer = $CookingTimer
@onready var sprite_2d: Sprite2D = $Sprite2D



func _ready() -> void:
	cooking_timer.wait_time = food_data.cooking_time
	cooking_timer.start()
	# animated_sprite_2d.play("raw")
	sprite_2d.texture = food_data.texture_raw


func _on_cooking_timer_timeout() -> void:
	match current_state:
		State.RAW:
			current_state = State.READY
			# animated_sprite_2d.play("cooked")
			# animation_player.play("to_cooked")
			sprite_2d.texture = food_data.texture_cooked
			cooking_timer.wait_time = food_data.burned_time - food_data.cooking_time
			cooking_timer.start()
		State.READY:
			current_state = State.BURNED
			# animated_sprite_2d.play("burned")
			# animation_player.play("to_cooked")
			sprite_2d.texture = food_data.texture_burned
		_:
			pass


func remove_food():
	var slot = get_meta("grill_slot")
	if slot:
		slot.occupied = false
	queue_free()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if current_state == State.READY:
			remove_food()
			get_tree().call_group("game", "add_score", 10)
		elif current_state == State.BURNED:
			remove_food()
			get_tree().call_group("game", "add_score", -5)
