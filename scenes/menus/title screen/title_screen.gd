extends Control


@export var next_scene: String


@onready var title_sfx: AudioStreamPlayer2D = $TitleSFX


func _ready() -> void:
	var bg_music = GameManager.get_node("MusicPlayer")
	if bg_music and not bg_music.playing:
		bg_music.play()
	title_sfx.play() 


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file.call_deferred(next_scene)
