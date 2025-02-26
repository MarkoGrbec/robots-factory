class_name QuestsManager extends TabContainer

func _ready() -> void:
	g_man.quests_manager = self
	#get_parent().set_id_window(13, "quests manager")
	
	# Pick a voice. Here, we arbitrarily pick the first English voice.
	voices = DisplayServer.tts_get_voices_for_language("en")
	pass

func show_window():
	show()
	set_anchors()

func set_anchors():
	if is_visible_in_tree():
		if g_man.inventory_system.is_visible_in_tree():
			anchor_right = 0.609
		else:
			anchor_right = 1

func close_window():
	hide()
@export var quest_grid_container: GridContainer
@export var entity_button_quest: EntityButtonQuest
@export var stop_button_quest_scene: PackedScene
var array_stop_button_quest: Array[StopButtonQuest]

@export var ask_or_response_dialog: PackedScene
@export var answer_dialog: PackedScene
## for responce and questions
@export var dialog_container: VBoxContainer
@export var answer_container: GridContainer
### for automated scrolling
#@export var scroll_container: Control

var dict_name__server_quest: Dictionary[String, ServerQuest]
var dialogs = []
var answers = []
var _basic_dialog

var _quest_index
#region text to speach
# One-time steps.
var voices
#endregion text to speach


func open_dialog(quest_index, _c_p_q: CPQuest):
	show_window()
	# clear dialogs
	if _quest_index != quest_index:
		for dial in dialogs:
			dial.queue_free()
		dialogs.clear()
	# set quest index
	_quest_index = quest_index
	cmd_quest_dialog("", _quest_index)
	entity_button_quest.entity = _c_p_q.entity_inventory
	recount_entities()

func recount_entities():
	var array = array_stop_button_quest.duplicate()
	for stop in array:
		stop.queue_free()
	array_stop_button_quest.clear()
	var dict = entity_button_quest.entity.get_dict_count()
	for d in dict:
		d = dict.get(d)
		var node = stop_button_quest_scene.instantiate()
		node.change_texture_counter(d)
		quest_grid_container.add_child(node)
		array_stop_button_quest.push_back(node)

func add_response(quest_giver_name, response, basic_dialog, array_display_answers__response_size = []):
	if _basic_dialog != basic_dialog or basic_dialog.contains("hacking, ..."):
		_basic_dialog = basic_dialog
		response = [response, basic_dialog]
	
	if not dialogs:
		response = [basic_dialog]
	
	# normal quests
	current_tab = 0
	if not response is Array:
		response = [response]
	if response:
		add_dialogs(quest_giver_name, response)
		if voices:# TODO and g_man.options.speach_dialogs:
			var id = clampi(_quest_index, 0, voices.size() - 1)
			var voice_id = voices[id]
			DisplayServer.tts_stop()
			for resp in response:
				DisplayServer.tts_speak(resp, voice_id)
	# add answers
	for answer in answers:
		answer.queue_free()
	answers.clear()
	for answer__response_size in array_display_answers__response_size:
		var button: Button = answer_dialog.instantiate()
		answers.push_back(button)
		answer_container.add_child(button)
		button.text = str(answer__response_size[1], ": ", answer__response_size[0].replace("\"", "").replace("[", "").replace("]", "").replace(",", "").replace("\\", ""))
		button.pressed.connect(
			func():
				_on_ask_quester(button.text)
		)
	g_man.holding_hand.holding_hand_npc()

func _on_ask_quester(text: String):
	var avatar = g_man.user
	await add_dialogs(avatar.avatar_name, [text])
	# send to server a dialog
	cmd_quest_dialog(text, _quest_index)

func add_dialogs(name_a: String, text):
	for i in text.size():
		if text[i] == "":
			continue
		var dialog: Label = ask_or_response_dialog.instantiate()
		dialogs.push_back(dialog)
		dialog_container.add_child(dialog)
		dialog_container.move_child(dialog, 0)
		if i == 0:
			dialog.text = str("\n", name_a, ": ", text[i])
		else:
			dialog.text = str("\n", text[i])
		var tween = create_tween()
		dialog.visible_characters = 1
		var dialog_speed = dialog.text.length() * g_man.misc.slow_writing
		tween.tween_property(dialog, "visible_characters", dialog.text.length(), dialog_speed)
		await get_tree().create_timer(dialog_speed).timeout

func cmd_quest_dialog(raw_text: String, quest_index):
	if quest_index > 0:
		if quest_index == 7:
			# companion hacks in to other bots for qq avatar dialogs
			if raw_text.contains("hack"):
				var companion_name = mp.get_quest_object(quest_index).quest_name
				#var companion_quest: ServerQuest = dict_name__server_quest.get(companion_name)
				
				var array_name = raw_text.replace("hack", "").replace("]", "").split("[")
				var server_quest: ServerQuest
				if array_name.size() > 1:
					server_quest = dict_name__server_quest.get(array_name[1])
				else:
					server_quest = dict_name__server_quest.get(array_name[0])
				if server_quest and server_quest.body:
					var quest_object: QuestObject = mp.get_quest_object(server_quest._quest_index)
					var response_hack = ""
					for qq in quest_object.list_quest_basis[server_quest.basis].list_quest_questions:
						response_hack += str(qq.list_avatar_dialog, "\n")
					
					target_quest_response(quest_index, companion_name, response_hack, "hacking, ...")
					return
				if server_quest:
					target_quest_response(quest_index, companion_name, "I'm sorry but bot is gone at the moment\nyou want me to hack in to", "hacking, ... failed")
					return
				target_quest_response(quest_index, companion_name, "I'm sorry but I cannot find the bot\nyou want me to hack in to", "hacking, ... failed")
				return
		var q: ServerQuest = g_man.savable_multi_avatar__quest_data.new_data(1, quest_index)
		var response = q.ask(raw_text, null)
		if response:
			target_quest_response(quest_index, response[0][0], response[0][1], q.default_starting_dialog, response[3], response[4], response[5])
			# activate new quest giver
			if response[0] and response[1] and response[1].other_npcs:
				for npc in response[1].other_npcs:
					var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.new_data(1, npc.npc_activate)
					server_quest.basis = npc.npc_basis
					server_quest.activated = npc.npc_activated
					server_quest.alive = npc.npc_alive
					server_quest.save_basis()
					server_quest.save_activated()
					server_quest.save_position()
					#var ser_server_quests = Serializable.serialize([server_quest])
					target_send_quest_mob_to_make(server_quest)
			#if response[1] and response[1].reward:
				#var inventory: Entity =  node.client.playing_avatar.inventory
				#var reward = Entity.create_from_scratch(response[1].reward, true, false, true)
				#reward.add_to_parent(inventory, true, node)
			#target_refresh_quest_items.rpc_id(node.id_net, quest_index)
			

static func target_send_quest_mob_to_make(server_quest: ServerQuest):
	if not server_quest.activated:
		target_send_quest_mob_remove(server_quest)
		return
	if server_quest.body:
		return
	var quest_object = mp.get_quest_object(server_quest._quest_index)
	server_quest.body = mp.create_me(quest_object.quest_body_type)
	server_quest.body.patrol_targets = quest_object.patrol_targets
	server_quest.body.global_position = server_quest.position
	server_quest.body.quest_index = server_quest._quest_index
	server_quest.body.entity_inventory = server_quest.inventory
	server_quest.body.config()
	if server_quest.layer == g_man.tile_map_layers.active_layer:
		server_quest.body.show()
	else:
		server_quest.body.hide()

static func target_send_quest_mob_remove(server_quest: ServerQuest):
	if server_quest.body:
		server_quest.body.queue_free()

func target_quest_response(quest_index, quest_giver_name, response, basis_dial, success_old_basis = [], array_believe = [], array_display_answers__response_size = []):
	add_response(quest_giver_name, response, basis_dial, array_display_answers__response_size)
	var server_quest = g_man.savable_multi_avatar__quest_data.get_all(1, quest_index)
	if server_quest.body:
		if success_old_basis:
			server_quest.body.succeed_old_basis(success_old_basis)
		#if array_believe:
		server_quest.body.quest_believe(array_believe)

static func set_server_quest(quest_index: int, activated: bool, basis: int):
	var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.get_all(1, quest_index)
	if server_quest:
		server_quest.activated = activated
		server_quest.basis = basis
		server_quest.save_activated()
		server_quest.save_basis()
		target_send_quest_mob_to_make(server_quest)

static func get_server_quest_basis(quest_index: int):
	var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.get_all(1, quest_index)
	if server_quest:
		return server_quest.basis

static func get_server_quest(quest_index: int):
	var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.get_all(1, quest_index)
	return server_quest

static func add_server_quest_basis_flags(quest_index: int, flags: Array[int]):
	var server_quest: ServerQuest = get_server_quest(quest_index)
	if server_quest:
		server_quest.add_basis_flags(flags, true)

static func remove_server_quest_basis_flags(quest_index: int, flags: Array[int]):
	var server_quest: ServerQuest = get_server_quest(quest_index)
	if server_quest:
		server_quest.remove_basis_flags(flags, true)
