class_name MainMenu extends Node2D

@export var main_menu_tab: TabContainer
@export var in_game_main_menu: InGameMenu
@export var environment: WorldEnvironment
func _ready() -> void:
	g_man.main_menu = self
	#environment.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	#environment.environment.glow_map_strength = 0.2

func close_main_menu():
	main_menu_tab.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if in_game_main_menu:
			in_game_main_menu.open_window()
	elif event.is_action_pressed("inventory"):
		g_man.inventory_system.open_window()
