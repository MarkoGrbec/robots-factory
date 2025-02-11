class_name CPTrader extends CPMob

var trader: Trader

func _on_mouse_entered() -> void:
	g_man.camera.input_active = -2
	show_label()

func _unhandled_input(event: InputEvent) -> void:
	if g_man.camera.input_active is int and g_man.camera.input_active == -2:
		if event is InputEventMouseButton:
			if event.is_action_pressed("select"):
				g_man.trader_manager.open_window(trader)
