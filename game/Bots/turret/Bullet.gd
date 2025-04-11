extends Node2D

func _process(delta: float) -> void:
	global_position += transform * Vector2(1 * delta, 0)
