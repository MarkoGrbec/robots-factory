class_name InGameMenu extends TabContainer

@export var options_holding_hand_scene: PackedScene
@export var options_holding_hand_container: VBoxContainer


func _ready() -> void:
	g_man.in_game_menu = self

func close_window():
	hide()
	g_man.changes_manager.open_window()

func open_window(open: bool = false):
	if is_visible_in_tree():
		if not open:
			close_window()
		return
	else:
		show()
		g_man.changes_manager.close_window()


func _on_quit_button_pressed() -> void:
	g_man.mold_window.set_yes_no_cancel(["does the robot really wants to quit", "is it really all done for today"], quit, cancel_quit, cancel_quit)

func quit():
	g_man.mold_window.set_instructions_only(["thanks for playing"])
	await get_tree().create_timer(("thanks for playing".length() + 3) * g_man.misc.slow_writing).timeout
	get_tree().quit()

func cancel_quit():
	g_man.changes_manager.add_change("objectives not done yet are they?")


func _on_quit_game_button_pressed() -> void:
	g_man.main_menu.terrain.queue_free()
	g_man.tutorial = false
	g_man.main_menu.open_main_menu()
	g_man.main_menu.show_main_menu_tabs()
	g_man.changes_manager.delete_changes()
	g_man.entity_manager.destroy_all_entities()
	
	close_window()
	g_man.inventory_system.close_window()
	g_man.quests_manager.close_window()
	g_man.trader_manager.close_window()
