class_name Camera extends Camera2D

var input_active = 0

func _ready() -> void:
	g_man.camera = self
