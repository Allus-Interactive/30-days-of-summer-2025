extends Node2D


const FOOD_TYPES =[
	preload("res://resources/food resources/burger.tres"),
	preload("res://resources/food resources/sausage.tres"),
	preload("res://resources/food resources/shish-kebab.tres"),
]


@export var times_up_scene: String
@export var lb_submit_scene: String
@export var time_remaining = 60
@export var combo_streak: int = 5
@export var combo_multiplier: int = 5


@onready var grill_slots: Array = $GrillArea/GrillSlots.get_children()
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var combo_label: Label = $CanvasLayer/ComboLabel
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var food_spawn_timer: Timer = $GrillArea/FoodSpawnTimer
@onready var level_timer: Timer = $LevelTimer
@onready var combo_label_timer: Timer = $ComboLabelTimer
@onready var sizzle_sfx: AudioStreamPlayer2D = $SizzleSFX
@onready var ticking_sfx: AudioStreamPlayer2D = $TickingSFX
@onready var tasty_sfx: AudioStreamPlayer2D = $TastySFX


var food_scene = preload("res://scenes/food/food.tscn")
var score = 0
var score_multiplier: float = 1
var spawn_rate: float = 1


func _ready() -> void:
	add_to_group("game")
	set_difficulty_multiplier()
	# update timer for difficulty level and start it
	food_spawn_timer.wait_time = food_spawn_timer.wait_time * spawn_rate
	food_spawn_timer.start()
	timer_label.text = "Time: %d" % time_remaining
	combo_label.visible = false


func _process(_delta: float) -> void:
	# play tick sfx when 10 seconds left on game
	if time_remaining == 10:
		ticking_sfx.play()


func set_difficulty_multiplier() -> void:
	# set difficulty multipliers
	match GameManager.difficulty_level:
		GameManager.Difficulty.easy:
			score_multiplier = 0.75
			spawn_rate = 1.25
		GameManager.Difficulty.medium:
			score_multiplier = 1
			spawn_rate = 1
		GameManager.Difficulty.hard:
			score_multiplier = 1.25
			spawn_rate = 0.75
		_:
			score_multiplier = 1
			spawn_rate = 1


func add_score(value: int) -> void:
	var diff_score = value * score_multiplier
	if GameManager.cooking_streak == combo_streak:
		GameManager.cooking_streak = 0
		tasty_sfx.play()
		score += (diff_score * combo_multiplier)
		combo_label.visible = true
		combo_label_timer.start()
	else:
		score += diff_score
	score_label.text = "Score: %d" % score


func on_timer_finished():
	# Game End
	GameManager.current_score = score
	if GameManager.difficulty_level == GameManager.Difficulty.hard:
		if score < GameManager.leaderboard["scores"].back()["score"]:
			# load time's up, try again scene
			get_tree().change_scene_to_file.call_deferred(times_up_scene)
		else:
			# load scene for leaderboard submission
			get_tree().change_scene_to_file.call_deferred(lb_submit_scene)
	else: 
		# load time's up, try again scene
		get_tree().change_scene_to_file.call_deferred(times_up_scene)


func _on_food_spawn_timer_timeout() -> void:
	if not sizzle_sfx.playing:
		sizzle_sfx.play()
	
	var available_slots = grill_slots.filter(func(_slot):
		return not _slot.occupied
	)
	
	if available_slots.is_empty():
		# all slots have food in them
		return
	
	var food_data = FOOD_TYPES.pick_random()
	var food = food_scene.instantiate()
	food.food_data = food_data
	var slot = available_slots.pick_random()
	food.global_position = slot.global_position
	add_child(food)
	if food_spawn_timer.wait_time > 1.0:
		food_spawn_timer.wait_time -= (0.1 * score_multiplier)
	
	slot.occupied = true
	food.set_meta("grill_slot", slot)


func _on_level_timer_timeout() -> void:
	time_remaining -= 1
	timer_label.text = "Time: %d" % time_remaining
	
	if time_remaining <= 0:
		level_timer.stop()
		on_timer_finished()


func _on_combo_label_timer_timeout() -> void:
	combo_label.visible = false
