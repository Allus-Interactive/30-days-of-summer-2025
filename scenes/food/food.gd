extends Area2D


enum State { RAW, COOKING, READY, BURNED }


var current_state = State.RAW
var flipped = false

@export var food_data: FoodData

@onready var food: Area2D = $"."
@onready var cooking_timer: Timer = $CookingTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sizzle_sfx: AudioStreamPlayer2D = $SizzleSFX
@onready var player_anim_timer: Timer = $PlayerAnimTimer
@onready var food_anim_timer: Timer = $FoodAnimTimer


func _ready() -> void:
	set_food_to_raw()
	# sizzle_sfx.play()
	GameManager.flip_the_food.connect(on_flip_food)


func _on_cooking_timer_timeout() -> void:
	match current_state:
		State.RAW:
			current_state = State.READY
			sprite_2d.texture = food_data.texture_cooked
			cooking_timer.wait_time = food_data.burned_time - food_data.cooking_time
			cooking_timer.start()
		State.READY:
			current_state = State.BURNED
			sprite_2d.texture = food_data.texture_burned
		_:
			pass


func set_food_to_raw():
	current_state = State.RAW
	cooking_timer.wait_time = food_data.cooking_time
	cooking_timer.start()
	sprite_2d.texture = food_data.texture_raw


func remove_food():
	var slot = get_meta("grill_slot")
	if slot:
		slot.occupied = false
	queue_free()


func on_flip_food(player_position: float) -> void:
	if global_position.x == player_position:
		if current_state == State.READY:
			if flipped:
				cooking_timer.stop()
				player_anim_timer.start()
				food_anim_timer.start()
			else:
				flip_food_sprite()
				await get_tree().create_timer(0.2).timeout
				flipped = true
				set_food_to_raw()
		elif current_state == State.BURNED:
			cooking_timer.stop()
			player_anim_timer.start()
			food_anim_timer.start()


func flip_food_sprite() -> void:
	var tween = create_tween()
	
	# Scale X to 0 (disappear)
	tween.tween_property(sprite_2d, "scale:x", 0.0, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	# Scale X back to 1 (reappear)
	tween.tween_property(sprite_2d, "scale:x", 1.0, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


func _on_player_anim_timer_timeout() -> void:
	print("player anim timer timeout")
	var tween = create_tween()
	tween.tween_property(food, "position", Vector2(global_position.x, 400), 0.25)


func _on_food_anim_timer_timeout() -> void:
	print("food anim timer timeout")
	if current_state == State.READY:
		remove_food()
		get_tree().call_group("game", "add_score", 10)
	elif current_state == State.BURNED:
		remove_food()
		get_tree().call_group("game", "add_score", -5)
