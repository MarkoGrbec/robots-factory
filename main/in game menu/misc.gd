class_name Misc extends Node

func _ready() -> void:
	g_man.misc = self
	load_quest_move()
	load_slow_writing()

@export var quest_move: CheckBox
@export var slow_letters: LineEdit
var slow_writing: float

func _on_quest_move_toggled(_toggled_on: bool) -> void:
	save_quest_move()

func _on_slow_letters_text_submitted(new_text: String) -> void:
	slow_writing = float(new_text)
	save_slow_writing()

func save_quest_move():
	DataBase.insert(false, g_man.dbms, "misc", "quest_move", 1, quest_move.button_pressed)

func load_quest_move():
	quest_move.button_pressed = DataBase.select(false, g_man.dbms, "misc", "quest_move", 1, false)

func save_slow_writing():
	DataBase.insert(false, g_man.dbms, "misc", "slow_writing", 1, slow_writing)

func load_slow_writing():
	slow_writing = DataBase.select(false, g_man.dbms, "misc", "slow_writing", 1, 0.045)
	slow_letters.text = str(slow_writing)
