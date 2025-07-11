extends Node2D


var current_score: int = 0
var high_score: int = 0
var cooking_streak: int = 0
var is_muted: bool = false
signal flip_the_food(current_position: float)


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
