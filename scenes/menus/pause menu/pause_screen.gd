extends Control


var is_paused: bool = false


@export var title_scene: String


@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	canvas_layer.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		is_paused = true
		canvas_layer.visible = true
		get_tree().paused = true
	
	if Input.is_action_just_pressed("start"):
		is_paused = false
		canvas_layer.visible = false
		get_tree().paused = false

	if Input.is_action_just_pressed("quit") and is_paused:
		canvas_layer.visible = false
		get_tree().paused = false
		get_tree().change_scene_to_file.call_deferred(title_scene)
