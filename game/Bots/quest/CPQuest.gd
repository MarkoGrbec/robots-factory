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


func quest_believe(old_basis):
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
				# create bot
				CreateMob.target_create_bot( mp.get_quest_object(7).position , Enums.Esprite.mob_helpless_robot)
		elif success_old_basis__qq_index[0] == 5:
			if success_old_basis__qq_index[1] == 0:
				GameControl.destroy_helpless_bot()
				GameControl.destroy_helpless_bot()
		elif success_old_basis__qq_index[0] == 6:
			if success_old_basis__qq_index[1] == 2:
				if g_man.player.weapon_controller.weapon.activated:
					QuestsManager.set_server_quest(6, true, 1)
				else:
					QuestsManager.set_server_quest(6, true, 0)
		elif success_old_basis__qq_index[0] == 7:
			if success_old_basis__qq_index[1] == 0:
				timer.timeout.connect(
					func():
						GameControl.destroy_helpless_bot(true)
						GameControl.destroy_helpless_bot()
				)
				timer.start(12)
				if GameControl._helpless_bot:
					await get_tree().create_timer(61).timeout
				else:
					await get_tree().create_timer(11).timeout
				timer.stop()
				for conn in timer.timeout.get_connections():
					timer.timeout.disconnect(conn.callable)
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
	elif quest_index == 7:# assistant bot
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.tile_map_layers.set_region(Rect2i(9, -29, 1, 30), [[TileMapLayers.Tile.ROCK, 1]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.set_region(Rect2i(10, -29, 1, 30), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(11, -29, 1, 30), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(12, -29, 1, 30), [[TileMapLayers.Tile.ROCK, 3]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
	elif quest_index == 11:# johny
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.user.believe_in_god = true
				g_man.user.save_believe_in_god()
	elif quest_index == 12:# sophie
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.user.believe_in_god = false
				g_man.user.save_believe_in_god()

func change_name():
	g_man.change_name_manager.open_window()

func change_type(type):
	var user: User = g_man.user
	user.save_user_type(type)
