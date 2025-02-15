class_name MapGroundLayer extends Node2D
func _ready() -> void:
	g_man.map = self

func activate(active: bool):
	#if active:
		#show()
	#else:
		#hide()
	var children = get_children()
	for child in children:
		if not child is NavigationRegion2D:
			activate_child(child, active)
			if child is CPQuest:
				var server_quest: ServerQuest = QuestsManager.get_server_quest(child.quest_index)
				if server_quest.layer == g_man.tile_map_layers.active_layer:
					activate_child(child, true)
				else:
					activate_child(child, false)
#
func activate_child(child, active):
	child.set_collision_mask_value(1, active)
	child.set_collision_layer_value(1, active)
	if active:
		child.show()
	else:
		child.hide()
