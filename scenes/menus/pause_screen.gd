extends Control


var is_paused: bool = false


@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	canvas_layer.visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			is_paused = false
			canvas_layer.visible = false
			get_tree().paused = false
		else:
			is_paused = true
			canvas_layer.visible = true
			get_tree().paused = true
