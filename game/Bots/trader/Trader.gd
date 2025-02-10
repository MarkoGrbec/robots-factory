class_name Trader extends ISavable

var gold_coins = 500
var activated: bool = false
var body: CPTrader

func copy():
	return Trader.new()

func destroy():
	activated = false
	gold_coins = 500
	fully_save()

func fully_save():
	save_activated()
	save_gold_coins()

func fully_load():
	load_activated()
	load_gold_coins()

#region activated
func save_activated():
	DataBase.insert(_server, g_man.dbms, _path, "activated", id, activated)

func load_activated():
	activated = DataBase.select(_server, g_man.dbms, _path, "activated", id, false)
#endregion activated
#region gold coins
func save_gold_coins():
	DataBase.insert(_server, g_man.dbms, _path, "gold_coins", id, gold_coins)

func load_gold_coins():
	gold_coins = DataBase.select(_server, g_man.dbms, _path, "gold_coins", id, 500)
#endregion gold coins
