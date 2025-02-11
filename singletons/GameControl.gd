extends Node

var _helpless_bot: CPHelplessBot
var enemy_bots: Array[CPEnemy]

var enemy_tunnels: Array

func set_helpless_bot(bot: CPHelplessBot):
	# get the bug out
	if _helpless_bot:
		g_man.savable_mob.remove_at(bot.id_mob)
		bot.queue_free()
	else:
		_helpless_bot = bot
	
	if _helpless_bot.state == CPHelplessBot.State.CHIPS:
		var basis = QuestsManager.get_server_quest_basis(5)
		if basis == 4:
			if not enemy_tunnels:
				destroy_helpless_bot()

func remove_helpless_bot():
	if _helpless_bot:
		g_man.savable_mob.remove_at(_helpless_bot.id_mob)
		_helpless_bot.queue_free()
		_helpless_bot = null

func destroy_helpless_bot(bring_mats: bool = false):
	if not _helpless_bot:
		return
	await get_tree().create_timer(3).timeout
	var coords_spawn = Vector2i(randi_range(1, 19), randi_range(1, 19))
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
		enemy_bot.controller.target = GameControl._helpless_bot
		
		
		if bring_mats:
			enemy_bot.controller.agent.avoidance_enabled = false
			enemy_bot.controller.state = EnemyController.State.BRING_MATS
		enemy_bot.controller.set_timer()

func retreve_bot(tunnel):
	var enemy_bot: CPEnemy = CreateMob.target_create_enemy_bot(tunnel[1][1][0] / 2, Enums.Esprite.mob_commander_client)
	enemy_bot.controller.starting_point = enemy_bot.global_position
	enemy_bot.controller.coords = tunnel[1]
	enemy_bot.controller.enemy_tunnel = tunnel
	enemy_bot.controller.target = tunnel[0][0]
	enemy_bot.controller.state = EnemyController.State.RETRIVE
	enemy_bot.health = -1
	tunnel[0].push_back(enemy_bot)
	enemy_bot.controller.set_timer(30)

func turn_fake_tunnel_back(tunnel_coords, state: EnemyController.State):
	if not tunnel_coords:
		return
	g_man.tile_map_layers.override_fake_tunnel_back(tunnel_coords[1][0], tunnel_coords[1][1][1])
	for bot in tunnel_coords[0]:
		bot.queue_free()
	
	enemy_tunnels.erase(tunnel_coords)
	
	if state == EnemyController.State.RUN:
		remove_helpless_bot()
		_helpless_bot = null
		QuestsManager.set_server_quest(5, true, 6)
		QuestsManager.set_server_quest(4, true, 12)
	elif not enemy_tunnels: # overriding quest basis after quest has been completed (tunnels cleared)
		g_man.music_manager.set_music_type(MusicManager.MusicStatus.wandering)
		var basis = QuestsManager.get_server_quest_basis(5)
		if basis == 4:
			QuestsManager.set_server_quest(5, true, 5)
			# sand
			QuestsManager.set_server_quest(4, true, 11)
		if basis == 5:
			QuestsManager.set_server_quest(5, true, 7)
			# iron
			QuestsManager.set_server_quest(4, true, 10)
		if basis == 7:
			QuestsManager.set_server_quest(5, true, 8)
			
			remove_helpless_bot()
			QuestsManager.set_server_quest(7, true, 0)
			g_man.mold_window.set_instructions_only(["thanks for saving me", "I guess", "or was I programmed for it to say"], 7)
