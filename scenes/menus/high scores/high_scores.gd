extends Node2D


@export var game_scene: String


@onready var local_leaderboard_container: VBoxContainer = $CanvasLayer/HBoxContainer/LocalLeaderboardContainer
@onready var local_leaderboard: Label = $CanvasLayer/HBoxContainer/LocalLeaderboardContainer/LocalLeaderboard
@onready var global_leaderboard: Label = $CanvasLayer/HBoxContainer/OnlineLeaderboardContainer/GlobalLeaderboard
@onready var global_title: Label = $CanvasLayer/HBoxContainer/OnlineLeaderboardContainer/GlobalTitle
@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:	
	get_local_leaderboard()
	get_global_leaderboard()


func get_local_leaderboard():
	GameManager.load_local_leaderboard()
	for i in GameManager.leaderboard["scores"].size():
		var entry = GameManager.leaderboard["scores"][i]
		# local_leaderboard.text += "%d. %s - %d\n" % [i + 1, entry["name"], entry["score"]]
		local_leaderboard.text += "%s%d. %s - %d\n" % [(" " if i < 9 else ""), i + 1, entry["name"], entry["score"]]
		# fill global lb with local data until real data is loaded
		global_leaderboard.text += "%s%d. %s - %d\n" % [(" " if i < 9 else ""), i + 1, entry["name"], entry["score"]]


func get_global_leaderboard():
	# connect function to run on request completion
	http_request.request_completed.connect(_on_scores_received)
	# make the request
	http_request.request(GameManager.firebase_url, [], HTTPClient.METHOD_GET)


func _on_scores_received(_result, response_code, _headers, body):
	if response_code != 200:
		# Failed to load leaderboard
		global_title.visible = false
		return
	var json = JSON.new()
	var json_response = json.parse(body.get_string_from_utf8())
	# Ok or 0 returned is a success code
	if json_response != 0:
		# Error returning leaderboard
		global_title.visible = false
		return
	
	var scores = []
	if json.data != null:
		for key in json.data:
			var entry = json.data[key]
			scores.append(entry)
	
	# Sort descending
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	global_leaderboard.text = ""
	for i in range(min(10, scores.size())):
		var e = scores[i]
		# global_leaderboard.text += "%d. %s - %d\n" % [i + 1, e.name, e.score]
		global_leaderboard.text += "%s%d. %s - %d\n" % [(" " if i < 9 else ""), i + 1, e.name, e.score]


func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				get_tree().change_scene_to_file.call_deferred(game_scene)
