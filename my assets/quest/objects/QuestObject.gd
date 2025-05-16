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
@export_group("debug")
@export var reset: bool = false
@export var debug_basis: int
@export var debug_activated: bool = true

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
	#var qq_deep: QQDeep = 
	g_man.savable_multi____quest___qq__qq.new_data(1, quest_index)
	g_man.quests_manager.dict_name__server_quest[quest_name] = server_quest
	# quest loaded activated and initialized
	# if reset go config it first
	if server_quest.activated and server_quest.initialized and not reset:
		return server_quest
	
	# if reset always config it and return if it should be activated
	config(server_quest)
	if server_quest.activated:
		return server_quest

# Configure the NPC
func config(server_quest: ServerQuest) -> void:
	if not server_quest.initialized or reset:
		server_quest.position = position
		server_quest.save_position()
		server_quest.activated = activated
		server_quest.load_inventory()
		server_quest.initialized = true
		server_quest.save_initialized()
		server_quest.save_activated()
		if reset:
			server_quest.basis = debug_basis
			server_quest.save_basis()
			server_quest.activated = debug_activated
			server_quest.save_activated()

# Get a quest question based on basis and text input
func get_quest_question(basis: int, text: String, qq_flags: Dictionary = {}):
	if list_quest_basis.size() <= basis or basis < 0:
		push_error("NO quests for " + quest_name + ": " + str(basis) + ", count: " + str(list_quest_basis.size()))
		return null
	
	var q_basis = list_quest_basis[basis]
	potential_load_basis(basis)
	
	var qqs: Array[QuestQuestion] = q_basis.list_quest_questions
	
	var qq_from_avatar_dialogs = []
	#var index = 0
	# Iterate over each item in the qq array
	var i: int = 0
	for qq: QuestQuestion in qqs:
		var _flags = qq_flags.get_or_add(basis, {})
		# Check if any of the list_avatar_dialog items match the text
		qq_from_avatar_dialogs = get_qq_from_avatar_dialogs(qq, text)
		if qq_from_avatar_dialogs:
			_flags.get_or_add(i, {})
			return [qq_from_avatar_dialogs, {}]
		i += 1
		#index += 1
	## get quest index row
	#var qq_deeps_quest = g_man.savable_multi____quest___qq__qq.get_all(1, quest_index)
	## get basis row
	#var qq_deeps_basis = g_man.savable_multi____quest___qq__qq.get_all(qq_deeps_quest[0].id, basis +1)
	#var qq_deeps = []
	#if qq_deeps_basis:
		#qq_deeps = g_man.savable_multi____quest___qq__qq.get_all(qq_deeps_basis[0].id, 0)
	## get all other rows
	#
	qq_from_avatar_dialogs = []
	var dict_indexes = {}
	
	
	var flags = qq_flags.get(basis)
	if flags:
		qq_from_avatar_dialogs = get_qq_from_deeps2(flags, qqs, text, qq_from_avatar_dialogs, dict_indexes, 0)
	if qq_from_avatar_dialogs:
		qq_from_avatar_dialogs = qq_from_avatar_dialogs[0]
	return [qq_from_avatar_dialogs, dict_indexes]

## get answers from deep inside
@warning_ignore("unused_parameter")
func get_qq_from_deeps2(qq_flags: Dictionary, qqs: Array[QuestQuestion], text, qq_from_avatar_dialogs, dict_indexes: Dictionary, deep_basis_index):
	for flag in qq_flags:
		var dict = qq_flags.get(flag)
		var i: int = 0
		for deep in qqs:
			if i == flag:
				var dialog = get_qq_from_avatar_dialogs(deep, text)
				if dialog:
					qq_from_avatar_dialogs = [dialog, {}]
					return qq_from_avatar_dialogs
				else:
					var ii: int = 0
					for deep_i in deep.add_qq_flags:
						dialog = get_qq_from_avatar_dialogs(deep_i, text)
						if dialog:
							dict.get_or_add(ii, {})
							qq_from_avatar_dialogs = [dialog, {}]
							return qq_from_avatar_dialogs
						ii += 1
				var got = get_qq_from_deeps2(dict, deep.add_qq_flags, text, qq_from_avatar_dialogs, dict_indexes, i)
				if got:
					return got
			i += 1

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

# bog je stvarnik ki je ustvaril svet.
# ni viden brez njega nekaj ni se zgodilo nekaj se je moralo zgoditi da smo tu a dejansko ga ne vidimo.
# človek ki ga ne srečujemo a ga samo čutimo.

# to je nevidna struktura
# verjamemo vanj ker ga čutimo

# ker bog je ljubezen čutimo ljubezen zaradi njega živimo zaradi njega
# ustvaril je rojstvo živimo umremo
# hodimo v cerkev da ga začutimo
# menihi molijo v budo
# molijo da bi pozitivno energijo dobili v sebe

# na svetu je dosti trpljenja a ga ni ustvaril bog
# bog zeos on je oče od jezusa
# da verujemo v božička ker se je takrat rodil jezus marija je bila spočeta brezmadežno
# to naj bi bil oče
# sprejel jožef za ženo in sta dobila jezusa zato mi verujemo v boga

# za veliko noč je jezusa vprašali če veruje v boga in so ga križali
# če bi rekel da veruje bi bil živ
# jajce hren meso nesemo k žegnu
# vino je jezusova kri
# 
# jezus je vstal od mrtvih za veliko noč


# moramo ga čutit ker ga dejansko ni
# nimamo možnosti ga spoznavati ga videti se pogovoriti z njim mu zaupati
# neka sila je morala biti za stvarnost
# eni pravijo da so najprej nastali možgani
# in možgani delajo telo
# kdo je pa ustvaril možgane?
# ne raziskani organ privid
# možgani nas delajo vidne
# s pomožjo možganov mi verujemo v boga ki ga ni
# otrok je čudež zato so otroci čudeži vsakemu pikecu je isti plod in je čudež da se je razvil iz istega polda v veliko zver to je ustvaril bog.
# bog je ustvaril adama in eveo
# bila sta v raju adam ji pravi jst sm lačn
# kača je rekla da naj odtrga jabolko iz drevesa
# morata jesti meso
# bog jo je kaznoval da bo rojevala v bolečinah
# moški pa 
