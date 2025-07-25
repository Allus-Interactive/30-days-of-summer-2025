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
@onready var burned_timer: Timer = $BurnedTimer
@onready var steam_particles: GPUParticles2D = $SteamParticles
@onready var burned_particles: GPUParticles2D = $BurnedParticles


func _ready() -> void:	
	set_food_to_raw()
	sizzle_sfx.play()
	GameManager.flip_the_food.connect(on_flip_food)


func _on_cooking_timer_timeout() -> void:
	match current_state:
		State.RAW:
			current_state = State.READY
			steam_burst(State.READY)
			cooking_timer.wait_time = food_data.burned_time - food_data.cooking_time
			cooking_timer.start()
		State.READY:
			current_state = State.BURNED
			steam_burst(State.BURNED)
			sprite_2d.texture = food_data.texture_burned
			burned_timer.start()
		_:
			pass


func set_food_to_raw():
	current_state = State.RAW
	cooking_timer.wait_time = food_data.cooking_time
	cooking_timer.start()
	sprite_2d.texture = food_data.texture_raw


func set_food_to_half_cooked():
	current_state = State.RAW
	cooking_timer.wait_time = food_data.cooking_time
	cooking_timer.start()
	sprite_2d.texture = food_data.texture_cooked


func remove_food():
	var slot = get_meta("grill_slot")
	if slot:
		slot.occupied = false
	queue_free()


func on_flip_food(player_position: float) -> void:
	# checks that the food item is where the player is
	if global_position.x == player_position:
		# check if food is ready
		if current_state == State.READY:
			# check if food is flipped
			if flipped:
				# if the food has been flipped, stop the timer
				# and remove the food from the grill
				cooking_timer.stop()
				player_anim_timer.start()
				food_anim_timer.start()
				GameManager.cooking_streak += 1
				print("Streak:" + str(GameManager.cooking_streak))
			else:
				# flip the food
				flip_food_sprite()
				await get_tree().create_timer(0.2).timeout
				sprite_2d.texture = food_data.texture_cooked
				sizzle_sfx.play()
				flipped = true
				set_food_to_half_cooked()
		# check if food is burned
		elif current_state == State.BURNED:
			# remove the burned food from the grill
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


func steam_burst(state: State) -> void:
	if state == State.READY:
		steam_particles.restart()
	elif state == State.BURNED:
		burned_particles.restart()


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
