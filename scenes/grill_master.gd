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


var food_scene = preload("res://scenes/food/food.tscn")
var score = 0


func _ready() -> void:
	add_to_group("game")
	food_spawn_timer.start()
	timer_label.text = "Time: %d" % time_remaining
	combo_label.visible = false


func _process(delta: float) -> void:
	if time_remaining == 10:
		ticking_sfx.play()


func add_score(value: int) -> void:
	if GameManager.cooking_streak == combo_streak:
		# TODO: add 'Tasty' sfx
		score += (value * combo_multiplier)
		combo_label.visible = true
	else:
		score += value
	score_label.text = "Score: %d" % score


func on_timer_finished():
	# Game End
	GameManager.current_score = score
	if score < GameManager.leaderboard["scores"].back()["score"]:
		# load time's up, try again scene
		get_tree().change_scene_to_file.call_deferred(times_up_scene)
	else:
		# load scene for leaderboard submission
		get_tree().change_scene_to_file.call_deferred(lb_submit_scene)
		
	#if score > GameManager.high_score:
		#GameManager.high_score = score
		#GameManager.add_score_to_local_leaderboard("RWM", score)
		## TODO: implement Leaderboard
		## TODO: add input for player initials to replace hardcoded "RWM" 
		## GameManager.submit_score("RWM", score)
	#get_tree().change_scene_to_file.call_deferred(times_up_scene)


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
		food_spawn_timer.wait_time -= 0.1
	
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
