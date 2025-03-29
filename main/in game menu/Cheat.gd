extends Node


func _on_button_reset_trader_money_pressed() -> void:
	if g_man.trader:
		g_man.trader.gold_coins = 500
		g_man.trader.save_gold_coins()
		if g_man.user:
			g_man.user.gold_coins = 500
			g_man.user.save_gold_coins()


func _on_activate_mark_pressed() -> void:
	QuestsManager.set_server_quest(10, true, 0)


func _on_remove_sophie_mission_pressed() -> void:
	var johnny: ServerQuest = QuestsManager.get_server_quest(11)
	johnny.mission_quantity = 0
	johnny.dict_mission__entity_num.clear()
	
	var sophie: ServerQuest = QuestsManager.get_server_quest(12)
	sophie.mission_quantity = 0
	sophie.dict_mission__entity_num.clear()
