class_name MainMenu extends Node2D

@export var main_menu_tab: TabContainer
@export var in_game_main_menu: InGameMenu
@export var environment: WorldEnvironment

var terrain

func _ready() -> void:
	g_man.main_menu = self
	#environment.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	#environment.environment.glow_map_strength = 0.2

func close_main_menu():
	main_menu_tab.hide()

func open_main_menu():
	main_menu_tab.show()

func show_main_menu_tabs():
	var tab = main_menu_tab
	tab.set_tab_hidden(0, false)
	tab.set_tab_hidden(1, false)
	tab.set_tab_hidden(2, true)
	tab.current_tab = 0

func _input(event: InputEvent) -> void:
	if g_man.asking_toggled:
		return
	if event.is_action_pressed("esc"):
		if in_game_main_menu:
			in_game_main_menu.open_window()
	elif event.is_action_pressed("inventory"):
		g_man.inventory_system.open_window()
	elif event.is_action_pressed("changes"):
		g_man.holding_hand.holding_hand_changes()
		g_man.changes_manager.change_opened_window()
	elif event.is_action_pressed("stats"):
		g_man.stats_labels.open_close_window()
