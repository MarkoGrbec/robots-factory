class_name CPQuest extends CPMob

@export var controller: QuestController
@export var visuals: Visuals
@export var timer: Timer

var entity_inventory
var quest_index
var patrol_targets: Array[Vector2]

var is_talking_to_me: bool = false

func stop_talking_to_me():
	is_talking_to_me = false

func config() -> void:
	var quest_obj = mp.get_quest_object(quest_index)
	if quest_obj:
		name_label.text = quest_obj.quest_name
		visuals.color_poligons(quest_obj.color)
		get_target()

func get_target():
	if patrol_targets:
		controller.target = patrol_targets[0]

func _on_mouse_entered() -> void:
	if not g_man.speech_activated():
		g_man.camera.input_active = quest_index
		show_label()

func _unhandled_input(event: InputEvent) -> void:
	if g_man.camera.input_active is int and g_man.camera.input_active == quest_index:
		if event is InputEventMouseButton:
			if event.is_action_pressed("select"):
				g_man.quests_manager.open_dialog(quest_index, self)
				is_talking_to_me = true
				g_man.quests_manager.stop_talking = stop_talking_to_me


func quest_believe(_old_basis):
	pass

func succeed_old_basis(success_old_basis__qq_index):
	if quest_index == 1:
		if success_old_basis__qq_index[0] == 2:
			if success_old_basis__qq_index[1] == 1:
				change_name()
	elif quest_index == 3:
		if success_old_basis__qq_index[0] == 1:
			if success_old_basis__qq_index[1] == 3:
				change_type(1)
			elif success_old_basis__qq_index[1] == 4:
				change_type(2)
			elif success_old_basis__qq_index[1] == 5:
				change_type(3)
	elif quest_index == 5:# gathering bot
		if success_old_basis__qq_index[0] == 3:
			if success_old_basis__qq_index[1] == 0:
				# activate trader
				g_man.trader.activated = true
				g_man.trader.save_activated()
				CreateMob.target_create_trader(g_man.trader)
		elif success_old_basis__qq_index[0] == 4:
			if success_old_basis__qq_index[1] == 0:
				# create bot and attack it afterwards
				CreateMob.target_create_bot( mp.get_quest_object(7).position , Enums.Esprite.mob_helpless_robot)
		elif success_old_basis__qq_index[0] == 5:
			if success_old_basis__qq_index[1] == 0:
				# attack on helpless robot
				GameControl.set_two_attackers()
		elif success_old_basis__qq_index[0] == 6:
			if success_old_basis__qq_index[1] == 2:
				if g_man.player.weapon_controller.weapon.activated:
					QuestsManager.set_server_quest(6, true, 1)
				else:
					QuestsManager.set_server_quest(6, true, 0)
		elif success_old_basis__qq_index[0] == 7:
			if success_old_basis__qq_index[1] == 0:
				# full scale attack on helpless robot
				GameControl.set_arena()
	elif quest_index == 6: # weapon master
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 1:
				var user: User = g_man.user
				user.set_weapon(true)
		elif success_old_basis__qq_index[0] == 1:
			if success_old_basis__qq_index[1] == 0:
				var user: User = g_man.user
				user.save_battery_constumption(1.1)
				g_man.sliders_manager.mana_slider.value = 100
			elif success_old_basis__qq_index[1] == 1:
				var user: User = g_man.user
				user.save_weapon_range(1.1)
			elif success_old_basis__qq_index[1] == 2:
				var user: User = g_man.user
				user.save_weapon_reflexes(0.9)
	elif quest_index == 11:# johny
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.user.believe_in_god = true
				g_man.user.save_believe_in_god()
		if success_old_basis__qq_index[0] == 1:
			if success_old_basis__qq_index[1] == 0:
				printerr("start full scale attack on factory")
				g_man.tile_map_layers.active_layer = 0
				g_man.tile_map_layers.set_region(Rect2i(20, -42, 30, 1), [[TileMapLayers.Tile.ROCK, 1]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.set_region(Rect2i(19, -41, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(20, -40, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(19, -39, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(20, -38, 30, 1), [[TileMapLayers.Tile.ROCK, 3]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.active_layer = 4
				var server_quest: ServerQuest = QuestsManager.get_server_quest(quest_index)
				server_quest.layer = 0
				server_quest.save_layer()
				global_position = Vector2(3200, -1900)
				server_quest.position = global_position
				server_quest.save_position()
				
		if success_old_basis__qq_index[0] == 3:
			if success_old_basis__qq_index[1] == 0:
				g_man.friendly_robots_spawn_godish.spawn_friendly()
			if success_old_basis__qq_index[1] == 1:
				g_man.friendly_robots_spawn_godish.spawn_friendly_armored()
	elif quest_index == 12:# sophie
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.user.believe_in_god = false
				g_man.user.save_believe_in_god()
		if success_old_basis__qq_index[0] == 1:
			if success_old_basis__qq_index[1] == 0:
				printerr("start full scale craft factory")
				g_man.tile_map_layers.active_layer = 0
				g_man.tile_map_layers.set_region(Rect2i(-28, -38, 30, 1), [[TileMapLayers.Tile.ROCK, 1]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.set_region(Rect2i(-29, -37, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(-28, -36, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(-29, -35, 30, 1), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(-28, -34, 30, 1), [[TileMapLayers.Tile.ROCK, 3]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.active_layer = 4

func change_name():
	g_man.change_name_manager.open_window()

func change_type(type):
	var user: User = g_man.user
	user.save_user_type(type)
