class_name TraderManager extends TabContainer

@export var buy_grid_container: GridContainer
@export var trader_button_sell: TraderButtonSell
@export var trader_gold_label: Label
@export var robot_gold_label: Label

@export var buy_for: Label
@export var sell_for: Label

var _trader: Trader

func _ready() -> void:
	g_man.trader_manager = self

func close_window():
	hide()

func open_window(trader: Trader):
	if is_visible_in_tree():
		hide()
	else:
		show()
		for child: TraderButtonBuy in buy_grid_container.get_children():
			child.trader = trader
			_trader = trader
			trader_button_sell.trader = trader
		g_man.inventory_system.open_window(true)
		recount_gold()

func recount_gold():
	trader_gold_label.text = str("trader gold: ", int(_trader.gold_coins))
	var user: User = g_man.user.get_index_data(1)
	robot_gold_label.text = str(user.avatar_name, " gold: ", int(user.gold_coins))
