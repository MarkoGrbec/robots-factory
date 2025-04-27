class_name Bindings extends Node

func _ready() -> void:
	g_man.bindings = self
	load_keys()

#@export var speach_dialogs: CheckBox
## to load all the bindings
@export var bindings_container: VBoxContainer

@export var disable_binding_button: Button
#region binding
var change_input_map := ""
var binding_label
var binding_pri_sec_ter

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
	for binding_key in bindings_container.get_children():
		if binding_key is BindingKey:
			# load key
			var done = load_key(binding_key, str(keys.find_key(binding_key.index)).replace("_", " "), binding_key.default)
			if not done:
				# set label
				var input_event = InputMap.action_get_events(str(keys.find_key(binding_key.index)).replace("_", " "))
				if input_event:
					for i in input_event.size():
						binding_key.set_binding(i, input_event[i], str(input_event[i].as_text().replace(" (Physical)", "")))

func load_key(binding_key: BindingKey, key_string, default = false):
	if default:
		return
	#print("[", key_string, "]")
	# make column if it doesn't exist yet
	var table = DataBase.Table.new("bindings")
	
	var loaded_once = false
	for i in range(2, -1, -1):
		table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, str(key_string, i))
		table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, str(key_string, "_type", i))
		
		# get keycode if it exists
		var keycode = DataBase.select(false, g_man.dbms, "bindings", str(key_string, i), 1, -10)
		var keytype = DataBase.select(false, g_man.dbms, "bindings", str(key_string, "_type", i), 1, -10)
		if keycode != -10:
			# keyboard
			if keytype == 0:
				loaded_once = loaded_once_binding(loaded_once, key_string)
				
				var event_key:InputEventKey = InputEventKey.new()
				event_key.keycode = keycode
				InputMap.action_add_event(key_string, event_key)
				binding_key.set_binding(i, event_key, event_key.as_text())
			# mouse
			elif keytype == 1:
				loaded_once = loaded_once_binding(loaded_once, key_string)
				
				var event_key:InputEventMouseButton = InputEventMouseButton.new()
				event_key.button_index = keycode
				InputMap.action_add_event(key_string, event_key)
				binding_key.set_binding(i, event_key, event_key.as_text())
			elif keytype == 2:
				loaded_once = loaded_once_binding(loaded_once, key_string)
				
				var event_key:InputEventJoypadButton = InputEventJoypadButton.new()
				event_key.button_index = keycode
				InputMap.action_add_event(key_string, event_key)
				binding_key.set_binding(i, event_key, event_key.as_text())
			elif keytype == 3:
				loaded_once = loaded_once_binding(loaded_once, key_string)
				
				var event_key:InputEventJoypadMotion = InputEventJoypadMotion.new()
				event_key.axis = keycode
				InputMap.action_add_event(key_string, event_key)
				binding_key.set_binding(i, event_key, event_key.as_text())
			else:
				g_man.changes_manager.add_change(str("load key: ", key_string, " : ", keytype, " : ", keycode))
	# if loaded at least once don't make new text input map
	return loaded_once

func loaded_once_binding(loaded, key_string):
	if not loaded:
		InputMap.action_erase_events(key_string)
	return true

func disable_binding():
	if binding_label:
		change_input_map = str(keys.find_key(binding_label.index)).replace("_", " ")
		for i in 3:
			binding_label.set_binding(i, null, str("N/A"))
			DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, i), 1, -10)
			DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, "_type", i), 1, -10)
		
		InputMap.action_erase_events(change_input_map)
		change_input_map = ""
		disable_binding_button.hide()

func change_binding(index:int, label:BindingKey, pri_sec_ter: int = 0):
	# label we will change on finished binding
	binding_label = label
	#set which one will be changed
	binding_pri_sec_ter = pri_sec_ter
	# function that will be called on end of binding
	finished = _finish_binding
	# input map name
	change_input_map = str(keys.find_key(index)).replace("_", " ")
	
	disable_binding_button.show()

func _finish_binding(event):
	if binding_label:
		binding_label.set_binding(binding_pri_sec_ter, event, str(event.as_text()))
	
	var change_input_map__type = str(change_input_map, "_type")
	if event is InputEventKey:
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, binding_pri_sec_ter), 1, event.keycode)
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map__type, binding_pri_sec_ter), 1, 0)
		g_man.changes_manager.add_change(str(change_input_map, " key button: ", event.keycode))
		
	elif event is InputEventMouseButton:
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, binding_pri_sec_ter), 1, event.button_index)
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map__type, binding_pri_sec_ter), 1, 1)
		g_man.changes_manager.add_change(str("1 button index: ", event.button_index))
		
	elif event is InputEventJoypadButton:
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, binding_pri_sec_ter), 1, event.button_index)
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map__type, binding_pri_sec_ter), 1, 2)
		g_man.changes_manager.add_change(str("2 button index: ", event.button_index))
		
	elif event is InputEventJoypadMotion:
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map, binding_pri_sec_ter), 1, event.axis)
		DataBase.insert(false, g_man.dbms, "bindings", str(change_input_map__type, binding_pri_sec_ter), 1, 3)
		g_man.changes_manager.add_change(str("3 axis index: ", event.axis))

var finished:Callable

func _input(event):
	# change binding
	if change_input_map:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event.is_released():
				InputMap.action_erase_event(change_input_map, binding_label.array_events[binding_pri_sec_ter])
				InputMap.action_add_event(change_input_map, event)
				finished.call(event)
				change_input_map = ""
				disable_binding_button.hide()
#endregion binding
