extends Control


var is_paused: bool = false


@export var main_menu_scene: String


@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	canvas_layer.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		canvas_layer.visible = true
		get_tree().paused = true
	
	if Input.is_action_just_pressed("start"):
		canvas_layer.visible = false
		get_tree().paused = false
		
	
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file.call_deferred(main_menu_scene)
