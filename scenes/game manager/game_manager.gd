extends Node2D


var current_score: int = 0
var high_score: int = 0
var cooking_streak: int = 0
var is_muted: bool = false
signal flip_the_food(current_position: float)

var leaderboard = {
	"scores": [  # Each entry can be a dictionary with name and score
		{"name": "LFC", "score": 200},
		{"name": "GOD", "score": 180},
		{"name": "PRO", "score": 160},
		{"name": "ABC", "score": 140},
		{"name": "DEF", "score": 120},
		{"name": "GHI", "score": 100},
		{"name": "JKL", "score": 80},
		{"name": "MNO", "score": 60},
		{"name": "PQR", "score": 40},
		{"name": "STV", "score": 20},
	]
}


func save_high_score(score: int) -> void:
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if file:
		file.store_32(score)
		file.close()


func load_high_score() -> int:
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		if file:
			var score = file.get_32()
			file.close()
			return score
		else: 
			return 0
	else:
		return 0


func submit_score(username: String, new_score: int):
	var http = HTTPRequest.new()
	add_child(http)
	
	var data = { "name": username, "score": new_score }
	var json_data= JSON.stringify(data)
	print (json_data)
	
	http.request_completed.connect(_on_request_completed)
	
	var headers = ["Content-Type: application/json"]
	http.request("http://localhost:3000/submit", headers, HTTPClient.Method.METHOD_POST, json_data)


func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code == 200:
		print("Score submitted successfully!")
	else:
		print("Failed to submit score. Response code:", response_code)


func save_local_leaderboard():
	var file = FileAccess.open("user://leaderboard.json", FileAccess.WRITE)
	if file:
		var json = JSON.stringify(leaderboard, "\t")
		file.store_string(json)
		file.close()


func load_local_leaderboard():
	if not FileAccess.file_exists("user://leaderboard.json"):
		print("No leaderboard file found.")
		return
	
	var file = FileAccess.open("user://leaderboard.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var result = JSON.parse_string(content)
		if result is Dictionary:
			leaderboard = result
		else:
			print("Error parsing leaderboard data.")
		file.close()
