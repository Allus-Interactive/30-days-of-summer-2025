extends Node2D


const FOOD_TYPES =[
	preload("res://resources/food resources/burger.tres"),
	preload("res://resources/food resources/sausage.tres"),
	preload("res://resources/food resources/shish-kebab.tres"),
]


@export var times_up_scene: String


@onready var grill_slots: Array = $GrillArea/GrillSlots.get_children()
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var food_spawn_timer: Timer = $GrillArea/FoodSpawnTimer
@onready var level_timer: Timer = $LevelTimer
@onready var sizzle_sfx: AudioStreamPlayer2D = $SizzleSFX


var food_scene = preload("res://scenes/food/food.tscn")
var score = 0
var time_remaining = 60


func _ready() -> void:
	add_to_group("game")
	food_spawn_timer.start()
	timer_label.text = "Time: %d" % time_remaining


func add_score(value: int) -> void:
	score += value
	score_label.text = "Score: %d" % score


func on_timer_finished():
	# Game end
	print("Time's Up")
	# TODO implement game end logic
	GameManager.current_score = score
	if score > GameManager.high_score:
		GameManager.high_score = score
		GameManager.save_high_score(score)
	get_tree().change_scene_to_file.call_deferred(times_up_scene)


func _on_food_spawn_timer_timeout() -> void:
	if not sizzle_sfx.playing:
		sizzle_sfx.play()
	
	var available_slots = grill_slots.filter(func(slot):
		return not slot.occupied
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
	food.food_data
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
