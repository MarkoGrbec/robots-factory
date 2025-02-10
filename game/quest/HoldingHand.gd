class_name HoldingHand extends ISavable

func copy():
	return HoldingHand.new()

var movement_options_callable: Callable
var dig_options_callable: Callable
var drop_options_callable: Callable
var npc_options_callable: Callable
var underground_options_callable: Callable
var trader_options_callable: Callable

func destroy():
	still_holding_hand_movement(false)
	still_holding_hand_dig(false)
	still_holding_hand_drop(false)
	still_holding_hand_npc(false)
	still_holding_hand_underground(false)
	still_holding_hand_trader(false)

func config():
	movement_options_callable = _get_set_holding_hand_scene("movement", movement_string, load_return_holding_hand_movement(), still_holding_hand_movement, stop_holding_hand_movement)
	dig_options_callable = _get_set_holding_hand_scene("dig", dig_string, load_return_holding_hand_dig(), still_holding_hand_dig, stop_holding_hand_dig)
	drop_options_callable = _get_set_holding_hand_scene("drop", drop_string, load_return_holding_hand_drop(), still_holding_hand_drop, stop_holding_hand_drop)
	npc_options_callable = _get_set_holding_hand_scene("npc", npc_string, load_return_holding_hand_npc(), still_holding_hand_npc, stop_holding_hand_npc)
	underground_options_callable = _get_set_holding_hand_scene("underground", underground_string, load_return_holding_hand_underground(), still_holding_hand_underground, stop_holding_hand_underground)
	trader_options_callable = _get_set_holding_hand_scene("trader", trader_string, load_return_holding_hand_trader(), still_holding_hand_trader, stop_holding_hand_trader)

func _get_set_holding_hand_scene(text, tooltip, active, on: Callable, off: Callable) -> Callable:
	var check_box: OptionsHoldingHandCheckBox = g_man.in_game_menu.options_holding_hand_scene.instantiate()
	check_box.text = text
	check_box.tooltip_text = tooltip
	check_box.button_pressed = active
	check_box.on_callable = on
	check_box.off_callable = off
	g_man.in_game_menu.options_holding_hand_container.add_child(check_box)
	return check_box.toggle_me
#region movement

var movement_string: String = "to move around use WASD or arrow keys\nyou can change that in bindings\nto enter main menu press ESC\npay close attention to the game it's a thinking game\nyou may go long way or short way\nfor inventory press insert\nto open dialog with npc just click him with left mouse button\nto dig press left mouse button on a tile near the robot you are controlling"

func load_return_holding_hand_movement():
	return DataBase.select(_server, g_man.dbms, _path, "movement", id, true)

func save_holding_hand_movement(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "movement", id, yes)
	if call:
		movement_options_callable.call(yes)

func still_holding_hand_movement(call: bool = true):
	save_holding_hand_movement(true, call)

func stop_holding_hand_movement():
	save_holding_hand_movement(false)

func holding_hand_movement():
	if load_return_holding_hand_movement():
		g_man.mold_window.set_yes_no_cancel([movement_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_movement, stop_holding_hand_movement)
#endregion movement
#region dig

var dig_string: String = "when you dig you dig a portion of a selected tile\nthe selected tile always has certain portion of digs to dig\nsome more some less the rock tile gained from fog is always 35 digs long\nand only soft rock underneeth\ngrass grows of dirt but it does not make a new portion of dirt to dig"

func load_return_holding_hand_dig():
	return DataBase.select(_server, g_man.dbms, _path, "dig", id, true)

func save_holding_hand_dig(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "dig", id, yes)
	if call:
		dig_options_callable.call(yes)

func still_holding_hand_dig(call: bool = true):
	save_holding_hand_dig(true, call)

func stop_holding_hand_dig():
	save_holding_hand_dig(false)

func holding_hand_dig():
	if load_return_holding_hand_dig():
		g_man.mold_window.set_yes_no_cancel([dig_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_dig, stop_holding_hand_dig)
#endregion dig
#region underground

var underground_string: String = "when you go underground you may get back to surface\nthrough the brighter tile\nunderground is for mining soft rock which has 15 digs and rock with 35 digs\nunderground has 3 layers\nafter that you may no longer dig further but you need to go on other tiles"

func load_return_holding_hand_underground():
	return DataBase.select(_server, g_man.dbms, _path, "underground", id, true)

func save_holding_hand_underground(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "underground", id, yes)
	if call:
		underground_options_callable.call(yes)

func still_holding_hand_underground(call: bool = true):
	save_holding_hand_underground(true, call)

func stop_holding_hand_underground():
	save_holding_hand_underground(false)

func holding_hand_underground():
	if load_return_holding_hand_underground():
		g_man.mold_window.set_yes_no_cancel(["spoiler", "\nmachanics of digging", "\nif you choose no you will not see this dialog any longer"], spoiler_underground, stop_holding_hand_underground)

func spoiler_underground():
	g_man.mold_window.set_yes_no_cancel([underground_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_underground, stop_holding_hand_underground)
#endregion movement
#region npc
var npc_string: String = "you can talk to npc sometimes multiple times with same pharse\nand get different dialog\n\nto give item in to quest npc simply drag item from inventory or world\nin to top right slot of quest manager"

func load_return_holding_hand_npc():
	return DataBase.select(_server, g_man.dbms, _path, "npc", id, true)

func save_holding_hand_npc(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "npc", id, yes)
	if call:
		npc_options_callable.call(yes)

func still_holding_hand_npc(call: bool = true):
	save_holding_hand_npc(true, call)

func stop_holding_hand_npc():
	save_holding_hand_npc(false)

func holding_hand_npc():
	if load_return_holding_hand_npc():
		g_man.mold_window.set_yes_no_cancel([npc_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_npc, stop_holding_hand_npc)
#endregion npc
#region drop
var drop_string: String = "you may put portion back on to ground by right clicking on it"

func load_return_holding_hand_drop():
	return DataBase.select(_server, g_man.dbms, _path, "drop", id, true)

func save_holding_hand_drop(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "drop", id, yes)
	if call:
		drop_options_callable.call(yes)

func still_holding_hand_drop(call: bool = true):
	save_holding_hand_drop(true, call)

func stop_holding_hand_drop():
	save_holding_hand_drop(false)

func holding_hand_drop():
	if load_return_holding_hand_drop():
		g_man.mold_window.set_yes_no_cancel([drop_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_drop, stop_holding_hand_drop)
#endregion drop
#region trader
var trader_string: String = "if you wish to buy drag the item\nfrom trader manager in to inventory\nto sell simply drag it to the top right of trader manager\n\nless money you have cheaper it is\nbut also it's cheaper to sell\nmore money you have everything is more expensive\nit's kind of economy"

func load_return_holding_hand_trader():
	return DataBase.select(_server, g_man.dbms, _path, "trader", id, true)

func save_holding_hand_trader(yes, call: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "trader", id, yes)
	if call:
		trader_options_callable.call(yes)

func still_holding_hand_trader(call: bool = true):
	save_holding_hand_trader(true, call)

func stop_holding_hand_trader():
	save_holding_hand_trader(false)

func holding_hand_trader():
	if load_return_holding_hand_trader():
		g_man.mold_window.set_yes_no_cancel([trader_string, "\ntoo keep seeing this holding hand press yes"], still_holding_hand_trader, stop_holding_hand_trader)
#endregion trader
