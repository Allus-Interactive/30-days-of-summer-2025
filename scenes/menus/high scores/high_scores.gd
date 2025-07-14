extends Node2D


@export var game_scene: String


@onready var local_leaderboard_container: VBoxContainer = $CanvasLayer/LocalLeaderboardContainer
@onready var local_leaderboard: Label = $CanvasLayer/LocalLeaderboardContainer/LocalLeaderboard
# @onready var local_leaderboard_container: VBoxContainer = $CanvasLayer/HBoxContainer/LocalLeaderboardContainer
# @onready var local_leaderboard: Label = $CanvasLayer/HBoxContainer/LocalLeaderboardContainer/LocalLeaderboard
@onready var global_leaderboard: Label = $CanvasLayer/HBoxContainer/OnlineLeaderboardContainer/GlobalLeaderboard
@onready var global_title: Label = $CanvasLayer/HBoxContainer/OnlineLeaderboardContainer/GlobalTitle


func _ready() -> void:	
	# Local Leaderboard Logic
	GameManager.load_local_leaderboard()
	for i in GameManager.leaderboard["scores"].size():
		var entry = GameManager.leaderboard["scores"][i]
		local_leaderboard.text += str(i + 1) + ": " + entry["name"] + " - " + str(entry["score"]) + "\n"
	
	# Global Leaderboard Logic
	# TODO: implement online High Score Leaderboard
	# get_global_leaderboard()


func get_global_leaderboard():
	print("Retreiving global leaderboard...")
	var http = HTTPRequest.new()
	# add request node to scene tree
	add_child(http)
	# connect function to run on request completion
	http.request_completed.connect(_on_scores_received)
	# make the request
	http.request("http://localhost:3000/scores")


func _on_scores_received(_result, _code, _headers, body):
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var result = json.data
		print(result)
		for entry in result:
			print("%s: %d\n" % [entry["name"], entry["score"]])
			global_leaderboard.text += "%s: %d\n" % [entry["name"], entry["score"]]
	else:
		print("JSON parsing failed with error code: ", error)
		global_title.visible = false
		global_leaderboard.text = "Unable to retrieve leaderboard. Please try again later."


func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				get_tree().change_scene_to_file.call_deferred(game_scene)
