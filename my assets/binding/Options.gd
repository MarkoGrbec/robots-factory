class_name Options extends Node

func _ready() -> void:
	g_man.options = self
	


@export var new_password: LineEdit
@export var confirm_password: LineEdit
@export var old_password: LineEdit
@export var other_computers_can_come_in: CheckBox
@export var other_clients_can_come_in: CheckBox
@export var speach_dialogs: CheckBox
@export var font_size_text: LineEdit
@export var look_sensitivity_text: LineEdit
@export var look_y_sensitivity_text: LineEdit
@export var look_x_sensitivity_text: LineEdit
@export var font_size: Theme

@export var binding_buttons: Array[BindingKey]

@export var disable_binding_button: Button

@export var audio_container: Control

#region security
#func on_submit_security():
	#if old_password.text:
		#if new_password.text:
			#if new_password.text == confirm_password.text:
				#var encrypt:EncriptData = g_man.local_network_node.encrypted
				#
				#var new_enc_pass = EncriptData.synchronous_encrypting(new_password.text, encrypt.secret_key)
				#var old_enc_pass = EncriptData.synchronous_encrypting(old_password.text, encrypt.secret_key)
				#
				#g_man.local_network_node.cmd_change_security.rpc_id(1,
					#other_clients_can_come_in.button_pressed,
					#other_computers_can_come_in.button_pressed,
					#old_enc_pass,
					#new_enc_pass
				#)
		#else:
			#var encrypt:EncriptData = g_man.local_network_node.encrypted
				#
			#var old_enc_pass = EncriptData.synchronous_encrypting(old_password.text, encrypt.secret_key)
			#
			#g_man.local_network_node.cmd_change_security.rpc_id(1,
				#other_clients_can_come_in.button_pressed,
				#other_computers_can_come_in.button_pressed,
				#old_enc_pass,
				#0
			#)
		#update_can_get_in()
func update_can_get_in():
	g_man.local_network_node.client.other_client_can_get_in = other_clients_can_come_in.button_pressed
	g_man.local_network_node.client.other_computers_can_get_in = other_computers_can_come_in.button_pressed

func update_from_client():
	other_clients_can_come_in.button_pressed = g_man.local_network_node.client.other_client_can_get_in
	other_computers_can_come_in.button_pressed = g_man.local_network_node.client.other_computers_can_get_in

func on_ban_or_approve_mac():
	g_man.welcome_unwelcome_window.show_window(true)
#endregion security
#region binding
var change_input_map := ""
var binding_label

enum keys{
	forward = 1,
	back = 2,
	left = 3,
	right = 4,
	jump = 5,
	entity_stuff = 6,
	construction_stuff = 7,
	experience = 8,
	stop_work = 9,
	fire = 10,
	combat = 11,
	dataBase = 12,
}

func load_keys():
	for binding_key in binding_buttons:
		load_key(str(keys.find_key(binding_key.index)).replace("_", " "))
		var input_event = InputMap.action_get_events(str(keys.find_key(binding_key.index)).replace("_", " "))
		if input_event:
			binding_key.set_binding_label(input_event[0].as_text().replace(" (Physical)", ""))
		

func load_key(key_string):
	#print("[", key_string, "]")
	# make column if it doesn't exist yet
	var table = DataBase.Table.new("bindings")
	table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, key_string)
	# get keycode if it exists
	var keycode = DataBase.select(false, g_man.dbms, "bindings", key_string, g_man.local_network_node.client.id)
	if keycode:
		# keyboard
		if keycode > 5:
			var event_key:InputEventKey = InputEventKey.new()
			event_key.keycode = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)
		# mouse
		else:
			var event_key:InputEventMouseButton = InputEventMouseButton.new()
			event_key.button_index = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)

func disable_binding():
	change_input_map = str(keys.find_key(binding_label.index)).replace("_", " ")
	InputMap.action_erase_events(change_input_map)
	binding_label.set_binding_label(str("N/A"))
	change_input_map = ""
	disable_binding_button.hide()

func change_binding(index:int, label:BindingKey):
	# label we will change on finished binding
	binding_label = label
	# function that will be called on end of binding
	finished = _finish_binding
	# input map name
	change_input_map = str(keys.find_key(index)).replace("_", " ")
	disable_binding_button.show()

func _finish_binding(event):
	if binding_label:
		binding_label.set_binding_label(str(event.as_text()))
	if event is InputEventKey:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, g_man.local_network_node.client.id, event.keycode)
	elif event is InputEventMouseButton:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, g_man.local_network_node.client.id, event.button_index)

var finished:Callable

func _input(event):
	# change binding
	if change_input_map:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_released():
				InputMap.action_erase_events(change_input_map)
				InputMap.action_add_event(change_input_map, event)
				finished.call(event)
				change_input_map = ""
				disable_binding_button.hide()
#endregion binding
#region dialogs
func load_speach_dialogs():
	var speach = DataBase.select(false, g_man.dbms, "options", "dialogs", g_man.local_network_node.client.id)
	if speach:
		speach_dialogs.button_pressed = speach

func _toggle_speach_dialogs(yes: bool):
	DataBase.insert(false, g_man.dbms, "options", "dialogs", g_man.local_network_node.client.id, yes)
#endregion
#region options
func load_options():
	look_sensitivity_text.text = str(DataBase.select(false, g_man.dbms, "options", "c_sensitivity", g_man.local_network_node.client.id, 0.125))
	look_y_sensitivity_text.text = str(DataBase.select(false, g_man.dbms, "options", "c_y_sensitivity", g_man.local_network_node.client.id, 1))
	look_x_sensitivity_text.text = str(DataBase.select(false, g_man.dbms, "options", "c_x_sensitivity", g_man.local_network_node.client.id, -1))

func _sensitivity_value_changed(sensitivity: String):
	DataBase.insert(false, g_man.dbms, "options", "c_sensitivity", g_man.local_network_node.client.id, float(sensitivity))

func _sensitivity_y_value_changed(sensitivity: String):
	DataBase.insert(false, g_man.dbms, "options", "c_y_sensitivity", g_man.local_network_node.client.id, float(sensitivity))

func _sensitivity_x_value_changed(sensitivity: String):
	DataBase.insert(false, g_man.dbms, "options", "c_x_sensitivity", g_man.local_network_node.client.id, float(sensitivity))

func load_font_size():
	var size = DataBase.select(false, g_man.dbms, "options", "c_font_size", g_man.local_network_node.client.id)
	if size:
		font_size.default_font_size = size
		font_size_text.text = str(size)

func _on_font_size_change(new_text: String) -> void:
	var size = int(new_text)
	size = clampi(size, 10, 50)
	font_size.default_font_size = size
	DataBase.insert(false, g_man.dbms, "options", "c_font_size", g_man.local_network_node.client.id, size)
#endregion options
#region save system
## from g_man sucessfully login
func fully_load():
	load_keys()
	load_speach_dialogs()
	load_options()
	load_font_size()
	#load_audio()
#endregion save system
#region audio
	#region load
#func load_audio():
	#for audio in audio_container.get_children():
		#if audio is AudioBusVolume:
			#audio.load_audio()
	#endregion load
#endregion audio
