extends Node2D


@export var game_scene: String

@onready var difficulty_labels = [
	$CanvasLayer/Easy,
	$CanvasLayer/Medium,
	$CanvasLayer/Hard
]


var current_index = 0  # which label is selected


func _ready() -> void:
	difficulty_labels[0].add_theme_color_override("font_color", Color.YELLOW)


func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_A:
				current_index = max(current_index - 1, 0)
				update_cursor()
			KEY_D:
				current_index = min(current_index + 1, 2)
				update_cursor()
			KEY_W:
				current_index = max(current_index - 1, 0)
				update_cursor()
			KEY_S:
				current_index = min(current_index + 1, 2)
				update_cursor()
			KEY_SPACE:
				set_difficulty()
				get_tree().change_scene_to_file.call_deferred(game_scene)


func update_cursor():
	for i in range(3):
		difficulty_labels[i].add_theme_color_override("font_color", Color.YELLOW if i == current_index else Color.hex(0x9e2413ff))


func set_difficulty():
	match current_index:
		0:
			# set difficult to easy
			GameManager.difficulty_level = GameManager.Difficulty.easy
		1:
			# set difficulty to medium
			GameManager.difficulty_level = GameManager.Difficulty.medium
		2: 
			# set difficulty to hard
			GameManager.difficulty_level = GameManager.Difficulty.hard
