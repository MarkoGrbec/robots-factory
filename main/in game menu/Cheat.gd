extends Node


func _on_button_reset_trader_money_pressed() -> void:
	if g_man.trader:
		g_man.trader.gold_coins = 500
		g_man.trader.save_gold_coins()
		if g_man.user:
			g_man.user.gold_coins = 500
			g_man.user.save_gold_coins()
