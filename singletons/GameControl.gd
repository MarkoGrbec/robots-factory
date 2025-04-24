extends Node

var _helpless_bot: CPHelplessBot
var enemy_bots: Array[CPEnemy]

var enemy_tunnels: Array

func set_helpless_bot(bot: CPHelplessBot):
	# get the bug out
	if _helpless_bot:
		remove_helpless_bot(bot)
	else:
		_helpless_bot = bot
	
	if _helpless_bot.state == CPHelplessBot.State.CHIPS:
		var basis = QuestsManager.get_server_quest_basis(5)
		if basis == 4 or basis == 9:
			if not enemy_tunnels:
				await get_tree().create_timer(5).timeout
				destroy_helpless_bot()
		elif basis == 10:
			set_two_attackers()
		elif basis == 11:
			set_arena()

func set_two_attackers():
	await get_tree().create_timer(4).timeout
	GameControl.destroy_helpless_bot()
	GameControl.destroy_helpless_bot()

func set_arena():
	var timer = mp.global_timer
	timer.timeout.connect(
		func():
			destroy_helpless_bot(true)
			destroy_helpless_bot()
	)
	timer.start(12)
	if _helpless_bot:
		await get_tree().create_timer(61).timeout
	else:
		await get_tree().create_timer(11).timeout
	timer.stop()
	for conn in timer.timeout.get_connections():
		timer.timeout.disconnect(conn.callable)

func remove_helpless_bot(helpless_bot):
	if helpless_bot:
		if g_man.camera.input_active == -3:
			g_man.camera.input_active = 0
		g_man.savable_mob.remove_at(helpless_bot.id_mob)
		helpless_bot.queue_free()
		if helpless_bot == _helpless_bot:
			_helpless_bot = null

func enter_enemy(target, bring_mats: bool = false, coords_spawn: Vector2i = Vector2i(3, 3), walk: bool = false):
	await get_tree().create_timer(3).timeout
	var pos__id_tile = g_man.tile_map_layers.override_fake_tunnel(coords_spawn)
	if pos__id_tile:
		var enemy_bot: CPEnemy = CreateMob.target_create_enemy_bot(pos__id_tile[0] / 2, Enums.Esprite.mob_commander_client)
		enemy_bot.controller.starting_point = enemy_bot.global_position
		enemy_bot.controller.coords = [coords_spawn, pos__id_tile]
		var enemy_tunnel = [[enemy_bot], [coords_spawn, pos__id_tile]]
		# make music
		if not enemy_tunnels:
			g_man.music_manager.set_music_type(MusicManager.MusicStatus.action)
		
		enemy_tunnels.push_back(enemy_tunnel)
		enemy_bot.controller.enemy_tunnel = enemy_tunnel
		enemy_bot.controller.target = target
		
		if bring_mats:
			enemy_bot.controller.agent.avoidance_enabled = false
			enemy_bot.controller.state = EnemyController.State.BRING_MATS
		enemy_bot.controller.set_timer()
		if walk:
			enemy_bot.controller.movement.state = Movement.State.WALK

func destroy_helpless_bot(bring_mats: bool = false):
	if not _helpless_bot:
		return
	enter_enemy(_helpless_bot, bring_mats, Vector2i(randi_range(2, 18), randi_range(10, 18)))

func retreve_bot(tunnel):
	if g_man.tutorial:
		await g_man.holding_hand.holding_hand_enemy()
	var enemy_bot: CPEnemy = CreateMob.target_create_enemy_bot(tunnel[1][1][0] / 2, Enums.Esprite.mob_commander_client)
	enemy_bot.controller.starting_point = enemy_bot.global_position
	enemy_bot.controller.coords = tunnel[1]
	enemy_bot.controller.enemy_tunnel = tunnel
	enemy_bot.controller.target = tunnel[0][0]
	enemy_bot.controller.state = EnemyController.State.RETRIVE
	enemy_bot.health = -1
	tunnel[0].push_back(enemy_bot)
	enemy_bot.controller.set_timer(30)

func turn_fake_tunnel_back(tunnel_coords, state: EnemyController.State, target):
	# work around the BUG
	g_man.inventory_system.add_remove_hover_over_sprite(-1)
	if g_man.tutorial:
		await g_man.holding_hand.holding_hand_enemy_finished()
	if not tunnel_coords:
		try_turn_off_action_music()
		return
	g_man.tile_map_layers.override_fake_tunnel_back(tunnel_coords[1][0], tunnel_coords[1][1][1])
	for bot in tunnel_coords[0]:
		bot.queue_free()
		g_man.camera.input_active = 0
	
	enemy_tunnels.erase(tunnel_coords)
	
	if state == EnemyController.State.DRAG and target is CPHelplessBot:
		remove_helpless_bot(_helpless_bot)
		_helpless_bot = null
		QuestsManager.set_server_quest(5, true, 6)
		QuestsManager.set_server_quest(4, true, 12)
		try_turn_off_action_music()
	elif not enemy_tunnels: # overriding quest basis after quest has been completed (tunnels cleared)
		try_turn_off_action_music()
		var basis = QuestsManager.get_server_quest_basis(5)
		# fill molds with iron sucessfully defended robot
		if basis == 9:
			QuestsManager.set_server_quest(5, true, 5)
			# sand
			QuestsManager.set_server_quest(4, true, 11)
		# get sand from trader sucessfully defended robot
		if basis == 10:
			QuestsManager.set_server_quest(5, true, 7)
			# iron
			QuestsManager.set_server_quest(4, true, 10)
		# reprogram the robot sucessfully defended robot
		if basis == 11:
			QuestsManager.set_server_quest(5, true, 8)
			
			remove_helpless_bot(_helpless_bot)
			QuestsManager.set_server_quest(7, true, 0)
			g_man.mold_window.set_instructions_only(["Thanks for saving me... I guess.\nOr was I programmed to say this?"], 7)

func try_turn_off_action_music():
	if not enemy_tunnels:
		g_man.music_manager.set_music_type(MusicManager.MusicStatus.wandering)
