class_name QuestObject extends Resource

# Define an enum for TypeActivated
enum TypeActivated {
	ALIVE,
	DEAD,
	DEACTIVATE,
	ACTIVATED
}
@export_group("general")
@export var quest_name: String
@export var position: Vector2
@export var patrol_targets: Array[Vector2]
@export var layer: int = 0
@export_group("body")
@export var quest_body_type: Enums.Esprite = Enums.Esprite.mob_quest_client
@export var color: Color = Color.WHITE
@export var equipment: Enums.Esprite = Enums.Esprite.nul
@export var activated: bool = false
@export_group("quest")
@export var list_quest_basis: Array[QuestBasis]
@export var believe_l: float = 0
@export var believe_r: float = 1

var quest_index

#region open ai
#var api_key: String = ""
#var url: String = "https://api.openai.com/v1/chat/completions"
#var temperature: float = 0.5
#var max_tokens: int = 1024
#var headers = ["content-type: application/json", "Authorization: Bearer " + api_key]
#var model: String = "gpt-3.5-turbo"
#var messages = []
#var request: HTTPRequest
#
#func set_request(setting_request):
	#request = setting_request
	#request.request_completed.connect(on_request_completed)
	#
	#dialog_request("how to fuck")
#
#func dialog_request(player_dialogue):
	#messages.push_back(
		#{
			#"role": "user",
			#"content": player_dialogue
		#}
	#)
	#var body = JSON.new().stringify({
		#"messages": messages,
		#"temperature": temperature,
		#"max_tokens": max_tokens,
		#"model": model
	#})
	#var send_request = request.request(url, headers, HTTPClient.METHOD_POST)
	#print("does it even get here")
	#if send_request != OK:
		#push_error("there was an error sending message")
		#printerr("there was an error sending message")
#
#func on_request_completed(_result, _response_code, _headers, body):
	#var json:JSON = JSON.new()
	#json.parse(body.get_string_from_utf8())
	#var response = json.get_data()
	#var message = response["choices"][0]["message"]["content"]
	#
	#print(message)
#endregion open ai

# Create NPC on server-side
func generate_npc(index: int) -> void:
	quest_index = index

# Create NPC on server for client
func create_npc_with_avatar(id_avatar: int):
	var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.new_data(id_avatar, quest_index, 0)
	server_quest._quest_index = quest_index
	server_quest.fully_load()
	var qq_deep: QQDeep = g_man.savable_multi____quest___qq__qq.new_data(1, quest_index)
	g_man.quests_manager.dict_name__server_quest[quest_name] = server_quest
	server_quest.layer = layer
	if server_quest.activated and server_quest.initialized:
		return server_quest
	
	config(server_quest)
	if server_quest.activated:
		return server_quest

# Configure the NPC
func config(server_quest: ServerQuest) -> void:
	if not server_quest.initialized:
		server_quest.position = position
		server_quest.save_position()
		server_quest.activated = activated
		server_quest.load_inventory()
		server_quest.initialized = true
		server_quest.save_initialized()
		server_quest.save_activated()

# Get a quest question based on basis and text input
func get_quest_question(basis: int, text: String):
	if list_quest_basis.size() <= basis or basis < 0:
		push_error("NO quests for " + quest_name + ": " + str(basis) + ", count: " + str(list_quest_basis.size()))
		return null
	
	var q_basis = list_quest_basis[basis]
	potential_load_basis(basis)
	
	var qqs = q_basis.list_quest_questions
	
	var index = 0
	# Iterate over each item in the qq array
	for qq: QuestQuestion in qqs:
		# Check if any of the list_avatar_dialog items match the text
		var qq_from_avatar_dialogs = get_qq_from_avatar_dialogs(qq, text)
		if qq_from_avatar_dialogs:
			return [qq_from_avatar_dialogs, [index]]
		index += 1
	var array_indexes = []
	# get quest index row
	var id_row = g_man.savable_multi____quest___qq__qq.get_id_row(1, quest_index)
	# get basis row
	var qq_deeps = g_man.savable_multi____quest___qq__qq.get_all(id_row, basis +1)
	
	# get all other rows
	var qq_indexes = get_qq_from_deeps(qq_deeps, qqs, array_indexes, text)
	if qq_indexes:
		return qq_indexes
	return null

func get_qq_from_deeps(qq_deeps, qqs, array_indexes, text, ret = [null, array_indexes, 0, {}]):
	var i_indexed
	var index = 0
	if not qqs:
		ret = ret.duplicate()
		ret[2] = true
		return ret
	if qq_deeps:
		# get the right one for the answer
		for qq_deep in qq_deeps:
			for qq_flags in qqs[qq_deep.index -1].add_qq_flags:
				var qq_from_avatar_dialogs = get_qq_from_avatar_dialogs(qq_flags, text)
				if qq_from_avatar_dialogs:
					array_indexes.push_back(index)
					i_indexed = array_indexes.size()
					ret[0] = qq_from_avatar_dialogs
					#through = true
			index += 1
		# get deep in answers that have been explored in array_indexes
		explore_deep(qq_deeps, array_indexes, qqs, text, ret)
	
	# last one in row get 1 more deeper
	if not qq_deeps:
		index = 0
		var index_in_qq = 0
		for qq in qqs:
			array_indexes.push_back(index_in_qq)
			for qq_flag in qq.add_qq_flags:
				var qq_from_avatar_dialogs = get_qq_from_avatar_dialogs(qq_flag, text)
				if qq_from_avatar_dialogs:
					array_indexes.push_back(index)
					ret[0] = qq_from_avatar_dialogs
					#through = true
				else:
					array_indexes.pop_back()
				index += 1
			if not ret[0]:
				array_indexes.pop_back()
			index_in_qq += 1
	ret = ret.duplicate()
	#ret[2] = through
	return ret

func explore_deep(qq_deeps, array_indexes, qqs, text, ret):
	# get deep in answers that have been explored in array_indexes
	for qq_deep in qq_deeps:
		array_indexes.push_back(qq_deep.index -1)
		var qq_ds = g_man.savable_multi____quest___qq__qq.get_all(qq_deep.id, 0)
		var qq_from_avatar_dialogs = get_qq_from_deeps(qq_ds, qqs[qq_deep.index -1].add_qq_flags, array_indexes, text, ret)
		if not qq_from_avatar_dialogs[2]:
			array_indexes.pop_back()
		if qq_from_avatar_dialogs:
			return qq_from_avatar_dialogs

func get_qq_from_avatar_dialogs(qq, text):
	if qq.list_avatar_dialog.any(
		func(sentence):
			sentence = ServerQuest.make_raw(sentence)
			return all_words_match(sentence, text)
	):
		return qq

func index_quest_qustion(qq: QuestQuestion, basis: int):
	if list_quest_basis.size() <= basis or basis < 0:
		push_error("NO quests for " + quest_name + ": " + str(basis) + ", count: " + str(list_quest_basis.size()))
		return null
	return list_quest_basis[basis].list_quest_questions.find(qq)

# Check if all words match between two strings
func all_words_match(dialog_text: String, input_text: String) -> bool:
	var all_words: PackedStringArray = dialog_text.split(" ", true)
	var all_words_text: PackedStringArray = input_text.split(" ", true)
	
	##TODO work around a bug (function doesn't exist in PackedStringArray)
	var _all_words_text: Array[String]
	for word in all_words_text:
		_all_words_text.push_back(word)
	
	var count = all_words.size()
	
	for word in all_words:
		# check if any all_words are same as all_words_text
		if _all_words_text.any(
			func(a_word):
				return a_word == word
		):
			count -= 1
	return count == 0


# Potentially load basis questions
func potential_load_basis(basis: int) -> void:
	if list_quest_basis[basis].dict_quest_questions.size() == 0:
		list_quest_basis[basis].update_basis()
