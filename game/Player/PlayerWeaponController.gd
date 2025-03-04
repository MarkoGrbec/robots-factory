class_name PlayerWeaponController extends Node2D

@export var controller: Player
@export var weapon: Weapon
@export var pickaxe: Tool
@export var shovel: Tool

var array_ttc_tool: Array[TTCTool]

func _on_beam_weapon_hit_body(object) -> void:
	if object.is_in_group("enemy"):
		object.get_hit(1)

func _unhandled_input(event: InputEvent) -> void:
	if g_man.in_game_menu.is_visible_in_tree() or g_man.asking_toggled:
		return
	if event.is_action_pressed("fire") and not g_man.quests_manager.is_visible_in_tree():
		TTCWeapon.new(weapon)
	elif not g_man.camera.input_active and g_man.inventory_system.hover_over_sprite <= 0:
		if event is InputEventMouseButton:
			if event.is_action_released("select"):
				var cp_player: CPPlayer = get_parent().get_parent()
				var mouse_pos = get_global_mouse_position()
				var layer: TileMapLayer = g_man.tile_map_layers.ground_layer[g_man.tile_map_layers.active_layer]
				# if it's underground and going back up go up immediately and without restriction of distance
				if layer:
					var vec: Vector2i = layer.local_to_map(layer.get_local_mouse_position())
					if vec:
						var id = layer.get_cell_source_id(vec)
						if id == TileMapLayers.Tile.SOFT_ROCK_TUNNEL:
							dig(mouse_pos)
							return
						# go down or dig
						if cp_player.global_position.distance_to(mouse_pos) < 96:
							var tool = null
							# diging tool
							if id == TileMapLayers.Tile.ROCK or id == TileMapLayers.Tile.SOFT_ROCK_UNDERGROUND or id == TileMapLayers.Tile.SOFT_ROCK:
								tool = pickaxe
								pickaxe.show()
								controller.blend_anim("mine", 1, g_man.sliders_manager.stamina_slider.value * 0.03)
							elif id == TileMapLayers.Tile.DIRT or id == TileMapLayers.Tile.CLAY or id == TileMapLayers.Tile.GRASS:
								tool = shovel
								shovel.show()
								controller.blend_anim("dig", 1, g_man.sliders_manager.stamina_slider.value * 0.05)
							# inside house
							elif id == TileMapLayers.Tile.HOUSE:
								var house_inter_pos = mp.dict_ground_to_house_container.get(vec)
								if house_inter_pos:
									house_inter_pos = g_man.tile_map_layers.in_to_house(house_inter_pos)
									g_man.player.global_position = house_inter_pos
								return
							# outside house
							elif id == TileMapLayers.Tile.HOUSE_DOOR:
								var house_outer_pos = mp.dict_house_to_ground_container.get(vec)
								if house_outer_pos:
									house_outer_pos = g_man.tile_map_layers.out_of_house(house_outer_pos)
									g_man.player.global_position = house_outer_pos
								return
							array_ttc_tool.push_back(TTCTool.new(tool, mouse_pos, dig))

func dig(mouse_pos):
	var minus_counter = 0
	for i in array_ttc_tool.size():
		var ttc = array_ttc_tool[i - minus_counter]
		if not ttc:
			array_ttc_tool.remove_at(i)
			minus_counter += 1
			controller.blend_anim("dig", 0, 1)
			shovel.hide()
			controller.blend_anim("mine", 0, 1)
			pickaxe.hide()
			continue
		if ttc.finished or not ttc._point:
			if not ttc._tool:
				break
			if ttc._tool.entity_num == Enums.Esprite.shovel:
				controller.blend_anim("dig", 0, 1)
				shovel.hide()
			elif ttc._tool.entity_num == Enums.Esprite.pickaxe:
				controller.blend_anim("mine", 0, 1)
				pickaxe.hide()
		else:
			if ttc._tool.entity_num == Enums.Esprite.shovel:
				controller.blend_anim("dig", 1, g_man.sliders_manager.stamina_slider.value * 0.05)
				shovel.show()
			elif ttc._tool.entity_num == Enums.Esprite.pickaxe:
				controller.blend_anim("mine", 1, g_man.sliders_manager.stamina_slider.value * 0.03)
				pickaxe.show()
			break
	if mouse_pos:
		var gl_mouse_position: Vector2 = get_global_mouse_position()
		if gl_mouse_position.distance_to(mouse_pos) < 32:
			GlobalSignals.select_tile_node.emit(0, mouse_pos, null)
