class_name MapGroundLayer extends Node2D
func _ready() -> void:
	g_man.map = self

func activate(active: bool):
	if active:
		show()
	else:
		hide()
	var children = get_children()
	for child in children:
		if not child is NavigationRegion2D:
			child.set_collision_mask_value(1, active)
			child.set_collision_layer_value(1, active)
