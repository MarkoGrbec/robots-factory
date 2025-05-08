class_name GlobalCanvas extends Control

func _ready() -> void:
	g_man.global_canvas = self

func get_global_canvas_rect() -> Rect2:
	#return get_rect()
	return get_global_rect()
