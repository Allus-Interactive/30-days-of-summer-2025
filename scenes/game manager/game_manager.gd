extends Node2D


var high_score: int = 0


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
