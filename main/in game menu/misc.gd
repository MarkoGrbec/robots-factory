class_name Misc extends Node

func _ready() -> void:
	g_man.misc = self
	load_quest_move()
	load_slow_writing()
	load_speak_names()

@export var quest_move: CheckBox
@export var slow_letters: LineEdit
@export var speak_names: CheckBox
var slow_writing: float


func _on_quest_move_toggled(_toggled_on: bool) -> void:
	save_quest_move()

func _on_slow_letters_text_submitted(new_text: String) -> void:
	slow_writing = float(new_text)
	save_slow_writing()

func _on_speak_names_toggled(_toggled_on: bool) -> void:
	save_speak_names()

func save_quest_move():
	DataBase.insert(false, g_man.dbms, "misc", "quest_move", 1, quest_move.button_pressed)

func load_quest_move():
	quest_move.button_pressed = DataBase.select(false, g_man.dbms, "misc", "quest_move", 1, false)

func save_slow_writing():
	DataBase.insert(false, g_man.dbms, "misc", "slow_writing", 1, slow_writing)

func load_slow_writing():
	slow_writing = DataBase.select(false, g_man.dbms, "misc", "slow_writing", 1, 0.045)
	slow_letters.text = str(slow_writing)

func save_speak_names():
	DataBase.insert(false, g_man.dbms, "misc", "speak_names", 1, speak_names.button_pressed)

func load_speak_names():
	speak_names.button_pressed = DataBase.select(false, g_man.dbms, "misc", "speak_names", 1, true)
