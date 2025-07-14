extends Area2D


enum State { RAW, COOKING, READY, BURNED }


var current_state = State.RAW
var flipped = false
var cooking_speed: float = 1
var initial_setup: bool = false

@export var food_data: FoodData

@onready var food: Area2D = $"."
@onready var cooking_timer: Timer = $CookingTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sizzle_sfx: AudioStreamPlayer2D = $SizzleSFX
@onready var player_anim_timer: Timer = $PlayerAnimTimer
@onready var food_anim_timer: Timer = $FoodAnimTimer
@onready var burned_timer: Timer = $BurnedTimer


func _ready() -> void:
	# initial loop to set up difficulty for food items
	#if not GameManager.food_data_setup:
		#set_difficulty_multiplier()
		#set_cooking_speed()
		#GameManager.food_data_setup = true
	
	set_food_to_raw()
	sizzle_sfx.play()
	GameManager.flip_the_food.connect(on_flip_food)


func set_difficulty_multiplier() -> void:
	match GameManager.difficulty_level:
		GameManager.Difficulty.easy:
			cooking_speed = 1.25
		GameManager.Difficulty.medium:
			cooking_speed = 1
		GameManager.Difficulty.hard:
			cooking_speed = 0.75
		_:
			cooking_speed = 1


func set_cooking_speed() -> void: 
	food_data.cooking_time = food_data.cooking_time * cooking_speed
	food_data.burned_time = food_data.burned_time * cooking_speed
	print(food_data.food_name + ": cooking time - " + str(food_data.cooking_time))


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
			burned_timer.start()
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
				GameManager.cooking_streak += 1
			else:
				flip_food_sprite()
				await get_tree().create_timer(0.2).timeout
				sizzle_sfx.play()
				flipped = true
				set_food_to_raw()
		elif current_state == State.BURNED:
			cooking_timer.stop()
			player_anim_timer.start()
			food_anim_timer.start()
			GameManager.cooking_streak = 0


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
	var tween = create_tween()
	tween.tween_property(food, "position", Vector2(global_position.x, 400), 0.25)


func _on_food_anim_timer_timeout() -> void:
	if current_state == State.READY:
		remove_food()
		get_tree().call_group("game", "add_score", 10)
	elif current_state == State.BURNED:
		remove_food()
		get_tree().call_group("game", "add_score", -5)


func _on_burned_timer_timeout() -> void:
	remove_food()
	get_tree().call_group("game", "add_score", -10)
