class_name CreateMob extends Node

static var null_list_mob: NullList = NullList.new()

static func target_create_trader(trader: Trader, position: Vector2 = Vector2(300,300)):
	if trader.activated:
		if trader.body:
			return
		trader.body = mp.create_me(Enums.Esprite.mob_trader_client)
		trader.body.global_position = position
		trader.body.trader = trader


static func target_create_bot(global_position: Vector2, entity_num: Enums.Esprite,  index: int = -1):
	var bot: CPMob
	var mob: Mob
	if index != -1:# is made for loading
		# should never happen
		bot = null_list_mob.get_index_data(index)
		if not bot:
			bot = mp.create_me(entity_num)
		else:
			push_error(index, " cannot be made")
			printerr(index, " cannot be made")
		# get mob in to existance
		mob = g_man.savable_mob.get_index_data(index)
		# if mob actually doesn't exist
		if not mob:
			push_error(index, " mob doesn't exist")
			printerr(index, " mob doesn't exist")
			index = -1
		else:# set mob
			null_list_mob.set_index_data(index, bot)
	if index == -1:
		bot = mp.create_me(entity_num)
		if not bot:
			push_error("mob can't be made: ", Enums.Esprite.find_key(entity_num))
			printerr("mob can't be made: ", Enums.Esprite.find_key(entity_num))
			return
		# set data
		index = null_list_mob.set_data(bot)
		# overwrite mob
		if g_man.savable_mob.get_index_data(index):
			push_error("overwriting mob: ", index)
			printerr("overwriting mob: ", index)
		mob = g_man.savable_mob.set_index_data(index, Mob.new())
		mob.entity_num = entity_num
		mob.save_entity_num()
		mob.layer = g_man.tile_map_layers.active_layer
		mob.save_layer()
	# set bot
	bot.mob = mob
	bot.id_mob = index
	if global_position:
		bot.global_position = global_position
		mob.position = global_position
		mob.save_position()
	else:
		bot.global_position = mob.position
	return bot

static func target_create_enemy_bot(global_position: Vector2, entity_num: Enums.Esprite):
	var bot: CPMob = mp.create_me(entity_num)
	bot.global_position = global_position
	return bot
