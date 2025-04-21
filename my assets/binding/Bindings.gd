class_name Bindings extends Node

func _ready() -> void:
	g_man.bindings = self
	load_keys()

@export var speach_dialogs: CheckBox
@export var binding_buttons: Array[BindingKey]

@export var disable_binding_button: Button
#region binding
var change_input_map := ""
var binding_label

enum keys{
	move_up = 1,
	move_down = 2,
	move_left = 3,
	move_right = 4,
	walk = 5,
	fire = 6,
	select = 7,
	put_back_material = 8,
	inventory = 9,
	stop_work = 10,
	changes = 11,
	plus_stack = 12,
	minus_stack = 13,
	stats = 14,
	esc = 15,
}

func load_keys():
	for binding_key in binding_buttons:
		load_key(str(keys.find_key(binding_key.index)).replace("_", " "), binding_key.default)
		var input_event = InputMap.action_get_events(str(keys.find_key(binding_key.index)).replace("_", " "))
		if input_event:
			binding_key.set_binding_label(input_event[0].as_text().replace(" (Physical)", ""))

func load_key(key_string, default = false):
	if default:
		return
	#print("[", key_string, "]")
	# make column if it doesn't exist yet
	var table = DataBase.Table.new("bindings")
	table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, key_string)
	table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, str(key_string, "_type"))
	# get keycode if it exists
	var keycode = DataBase.select(false, g_man.dbms, "bindings", key_string, 1, -10)
	var keytype = DataBase.select(false, g_man.dbms, "bindings", str(key_string, "_type"), -10)
	if keycode != -10:
		# keyboard
		if keytype == 0:
			var event_key:InputEventKey = InputEventKey.new()
			event_key.keycode = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)
		# mouse
		elif keytype == 1:
			var event_key:InputEventMouseButton = InputEventMouseButton.new()
			event_key.button_index = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)
		elif keytype == 2:
			var event_key:InputEventJoypadButton = InputEventJoypadButton.new()
			event_key.button_index = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)
		elif keytype == 3:
			var event_key:InputEventJoypadMotion = InputEventJoypadMotion.new()
			event_key.axis = keycode
			InputMap.action_erase_events(key_string)
			InputMap.action_add_event(key_string, event_key)

func disable_binding():
	if binding_label:
		change_input_map = str(keys.find_key(binding_label.index)).replace("_", " ")
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, 1, -10)
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, "_type"), 1, -10)
		
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
	
	var change_input_map__type = str(change_input_map, "_type")
	if event is InputEventKey:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, 1, event.keycode)
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map__type, 1, 0)
	elif event is InputEventMouseButton:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, 1, event.button_index)
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map__type, 1, 1)
		
		g_man.changes_manager.add_change(str("1 button index: ", event.button_index))
	elif event is InputEventJoypadButton:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, 1, event.button_index)
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map__type, 1, 2)
		
		g_man.changes_manager.add_change(str("2 button index: ", event.button_index))
	elif event is InputEventJoypadMotion:
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map, 1, event.axis)
		DataBase.insert(false, g_man.dbms, "bindings", change_input_map__type, 1, 3)
		
		g_man.changes_manager.add_change(str("2 button index: ", event.axis))

var finished:Callable

func _input(event):
	# change binding
	if change_input_map:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event.is_released():
				InputMap.action_erase_events(change_input_map)
				InputMap.action_add_event(change_input_map, event)
				finished.call(event)
				change_input_map = ""
				disable_binding_button.hide()
#endregion binding
