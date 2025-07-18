extends Node2D


@export var lb_scene: String


@onready var leaderboard_button: Button = $CanvasLayer/LeaderboardButton
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var letter_labels = [
	$CanvasLayer/Letter1,
	$CanvasLayer/Letter2,
	$CanvasLayer/Letter3
]

var alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
var letters = ["A", "A", "A"]
var current_index = 0  # which letter is selected
var player_initials: String


func _ready() -> void:
	letter_labels[0].add_theme_color_override("font_color", Color.YELLOW)
	leaderboard_button.grab_focus()


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
				cycle_letter(1)
			KEY_S:
				cycle_letter(-1)
			KEY_ENTER:
				player_initials = letters[0] + letters[1] + letters[2]
				GameManager.add_score_to_global_leaderboard(player_initials, GameManager.current_score)
				GameManager.add_score_to_local_leaderboard(player_initials, GameManager.current_score)
				info_label.text = "Loading..."
				await get_tree().create_timer(2.0).timeout
				get_tree().change_scene_to_file.call_deferred(lb_scene)


func cycle_letter(direction: int):
	var current_letter = letters[current_index]
	var current_pos = alphabet.find(current_letter)
	if current_pos == -1:
		current_pos = 0  # fallback just in case
	var new_pos = (current_pos + direction) % alphabet.size()
	letters[current_index] = alphabet[new_pos]
	update_letters()

func update_letters():
	for i in range(3):
		letter_labels[i].text = letters[i]

func update_cursor():
	for i in range(3):
		letter_labels[i].add_theme_color_override("font_color", Color.YELLOW if i == current_index else Color.hex(0x9e2413ff))


func _on_leaderboard_button_pressed() -> void:
	player_initials = letters[0] + letters[1] + letters[2]
	GameManager.add_score_to_local_leaderboard(player_initials, GameManager.current_score)
	get_tree().change_scene_to_file.call_deferred(lb_scene)
