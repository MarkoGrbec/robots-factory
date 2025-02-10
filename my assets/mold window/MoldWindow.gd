class_name MoldWindow extends TabContainer

@export var parent: WindowManager

func _ready():
	g_man.mold_window = self
	#get_parent().set_id_window(1, "mold window")


func any_button():
	parent.close_window()
	clear_signals()

signal yes_actions
signal no_actions
signal text_submit_actions(text: String)

const _K_SPEED_WRITING: float = 0.045

var yes_callable
var no_callable
var cancel_callable
var text_callable

func yes():
	parent.close_window()
	if yes_callable:
		yes_callable.call()
	#yes_actions.emit()
	#clear_signals()

	
func no():
	parent.close_window()
	if no_callable:
		no_callable.call()
	#no_actions.emit()
	#clear_signals()

func cancel():
	parent.close_window()
	if cancel_callable:
		cancel_callable.call()

func submit():
	parent.close_window()
	if text_callable:
		text_callable.call(text_edit.text)
	#text_submit_actions.emit(text_edit.text)
	#clear_signals()

func line_submit():
	parent.close_window()
	if text_callable:
		text_callable.call(text_edit.text)
	#text_submit_actions.emit(line_edit.text)
	#clear_signals()

func submit_text(text: String):
	parent.close_window()
	if text_callable:
		text_callable.call(text)
	#text_submit_actions.emit(text)
	#clear_signals()

func clear_signals():
	yes_callable = null
	no_callable = null
	text_callable = null
	for item in no_actions.get_connections():
		no_actions.disconnect(item.callable)
		break
	for item in yes_actions.get_connections():
		yes_actions.disconnect(item.callable)
		break
	for item in text_submit_actions.get_connections():
		text_submit_actions.disconnect(item.callable)
		break

func get_string(array: Array):
	var string:String = ""
	for item in array:
		string = String("{before}\n{item}".format({before = string, item = item}))
	return string

@onready var instructions_only = $"instructions only/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"

func set_instructions_only(array: Array, voice_id = -1):
	begin()
	current_tab = 0
	instructions_only.text = get_string(array)
	print("instr\n", array)
	push_warning("instr\n", array)
	
	write_text(instructions_only)
	if g_man.quests_manager.voices:
		if voice_id == -1:
			voice_id = g_man.quests_manager.voices[0]
		else:
			voice_id = clampi(voice_id, 0, g_man.quests_manager.voices.size() -1)
			voice_id = g_man.quests_manager.voices[voice_id]
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(instructions_only.text, voice_id)

@onready var instructions_yes_no_cancel = $"yes no cancel/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"

func set_yes_no_cancel(array: Array, yes_action:Callable, no_action:Callable, cancel_action:Callable):
	begin()
	current_tab = 1
	instructions_yes_no_cancel.text = get_string(array)
	yes_callable = yes_action
	no_callable = no_action
	cancel_callable = cancel_action
	#yes_actions.connect(yes_action)
	#no_actions.connect(no_action)
	
	write_text(instructions_yes_no_cancel)
	if g_man.quests_manager.voices:
		var voice_id = g_man.quests_manager.voices[0]
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(instructions_yes_no_cancel.text, voice_id)

@onready var instructions_add_text = $"yes no cancel add text/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"
@onready var text_edit: TextEdit = $"yes no cancel add text/MarginContainer/VBoxContainer/buttons/VBoxContainer/TextEdit"

func set_add_submit_text(array: Array, placeholder_text:String, submit_action:Callable, cancel_action:Callable):
	begin()
	current_tab = 2
	instructions_add_text.text = get_string(array)
	text_edit.placeholder_text = placeholder_text
	text_callable = submit_action
	cancel_callable = cancel_action
	#text_submit_actions.connect(submit_action)
	
	write_text(instructions_add_text)
	if g_man.quests_manager.voices:
		var voice_id = g_man.quests_manager.voices[0]
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(instructions_add_text.text, voice_id)

@export var instructions_add_label: Label
@export var line_edit: LineEdit
func set_add_submit_label(array: Array, placeholder_text:String, submit_action:Callable, cancel_action:Callable):
	begin()
	current_tab = 3
	instructions_add_label.text = get_string(array)
	line_edit.placeholder_text = placeholder_text
	text_callable = submit_action
	cancel_callable = cancel_action
	#text_submit_actions.connect(submit_action)
	
	write_text(instructions_add_label)
	if g_man.quests_manager.voices:
		var voice_id = g_man.quests_manager.voices[0]
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(instructions_add_label.text, voice_id)

func set_yes_no_cancel_id(array: Array, yes_action:Callable, no_action:Callable, cancel_action:Callable, id):
	begin()
	current_tab = 1
	instructions_yes_no_cancel.text = get_string(array)
	yes_callable = (
		func():
			yes_action.call(id)
	)
	no_callable = (
		func():
			no_action.call(id)
	)
	cancel_callable = (
		func():
			cancel_action.call(id)
	)
	#yes_actions.connect(
		#func():
			#yes_action.call(id)
	#)
	#no_actions.connect(
		#func():
			#no_action.call(id)
	#)
	
	write_text(instructions_yes_no_cancel)
	if g_man.quests_manager.voices:
		var voice_id = g_man.quests_manager.voices[0]
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(instructions_yes_no_cancel.text, voice_id)

func write_text(label: Label):
	var tween = create_tween()
	var dialog_speed = label.text.length() * _K_SPEED_WRITING
	tween.tween_property(label, "visible_characters", label.text.length(), dialog_speed)

func begin():
	#get_parent().last_sibling()
	parent.show_window(true)
	#get_parent().set_min_size(Vector2(555, 333))
