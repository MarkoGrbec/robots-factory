extends ScrollContainer

var avatar_name: String

@export var start_game: Button
@export var delete_user: Button
@export var username_line_edit: LineEdit
@export var terrain: PackedScene
@export var terrain_tutorial: PackedScene
@export var welcome_label: Label
@export var welcome_button: Button

enum Month{
	January = 1,
	February = 2,
	March = 3,
	April = 4,
	May = 5,
	June = 6,
	July = 7,
	August = 8,
	September = 9,
	October = 10,
	November = 11,
	December = 12,
}

func _ready() -> void:
	var tab = get_parent()
	tab.set_tab_hidden(2, true)
	tab.current_tab = 0
	var user = g_man.savable_user.get_index_data(1)
	if user:
		g_man.user = user
		avatar_name = user.avatar_name
	if avatar_name:
		start_game.text = str("start with: ", avatar_name)
		username_line_edit.hide()
		tooltip_text = "start playing with character you made before or delete it"
	else:
		delete_user.hide()
		set_tooltip_start()

func set_tooltip_start() -> void:
	tooltip_text = "set name for your character and game saves as you progress"

func _on_delete_user_pressed() -> void:
	avatar_name = ""
	start_game.text = str("start game")
	username_line_edit.show()
	destroy_user()
	delete_user.hide()
	set_tooltip_start()

func submit_username(_text: String) -> void:
	_on_start_game_pressed()

func _on_start_game_pressed() -> void:
	# load user
	if avatar_name:
		welcome_screen()
		delete_user.show()
		return
	# delete / create user from scratch
	if username_line_edit.text and not avatar_name and username_line_edit.text.length() < 8:
		# destroy user
		destroy_user()
		
		# rename part username with 0 and 1
		avatar_name = username_line_edit.text
		if avatar_name.length() < 8:
			var remaining = 8 - avatar_name.length()
			for i in remaining:
				avatar_name += str(randi_range(0, 1))
		
		# create user
		g_man.user.avatar_name = avatar_name
		g_man.user.fully_save()
		welcome_screen()
		delete_user.show()
	elif username_line_edit.text:
		g_man.changes_manager.add_change("your name is too long it's the software's fault 8 bytes have gone wild")
	else:
		g_man.changes_manager.add_change("please enter your name")

func destroy_user():
	g_man.savable_user.remove_all()
	g_man.user = g_man.savable_user.set_index_data(1, User.new(), 0)
	g_man.user.destroy()
	g_man.savable_mob.remove_all()
	g_man.savable_entity.remove_all()
	g_man.savable_holding_hand.remove_all()
	g_man.savable_trader.remove_all()
	var holding_hand: HoldingHand = g_man.savable_holding_hand.set_index_data(1, HoldingHand.new())
	g_man.holding_hand = holding_hand
	g_man.savable_inventory_slot.remove_all()
	g_man.savable_trader.remove_all()
	# each one for 1 layer
	g_man.savable_multi_avatar__quest_data.remove_all()
	g_man.savable_terrain_ground.set_index_data(1, Terrain.new(), 2).remove_all()
	#g_man.savable_terrain_underground1.set_index_data(2, Terrain.new(), 2).remove_all()
	#g_man.savable_terrain_underground2.set_index_data(3, Terrain.new(), 2).remove_all()
	#g_man.savable_terrain_underground3.set_index_data(4, Terrain.new(), 2).remove_all()

func welcome_screen() -> void:
	# load or set stuff
	# holding hand
	set_holding_hand()
	# trader
	g_man.trader = g_man.savable_trader.get_index_data(1, 2)
	if not g_man.trader:
		g_man.trader = g_man.savable_trader.set_index_data(1, Trader.new(), 2)
	# terrain
	var ground = g_man.savable_terrain_ground.get_index_data(1, 2)
	#var underground1 = g_man.savable_terrain_underground1.get_index_data(2, 2)
	#var underground2 = g_man.savable_terrain_underground2.get_index_data(3, 2)
	#var underground3 = g_man.savable_terrain_underground3.get_index_data(4, 2)
	
	
	var t = terrain.instantiate()
	g_man.main_menu.terrain = t
	g_man.main_menu.add_child(t)
	
	# after map is created
	if g_man.trader.activated:
		CreateMob.target_create_trader(g_man.trader)
	
	g_man.tile_map_layers.savables = ground
	
	g_man.tile_map_layers.load_map()
	# npcs
	mp.set_quests_npcs()
	var quest_servers = mp.get_quest_objects(1)# 1 = id user
	for quest_server in quest_servers:
		if quest_server.activated:
			QuestsManager.target_send_quest_mob_to_make(quest_server)
	
	var tab = get_parent()
	tab.set_tab_hidden(0, true)
	tab.set_tab_hidden(1, true)
	tab.set_tab_hidden(2, false)
	tab.current_tab = 2
	var user: User = g_man.savable_user.get_index_data(1)
	g_man.user = user
	user.load_weapon()
	user.load_weapon_range()
	user.load_weapon_reflexes()
	user.load_battery_constumption()
	user.load_weapon_strength()
	user.load_armor_strength()
	user.load_factory_state()
	# load position
	var pos = user.load_return_position()
	if pos != Vector2.ZERO:
		g_man.player.global_position = pos
	# load layer
	g_man.tile_map_layers.activate_layer(user.load_return_layer())
	var time = user.load_return_user_time_change_name()
	if time:
		var dict: Dictionary = Time.get_datetime_dict_from_unix_time(time)
		var int_month = dict.get("month")
		welcome_label.text = str("welcome robot ", avatar_name, " you're changed name was at:\n", "\nyear: ", dict.get("year"), "\nmonth: ", Month.find_key(int_month), "\nday: ", dict.get("day"), "\nhour: ", dict.get("hour"), "\nminute: ", dict.get("minute"), "\nsecond: ", dict.get("second"))
		welcome_button.text = str("thanks for the info.")
	else:
		welcome_label.text = str("welcome robot ", avatar_name, " you were made at time: ", Time.get_unix_time_from_system(), "\nerror error something is wrong with name try fixing it")
		welcome_button.text = str("let's fix my name")

func set_holding_hand() -> void:
	g_man.holding_hand = g_man.savable_holding_hand.get_index_data(1, 0)
	if not g_man.holding_hand:
		g_man.holding_hand = g_man.savable_holding_hand.set_index_data(1, HoldingHand.new(), 0)
	g_man.holding_hand.config()

func close_welcome_window() -> void:
	g_man.sliders_manager.open_window()
	g_man.savable_entity.partly_load_all()
	
	g_man.player.config_name(g_man.user.avatar_name)
	g_man.inventory_system.generate_inventory_slots()
	
	g_man.savable_mob.partly_load_all()
	g_man.main_menu.close_main_menu()
	g_man.music_manager.set_music_type(MusicManager.MusicStatus.wandering)

func _on_message_to_ash_february_pressed() -> void:
	g_man.mold_window.set_instructions_only(["first of all I would like to thank you for previous feedback for it you'll have walls of text", "becarefull what you wish for, you might get it ;)", "truthfully I have no idea what text to speach I'm using on your machine but I'm only guessing the default is not an ai generated if you think it is say which part as I'm using bot id to get id(number) of speach voice by a number and I'll simply remove that index number of id", "\nI wander where YOU wish to get in to the game", "so I know what to develop not only focuses", "try to use key words at talking to NPC that are given to you by a context things they say try using main words that they say if main words aren't enough try combining them sometimes you need more than 1 word to activate", "\nhappy playing and please keep your mind on a game", "because you really need to keep attention in the game", "it's not usual kill and go game", "but more ask and REMEMBER what you were been told", "what to ask next npc what npc is whom and at what stage you are in the moment and the story of the game", "\nI will not hold your hand there untill companion except hint bot which is trying to explain kinda in riddles what to do", "\nalso I wander whom do you like more companion or hint bot that's when you get a companion I'd like to know your opinion"])

func _on_message_to_ash_march_pressed() -> void:
	g_man.mold_window.set_instructions_only(["thanks for feedback, I'd ask you to adjust audio volume press ESC key to enter main menu. as last time I saw you don't have ESC key I've added a q key to enter it I know as you pressed all keys on the keyboard, than you can also change key bindings. I cannot adjust volume of system text to speach but I can adjust all other volumes it's godot not fully functionality. that was max you could do last time as it was essential to open inventory in quest window. also I'd suggest to try tutorial first I've tried some times to do it correctly with some help."])

func _on_message_to_ash_april_pressed() -> void:
	g_man.mold_window.set_instructions_only(["thanks I love that it finally clicked, not only for you but also for my experience.\n\nI have added buy stack while dragging use mouse wheel or change bindings [plus stack] [minus stack]\n\nthere's also a cheat IF you will need to buy another 15 iron to reset the trader and your gold coins,\nI think you haven't noticed but there's indicator how much it actually costs around cost is rough cost but while dragging there's indicator (above trader buy and sell box) cost that says exactly how much it costs.\nIt's usually not wise to dry empty but gather somewhere in middle I think and sell.\n\ntutorial has no changes, tho I don't know why did you wanted to try the dead end right away, ...\n\nplease adjust music and sounds volume I have added a audio to hear when changing it.\n\nnow there's 2 of us devs one is helping me with story\n\nyou might want to test only 1 end of the game this time and the other end on the next month you can choose witch ever fork you want. -> beleve or not to believe, ...\nI will be developing the story on other forks you saw before, fighting and crafting, ...\nI'll probably go first on fighting.\n\noh and try using controller I don't have one and I'd love to see if it works. also the save system of controller bindings.\nyou'll need to quit game to test save system\n\nI have noticed you haven't tried queued the digging\nif you press multiple times before the material is dug you can dig it many more times\nI'll add it to tutorial when I'll have time.\n\nIF you encounter a bug in bots believe that no option dialog shows restart the application it'll fix there's many of them and I searched through all but it can happen that I missed some new basis to fix thanks"])

func _on_message_to_ash_may_pressed() -> void:
	g_man.mold_window.set_instructions_only(["since you didn't get through whole tutorial I might tell you a hint you'd like to know the number on the dialog options means how many different response dialogs there are.\nonce you'll be at end of game I'd ask to delete the char and begin from beginning and try the branch of other believe. also you'll experience the fixed enemy bots. ps. don't forget to dig ;)\n\ncan you retry bindings save system?\nI have changed it quite a bit\n\nthere are new bindings\nyou can pick up material\nconstruction of new materials - you need crafting fork opened"])

func _on_tutorial_pressed() -> void:
	g_man.user.gold_coins = 500
	g_man.sliders_manager.open_window()
	if g_man.holding_hand:
		g_man.holding_hand.destroy()
	set_holding_hand()
	g_man.holding_hand.destroy()
	mp.set_quests_npcs()
	#var quest_servers = 
	mp.get_quest_objects(1)# 1 = id user
	QuestsManager.set_server_quest(21, false, 0)
	
	var t = terrain_tutorial.instantiate()
	g_man.main_menu.terrain = t
	g_man.main_menu.add_child(t)
	g_man.music_manager.set_music_type(MusicManager.MusicStatus.tutorial)
	g_man.main_menu.close_main_menu()
	g_man.tutorial = true
	
	g_man.inventory_system.generate_inventory_slots()
	
	g_man.holding_hand.holding_hand_movement()
