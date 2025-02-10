class_name InGameMenu extends TabContainer

@export var options_holding_hand_scene: PackedScene
@export var options_holding_hand_container: VBoxContainer


func _ready() -> void:
	g_man.in_game_menu = self

func close_window():
	hide()

func open_window(open: bool = false):
	if is_visible_in_tree():
		if not open:
			hide()
		return
	else:
		show()


func _on_quit_button_pressed() -> void:
	g_man.mold_window.set_yes_no_cancel(["does the robot really wants to quit", "is it really all done for today"], quit, cancel_quit, cancel_quit)

func quit():
	g_man.mold_window.set_instructions_only(["thanks for playing"])
	await get_tree().create_timer(2.5).timeout
	DisplayServer.tts_stop()
	get_tree().quit()

func cancel_quit():
	g_man.changes_manager.add_change("objectives not done yet are they?")
