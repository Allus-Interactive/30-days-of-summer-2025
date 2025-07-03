extends Control


var is_paused: bool = false


@export var main_menu_scene: String


@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	canvas_layer.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			is_paused = false
			canvas_layer.visible = false
			get_tree().paused = false
		else:
			is_paused = true
			canvas_layer.visible = true
			get_tree().paused = true
	
	if Input.is_action_just_pressed("quit"):
			is_paused = true
			canvas_layer.visible = true
			get_tree().paused = true
			
			get_tree().change_scene_to_file.call_deferred(main_menu_scene)
