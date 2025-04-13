class_name MapGroundLayer extends Node2D

@export var static_objects: Array[StaticBody2D]

func _ready() -> void:
	g_man.map = self

func activate(active: bool):
	var children = get_children()
	for child in children:
		if not child is NavigationRegion2D and not child is TileMapLayer:
			if child.name == "underground_layer1" or child.name == "underground_layer2" or child.name == "underground_layer3" or child.name == "inside_houses_layer1":
				continue
			activate_child(child, active)
			if child is CPQuest:
				var server_quest = QuestsManager.get_server_quest(child.quest_index)
				if server_quest:
					if server_quest.layer == g_man.tile_map_layers.active_layer:
						activate_child(child, true)
					else:
						activate_child(child, false)
	for child in static_objects:
		activate_child(child, active)

func activate_child(child, active):
	child.set_collision_mask_value(1, active)
	child.set_collision_layer_value(1, active)
	if active:
		child.show()
	else:
		child.hide()
