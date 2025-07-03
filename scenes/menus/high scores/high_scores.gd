extends Control


@export var prev_scene: String


@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel
@onready var online_high_score_label: Label = $CanvasLayer/OnlineHighScoreLabel
@onready var back_button: Button = $CanvasLayer/BackButton


func _ready() -> void:
	back_button.grab_focus()
	
	GameManager.high_score = GameManager.load_high_score()
	if GameManager.high_score <= 0:
		high_score_label.visible = false
	high_score_label.text = "Your High Score: %d" % GameManager.high_score
	
	# TODO: implement online High Score Leaderboard
	# online_high_score_label.text = ""
	# get_high_scores()


func get_high_scores():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_scores_received)
	http.request("http://localhost:3000/scores")


func _on_scores_received(_result, _code, _headers, body):
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var result = json.data
		print(result)
		for entry in result:
			print(entry)
			if entry == "error":
				# Auth Error
				online_high_score_label.text = "Unable to retrieve high scores. Please try again later."
			else:
				print("%s: %d\n" % [entry["name"], entry["score"]])
				online_high_score_label.text += "%s: %d\n" % [entry["name"], entry["score"]]
	else:
		print("JSON parsing failed with error code: ", error)
		online_high_score_label.text = "Unable to retrieve high scores. Please try again later."

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred(prev_scene)
