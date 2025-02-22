class_name ServerQuest extends ISavable

#region savable
func copy():
	return ServerQuest.new()

func partly_save():
	pass

func fully_save():
	save_basis()
	save_basis_flags()
	save_mission()
	save_inventory()

func partly_load():
	pass

func fully_load():
	load_activated()
	load_position()
	load_basis()
	load_basis_flags()
	var q_obj = mp.get_quest_object(_quest_index)
	## go from beginning again
	if q_obj.list_quest_basis.size() <= basis:
		basis = 0
	default_starting_dialog = q_obj.list_quest_basis[basis].default_starting_dialog
	load_inventory()
	load_mission()
	load_mission_quantity()
	equipment_in_hand = q_obj.equipment
	load_initialized()
	array_believe = [0.0, 1.0]

func destroy():
	initialized = false
	save_initialized()
	print("destroy id server_quest: ", id)
	#region load
func load_initialized():
	initialized = DataBase.select(_server, g_man.dbms, _path, "initialized", id)

func load_inventory():
	inventory = DataBase.select(_server, g_man.dbms, _path, "inventory", id)
	if inventory != null:
		inventory = Entity.get_entity(inventory)
	else:
		inventory = Entity.create_from_scratch(Enums.Esprite.quest_inventory, true, false, false)
		save_inventory()

func load_activated():
	var _activated = DataBase.select(_server, g_man.dbms, _path, "activated", id)
	if _activated:# else it overwrites default activated
		activated = _activated

func load_position():
	var _position = DataBase.select(_server, g_man.dbms, _path, "position", id)
	if _position:# else it overwrites default activated
		position = Vector2(_position.x, _position.y)
	else:
		position = mp.get_quest_object(_quest_index).position

func load_basis():
	basis = DataBase.select(_server, g_man.dbms, _path, "basis", id, 0)
	#basis = 0

func load_basis_flags():
	basis_flags = DataBase.select(_server, g_man.dbms, _path, "basis_flags", id, basis_flags)
	
func load_mission():
	var keys = DataBase.select(_server, g_man.dbms, _path, "mission_keys", id)
	var values = DataBase.select(_server, g_man.dbms, _path, "mission_values", id)
	if keys:
		for i in keys.size():
			dict_mission__entity_num[keys[i]] = values[i]

func load_mission_quantity():
	mission_quantity = DataBase.select(_server, g_man.dbms, _path, "mission_quantity", id)
	if not mission_quantity:
		mission_quantity = 0
	#endregion
	#region save
func save_initialized():
	DataBase.insert(_server, g_man.dbms, _path, "initialized", id, initialized)

func save_inventory():
	if inventory:
		DataBase.insert(_server, g_man.dbms, _path, "inventory", id, inventory.id)
	else:
		DataBase.insert(_server, g_man.dbms, _path, "inventory", id, null)

func save_activated():
	DataBase.insert(_server, g_man.dbms, _path, "activated", id, activated)

func save_position():
	DataBase.insert(_server, g_man.dbms, _path, "position", id, position)

func save_basis() -> void:
	DataBase.insert(_server, g_man.dbms, _path, "basis", id, basis)

func save_basis_flags() -> void:
	DataBase.insert(_server, g_man.dbms, _path, "basis_flags", id, basis_flags)

func save_mission():
	var keys = dict_mission__entity_num.keys()
	var values: Array[Enums.Esprite]
	for key in keys:
		values.push_back(dict_mission__entity_num[key])
	DataBase.insert(_server, g_man.dbms, _path, "mission_keys", id, keys)
	DataBase.insert(_server, g_man.dbms, _path, "mission_values", id, values)
	save_mission_quantity()
	
func save_mission_quantity():
	DataBase.insert(_server, g_man.dbms, _path, "mission_quantity", id, mission_quantity)
	#endregion save
#endregion savable



# Properties
var body: CPQuest
var initialized = false
var activated: bool = false
var alive: bool = true
var _quest_index: int = 1
var position
var layer: int
var id_avatar: int
var default_starting_dialog: String
var basis = 0
var added_items: Array = []
var inventory
var equipment_in_hand: Enums.Esprite = Enums.Esprite.nul
var dict_mission__entity_num: Dictionary[String, Enums.Esprite]
var mission_quantity
var basis_flags = []
var array_believe: Array[float]

## basis -> qq_index -> index
var array_response_dialog_index: Array[int]
## display_answers
var array_answers__response_size: Array[String]
#region completting mission
func mission_completing(dict_string_mission__Entity_sprite: Dictionary):
	if dict_mission__entity_num and mission_quantity:
		var keys = dict_string_mission__Entity_sprite.keys()
		# string
		for key in keys:
			# entity_num
			var value = dict_mission__entity_num.get(key)
			if value:
				var compare_value = dict_string_mission__Entity_sprite.get(key)
				if value == compare_value:
					mission_quantity -= 1
					if mission_quantity <= 0:
						dict_mission__entity_num.clear()
						save_mission()
					else:
						save_mission_quantity()

func mission_failing_quest(dict_string_mission__Entity_sprite: Dictionary):
	var keys = dict_string_mission__Entity_sprite.keys()
	# string
	for key in keys:
		# entity_num
		var value =  dict_mission__entity_num.get(key)
		if value: # if key and value exists add to quantity
			var compare_value = dict_string_mission__Entity_sprite.get(key)
			if value == compare_value:
				mission_quantity += 1
				save_mission_quantity()
		else: # add all keys that don't exist
			value = dict_string_mission__Entity_sprite.get(key)
			dict_mission__entity_num.set(key, value)
			mission_quantity = 1
			save_mission()
#endregion completting mission
#region ask
func delete_chars(chars: Array[String], raw_text: String):
	for ch in chars:
		raw_text = raw_text.replace(ch, "")
	return raw_text

## return [[name], [response]], [quest_question], [inventory.id], [[success.old_basis], [qq_index]], [failed.old_basis], [array_answers__response_size]
func ask(raw_text: String, client) -> Array:
	var avatar_name = g_man.user.avatar_name
	raw_text = raw_text.to_lower()
	raw_text = delete_chars(["?", "!", ",", ".", ";", ":"], raw_text)
	var q_obj: QuestObject = mp.get_quest_object(_quest_index)
	if q_obj.list_quest_basis.size() > basis:
		default_starting_dialog = q_obj.list_quest_basis[basis].default_starting_dialog
		default_starting_dialog = default_starting_dialog.replace("[name]", avatar_name)
	if not raw_text:
		if q_obj.list_quest_basis.size() > basis:
			get_display_answers_all()
		return [[q_obj.quest_name, ""], null, inventory.id, [], array_believe, array_answers__response_size]
	
	if raw_text.find("fuck you") != -1:
		basis = -1
		default_starting_dialog = q_obj.list_quest_basis[basis].default_starting_dialog
		default_starting_dialog = default_starting_dialog.replace("[name]", avatar_name)
		return [[q_obj.quest_name, "don't be that mean to me I can revenge on you if you. Are on main quest line it means it's game over for you. You need to start from beginning again"], null, inventory.id, [], array_believe, array_answers__response_size]
	
	
	push_warning(raw_text, basis)
	# general basis
	var qq: QuestQuestion = q_obj.get_quest_question(basis, raw_text)
	var response_dialog
	var general_basis: bool = true
	
	# if first general basis failed
	if not qq:
		general_basis = false
		# loop through other basis
		for flag in basis_flags:
			qq = q_obj.get_quest_question(flag, raw_text)
			if qq:
				break
	if not qq:
		if not q_obj.list_quest_basis.size() > basis:
			# failed
			push_error(str(q_obj.quest_name, " not implemented exeption basis: ", basis))
			printerr(str(q_obj.quest_name, " not implemented exeption basis: ", basis))
			return [[q_obj.quest_name, str("not implemented exeption basis: ", basis)], null, inventory.id, [], array_believe, array_answers__response_size]
		var default_failed_dialog = q_obj.list_quest_basis[basis].default_failed_dialog
		if not default_failed_dialog:
			default_failed_dialog = "what do you mean?"
		response_dialog = [q_obj.quest_name, default_failed_dialog, false]
	elif general_basis and not (check_items_integrity(qq, client) and mission_quantity == 0):
		# failed
		var array_old_basis__qq_index
		if q_obj.list_quest_basis[basis].fail_passes:
			failed_believe()
			array_old_basis__qq_index = [basis, q_obj.index_quest_qustion(qq, basis)]
			set_new_basis(qq, q_obj, general_basis, avatar_name)
		
		get_display_answers_all()
		if qq.response_failed_dialog:
			return [[q_obj.quest_name, qq.response_failed_dialog], qq, inventory.id, [], array_believe, array_answers__response_size]
		else:
			return [[q_obj.quest_name, str("I'm sorry I need more quality items", mission_quantity)], null, inventory.id, [], array_believe, array_answers__response_size]
	# success
	else:
		succeed_believe()
		var array_old_basis__qq_index: Array = [basis, q_obj.index_quest_qustion(qq, basis)]
		# add name in to the response dialog
		var qq_response_dialog = get_response_dialog(qq, array_old_basis__qq_index[1], avatar_name)
		response_dialog = [q_obj.quest_name, qq_response_dialog]
		
		set_new_basis(qq, q_obj, general_basis, avatar_name)
		get_display_answers_all()
		return [response_dialog, qq, inventory.id, array_old_basis__qq_index, array_believe, array_answers__response_size]
	get_display_answers_all()
	# fail
	return [response_dialog, qq, inventory.id, [], array_believe, array_answers__response_size]

func get_display_answers_all():
	array_answers__response_size.clear()
	get_display_answers(basis)
	for flag in basis_flags:
		get_display_answers(flag)

func get_display_answers(basis_index: int):
	var q_obj: QuestObject = mp.get_quest_object(_quest_index)
	if q_obj.list_quest_basis.size() > basis_index:
		var _basis: QuestBasis = q_obj.list_quest_basis[basis_index]
		if _basis.display_answers:
			for basis_qq: QuestQuestion in _basis.list_quest_questions:
				array_answers__response_size.push_back([str(basis_qq.list_avatar_dialog), basis_qq.response_dialog.size()])
	

## sets new basis and default starting dialog
func set_new_basis(qq: QuestQuestion, q_obj: QuestObject, general_basis: int, avatar_name: String):
	# if non from pool keep basis
	var new_basis = basis
	# get one basis from the pool
	if qq.new_basis:
		new_basis = qq.new_basis[randi_range(0, qq.new_basis.size() -1)]
	# if char likes player set new_basis from pool or same as before (basis)
	if not new_basis == -1:
		# add remove flags
		add_basis_flags(qq.add_basis_flags)
		remove_basis_flags(qq.remove_basis_flags, true)
		if basis != new_basis:
			
			added_items.clear()
			if general_basis:
				basis = new_basis
			save_basis()
			# next round
			# only if different basis
			if q_obj.list_quest_basis.size() > basis:
				get_display_answers_all()
				default_starting_dialog = q_obj.list_quest_basis[basis].default_starting_dialog
				default_starting_dialog = default_starting_dialog.replace("[name]", avatar_name)
				# default mission
				dict_mission__entity_num = q_obj.list_quest_basis[basis].dict_mission__entity_num
				mission_quantity = q_obj.list_quest_basis[basis].mission_quantity
				save_mission()
	else:# he doesn't like the character any longer
		basis = new_basis
		save_basis()

func succeed_believe():
	#if g_man.user.believe_in_god:
	believe_to_right()
	#else:
		#believe_to_left()

func failed_believe():
	#if g_man.user.believe_in_god:
	believe_to_left()
	#else:
		#believe_to_right()

func believe_to_right():
	if array_believe[1] > 0.99:
		array_believe[0] = clampf(array_believe[0] + 0.4, 0, 0.99)
	else:
		array_believe[1] = clampf(array_believe[1] + 0.4, 0, 1)

func believe_to_left():
	if array_believe[0] < 0.01:
		array_believe[1] = clampf(array_believe[1] - 0.4, 0.01, 1)
	else:
		array_believe[0] = clampf(array_believe[0] - 0.4, 0, 0.99)

func add_basis_flags(array: Array[int], save: bool = false):
	for add_flag in array:
		if not basis_flags.has(add_flag):
			basis_flags.push_back(add_flag)
	if save:
		save_basis_flags()

func remove_basis_flags(array: Array[int], save: bool = false):
	for remove_flag in array:
		basis_flags.erase(remove_flag)
	if save:
		save_basis_flags()

func get_response_dialog(qq: QuestQuestion, qq_index, avatar_name: String):
	# reset reponse dialog to 0 if needed
	if not array_response_dialog_index:
		reset_array_response_dialog(qq_index)
	else:
		if not array_response_dialog_index[0] == basis:
			reset_array_response_dialog(qq_index)
		elif not array_response_dialog_index[1] == qq_index:
			reset_array_response_dialog(qq_index)
	
	# next response dialog
	if qq.response_dialog:
		if qq.response_dialog.size() <= array_response_dialog_index[2]:
			array_response_dialog_index[2] = 0
		
		var qq_response_dialog = qq.response_dialog[array_response_dialog_index[2]]
		array_response_dialog_index[2] += 1
		
		# set name of avatar
		return qq_response_dialog.replace("[name]", avatar_name)
	else:
		return ""

func reset_array_response_dialog(qq_index):
	array_response_dialog_index = [basis, qq_index, 0]

func check_items_integrity(qq, _client) -> bool:
	if qq.quantity == 0:
		return true
	var quantity: int = qq.quantity
	var to_destroy: Array = []
	for entity in inventory.e_container:
		if entity.entity_num == qq.quest_item:
			#if entity.ql * (1 - entity.damage / 1000) >= qq.ql:
				#if entity.per_ratio > Entity.MIN_WEIGHT_PERCENT and entity.per_ratio < Entity.MAX_WEIGHT_PERCENT:
					# TODO to_dastroy...
					# TODO	...break
			to_destroy.push_back(entity)
			quantity -= 1
			if quantity <= 0:
				break
	if quantity <= 0:
		for t in to_destroy:
			#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [t.id])
			t.destroy_me()
			g_man.quests_manager.recount_entities()
		return true
	return false
#endregion ask
#region serialize
func serialize():
	var data = []
	data.push_back(_quest_index)
	data.push_back(inventory.id)
	data.push_back(position)
	data.push_back(mp.get_quest_object(_quest_index).quest_body_type)
	data.push_back(activated)
	data.push_back(equipment_in_hand)
	return data
#endregion serialize
