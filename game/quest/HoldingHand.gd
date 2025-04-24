class_name HoldingHand extends ISavable

func copy():
	return HoldingHand.new()

var movement_options_callable: Callable
var movement_completed_options_callable: Callable
var changes_options_callable: Callable
var dig_options_callable: Callable
var drop_options_callable: Callable
var inventory_options_callable: Callable
var npc_options_callable: Callable
var npc_give_item_options_callable: Callable
var underground_options_callable: Callable
var to_surface_options_callable: Callable
var trader_options_callable: Callable
var trader_buy_options_callable: Callable
var enemy_options_callable: Callable
var enemy_finished_options_callable: Callable
var believe_options_callable: Callable

func destroy():
	still_holding_hand_movement(false)
	still_holding_hand_movement_completed(false)
	still_holding_hand_changes(false)
	still_holding_hand_dig(false)
	still_holding_hand_drop(false)
	still_holding_hand_inventory(false)
	still_holding_hand_npc(false)
	still_holding_hand_npc_give_item(false)
	still_holding_hand_underground(false)
	still_holding_hand_to_surface(false)
	still_holding_hand_trader(false)
	still_holding_hand_trader_buy(false)
	still_holding_hand_enemy(false)
	still_holding_hand_enemy_finished(false)
	still_holding_hand_believe(false)
	still_holding_hand_quadrant1()

## get tooltips in main menu misc
func config():
	movement_options_callable = _get_set_holding_hand_scene("movement", movement_string, load_return_holding_hand_movement(), still_holding_hand_movement, stop_holding_hand_movement)
	movement_completed_options_callable = _get_set_holding_hand_scene("changes", movement_completed_string, load_return_holding_hand_movement_completed(), still_holding_hand_movement_completed, stop_holding_hand_movement_completed)
	changes_options_callable = _get_set_holding_hand_scene("dig", changes_string, load_return_holding_hand_changes(), still_holding_hand_changes, stop_holding_hand_changes)
	dig_options_callable = _get_set_holding_hand_scene("put back material", dig_string, load_return_holding_hand_dig(), still_holding_hand_dig, stop_holding_hand_dig)
	drop_options_callable = _get_set_holding_hand_scene("to inventory", drop_string, load_return_holding_hand_drop(), still_holding_hand_drop, stop_holding_hand_drop)
	inventory_options_callable = _get_set_holding_hand_scene("talk to NPC", inventory_string, load_return_holding_hand_inventory(), still_holding_hand_inventory, stop_holding_hand_inventory)
	npc_options_callable = _get_set_holding_hand_scene("give item to NPC", npc_string, load_return_holding_hand_npc(), still_holding_hand_npc, stop_holding_hand_npc)
	npc_give_item_options_callable = _get_set_holding_hand_scene("dig underground", npc_give_item_string, load_return_holding_hand_npc_give_item(), still_holding_hand_npc_give_item, stop_holding_hand_npc_give_item)
	underground_options_callable = _get_set_holding_hand_scene("back to surface", underground_string, load_return_holding_hand_underground(), still_holding_hand_underground, stop_holding_hand_underground)
	to_surface_options_callable = _get_set_holding_hand_scene("sell to trader", to_surface_string, load_return_holding_hand_to_surface(), still_holding_hand_to_surface, stop_holding_hand_to_surface)
	trader_options_callable = _get_set_holding_hand_scene("buy from trader", trader_string, load_return_holding_hand_trader(), still_holding_hand_trader, stop_holding_hand_trader)
	trader_buy_options_callable = _get_set_holding_hand_scene("fight enemy", trader_buy_string, load_return_holding_hand_trader_buy(), still_holding_hand_trader_buy, stop_holding_hand_trader_buy)
	enemy_options_callable = _get_set_holding_hand_scene("defending the prey", enemy_string, load_return_holding_hand_enemy(), still_holding_hand_enemy, stop_holding_hand_enemy)
	enemy_finished_options_callable = _get_set_holding_hand_scene("end of tutorial", enemy_finished_string, load_return_holding_hand_enemy_finished(), still_holding_hand_enemy_finished, stop_holding_hand_enemy_finished)
	believe_options_callable = _get_set_holding_hand_scene("believe", believe_string, load_return_holding_hand_believe(), still_holding_hand_believe, stop_holding_hand_believe)

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
var movement_string: String = "to move around use WASD or arrow keys\nyou can change that in bindings in main menu\nto enter main menu press ESC or Q [ESC] binding\n\n\nsometimes you can hover over UI and you'll get a tooltip shown"

func load_return_holding_hand_movement():
	return DataBase.select(_server, g_man.dbms, _path, "movement", id, true)

func save_holding_hand_movement(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "movement", id, yes)
	if callab:
		movement_options_callable.call(yes)

func still_holding_hand_movement(callab: bool = true):
	save_holding_hand_movement(true, callab)

func stop_holding_hand_movement():
	save_holding_hand_movement(false)

func holding_hand_movement():
	if load_return_holding_hand_movement():
		g_man.mold_window.set_instructions_only([movement_string])
		g_man.changes_manager.add_key_change("tutorial: ", movement_string)
		stop_holding_hand_movement()
#endregion movement
#region movement_completed
var movement_completed_string: String = "now try to turn off changes\nto toggle changes press C [changes] binding"

func load_return_holding_hand_movement_completed():
	return DataBase.select(_server, g_man.dbms, _path, "movement_completed", id, true)

func save_holding_hand_movement_completed(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "movement_completed", id, yes)
	if callab:
		movement_completed_options_callable.call(yes)

func still_holding_hand_movement_completed(callab: bool = true):
	save_holding_hand_movement_completed(true, callab)

func stop_holding_hand_movement_completed():
	save_holding_hand_movement_completed(false)

func holding_hand_movement_completed():
	if g_man.tutorial and load_return_holding_hand_movement_completed() and not load_return_holding_hand_movement():
		g_man.mold_window.set_instructions_only(["great you know how to move around\n", movement_completed_string])
		g_man.changes_manager.add_key_change("tutorial: ", movement_completed_string)
		stop_holding_hand_movement_completed()
#endregion movement
#region changes
var changes_string: String = "now try to dig,\nto dig press left mouse button [select] binding near robot you are controlling\nalso you need to have mouse there untill it digs the portion out\nelse it does not dig anything and stamina is still drained"

func load_return_holding_hand_changes():
	return DataBase.select(_server, g_man.dbms, _path, "changes", id, true)

func save_holding_hand_changes(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "changes", id, yes)
	if callab:
		changes_options_callable.call(yes)

func still_holding_hand_changes(callab: bool = true):
	save_holding_hand_changes(true, callab)

func stop_holding_hand_changes():
	save_holding_hand_changes(false)

func holding_hand_changes():
	if g_man.tutorial and load_return_holding_hand_changes() and not load_return_holding_hand_movement_completed():
		g_man.mold_window.set_instructions_only(["great you know how to toggle changes\n", changes_string])
		g_man.changes_manager.add_key_change("tutorial: ", changes_string)
		stop_holding_hand_changes()
#endregion changes
#region dig

var dig_string: String = "digging will tire you\ntop right yellow is stanima\nwhen you dig you dig a portion of a selected tile\nyou can put it back to the ground by right clicking on it [put back material] binding\nthe selected tile always has certain portion of digs to dig\nsome more some less the rock tile gained from fog is always 35 digs long\nand only soft rock underneeth\ngrass grows of dirt but it does not make a new portion of dirt to dig\n\nyou cannot dig up but only down \n\nNow try to put it back in to the ground with right click on it."

func load_return_holding_hand_dig():
	return DataBase.select(_server, g_man.dbms, _path, "dig", id, true)

func save_holding_hand_dig(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "dig", id, yes)
	if callab:
		dig_options_callable.call(yes)

func still_holding_hand_dig(callab: bool = true):
	save_holding_hand_dig(true, callab)

func stop_holding_hand_dig():
	save_holding_hand_dig(false)

func holding_hand_dig():
	if g_man.tutorial and load_return_holding_hand_dig() and not load_return_holding_hand_changes():
		g_man.mold_window.set_instructions_only([dig_string])
		g_man.changes_manager.add_key_change("tutorial: ", dig_string)
		stop_holding_hand_dig()
#endregion dig
#region drop
var drop_string: String = "Try to dig and get it in to your inventory E or I or insert [inventory] binding\ndrag it in to your inventory"

func load_return_holding_hand_drop():
	return DataBase.select(_server, g_man.dbms, _path, "drop", id, true)

func save_holding_hand_drop(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "drop", id, yes)
	if callab:
		drop_options_callable.call(yes)

func still_holding_hand_drop(callab: bool = true):
	save_holding_hand_drop(true, callab)

func stop_holding_hand_drop():
	save_holding_hand_drop(false)

func holding_hand_drop():
	if g_man.tutorial and load_return_holding_hand_drop() and not load_return_holding_hand_dig():
		g_man.mold_window.set_instructions_only(["good you put it back.\n", drop_string])
		g_man.changes_manager.add_key_change("tutorial: ", drop_string)
		stop_holding_hand_drop()
#endregion drop
#region inventory
var inventory_string: String = "try to talk to tutorial NPC by left clikc on the tutorial NPC"

func load_return_holding_hand_inventory():
	return DataBase.select(_server, g_man.dbms, _path, "inventory", id, true)

func save_holding_hand_inventory(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "inventory", id, yes)
	if callab:
		inventory_options_callable.call(yes)

func still_holding_hand_inventory(callab: bool = true):
	save_holding_hand_inventory(true, callab)

func stop_holding_hand_inventory():
	save_holding_hand_inventory(false)

func holding_hand_inventory():
	if g_man.tutorial and load_return_holding_hand_inventory() and not load_return_holding_hand_drop():
		g_man.mold_window.set_instructions_only(["good you put in to your inventory.\n", inventory_string])
		g_man.changes_manager.add_key_change("tutorial: ", inventory_string)
		stop_holding_hand_inventory()
		QuestsManager.set_server_quest(21, true, 0)
#endregion inventory
#region npc
var npc_string: String = "to give item in to quest npc simply drag item from inventory or world in to top right slot of quest manager,\nYou must have inventory opened I, or E or insert [inventory] binding\n\nWhen talking to NPC with input order of words does not matter"
#"You can talk to npc sometimes multiple times with same pharse and get different dialog\n\ntry talking to them like to fellow human\n\nto give item in to quest npc simply drag item from inventory or world in to top right slot of quest manager\n\nUsually you need to say max 3 words but all words must match sometimes there are more than 1 pharses available to match\nOrder of words does not matter\n\nif you get failed dialog it means non pharses were match\nelse if you put right words for other pharse it may not activate it\ndepends on the priority of the pharse\n\n if you have a quest and correct pharse you might get failed dialog if the quest has not been fulfilled\n\nthe completed basis(quest) may activate other basis completely random(predefined) it is not linear.\n It may activate deactivate other npc and their basis\n\nin each basis there's usually more than 1 quest question\nWhich has 1 or more pharses to match if priority quest question is fulfilled than the bottom ones aren't triggered, quest question may have more than 1 sucessfull response if it changes the basis it's no longer possible to access that quest question as you are in different basis."

func load_return_holding_hand_npc():
	return DataBase.select(_server, g_man.dbms, _path, "npc", id, true)

func save_holding_hand_npc(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "npc", id, yes)
	if callab:
		npc_options_callable.call(yes)

func still_holding_hand_npc(callab: bool = true):
	save_holding_hand_npc(true, callab)

func stop_holding_hand_npc():
	save_holding_hand_npc(false)

func holding_hand_npc():
	if g_man.tutorial and load_return_holding_hand_npc() and not load_return_holding_hand_inventory():
		g_man.mold_window.set_instructions_only([npc_string])
		g_man.changes_manager.add_key_change("tutorial: ", npc_string)
		stop_holding_hand_npc()
#endregion npc
#region npc_give_item
var npc_give_item_string: String = "When you give item like this you cannot take it back\n\nNow try to dig underground"

func load_return_holding_hand_npc_give_item():
	return DataBase.select(_server, g_man.dbms, _path, "npc_give_item", id, true)

func save_holding_hand_npc_give_item(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "npc_give_item", id, yes)
	if callab:
		npc_give_item_options_callable.call(yes)

func still_holding_hand_npc_give_item(callab: bool = true):
	save_holding_hand_npc_give_item(true, callab)

func stop_holding_hand_npc_give_item():
	save_holding_hand_npc_give_item(false)

func holding_hand_npc_give_item():
	if g_man.tutorial and load_return_holding_hand_npc_give_item() and not load_return_holding_hand_npc():
		g_man.mold_window.set_instructions_only(["good you gave quest an item", npc_give_item_string])
		g_man.changes_manager.add_key_change("tutorial: ", npc_give_item_string)
		stop_holding_hand_npc_give_item()
#endregion npc_give_item
#region underground
var underground_string: String = "when you go underground you may get back to surface\nthrough the brighter tile\nunderground is for mining soft rock which has 15 digs and rock with 35 digs\nunderground has 3 layers\nafter that you may no longer dig further but you need to go on other tiles\n\nNow try to get back to the surface"

func load_return_holding_hand_underground():
	return DataBase.select(_server, g_man.dbms, _path, "underground", id, true)

func save_holding_hand_underground(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "underground", id, yes)
	if callab:
		underground_options_callable.call(yes)

func still_holding_hand_underground(callab: bool = true):
	save_holding_hand_underground(true, callab)

func stop_holding_hand_underground():
	save_holding_hand_underground(false)

func holding_hand_underground():
	if g_man.tutorial and load_return_holding_hand_underground() and not load_return_holding_hand_npc_give_item():
		spoiler_underground()
		#g_man.mold_window.set_instructions_only(["spoiler", "\nmachanics of digging", "\nif you choose no you will not see this dialog any longer"], spoiler_underground, stop_holding_hand_underground, stop_holding_hand_underground)

func spoiler_underground():
	g_man.mold_window.set_instructions_only([underground_string])
	g_man.changes_manager.add_key_change("tutorial: ", underground_string)
	stop_holding_hand_underground()
#endregion underground
#region to_surface
var to_surface_string: String = "remember brighter tile is always up to surface and black is down to next layer underground\n\nnow you've got some materials you've dug try selling them at trader,\nclick it with left mouse button\n\nif you wish to sell simply drag material from world or inventory in to the top right of trader window\nnow try to sell some materials"

func load_return_holding_hand_to_surface():
	return DataBase.select(_server, g_man.dbms, _path, "to_surface", id, true)

func save_holding_hand_to_surface(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "to_surface", id, yes)
	if callab:
		to_surface_options_callable.call(yes)

func still_holding_hand_to_surface(callab: bool = true):
	save_holding_hand_to_surface(true, callab)

func stop_holding_hand_to_surface():
	save_holding_hand_to_surface(false)

func holding_hand_to_surface():
	if g_man.tutorial and load_return_holding_hand_to_surface() and not load_return_holding_hand_underground():
		g_man.mold_window.set_instructions_only(["good you know how to go underground and back to surface", to_surface_string])
		g_man.changes_manager.add_key_change("tutorial: ", to_surface_string)
		stop_holding_hand_to_surface()
		var trader = Trader.new()
		trader.activated = true
		CreateMob.target_create_trader(trader, Vector2(100, 100))
#endregion to_surface
#region trader
var trader_string: String = "less money you have cheaper it is to buy\nbut also it's cheaper to sell\nmore money you have everything is more expensive\nit's kind of economy\nnow try to buy some materials\n\nif you wish to buy drag the item from trader manager in to inventory\nyou cannot place it in to the world"

func load_return_holding_hand_trader():
	return DataBase.select(_server, g_man.dbms, _path, "trader", id, true)

func save_holding_hand_trader(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "trader", id, yes)
	if callab:
		trader_options_callable.call(yes)

func still_holding_hand_trader(callab: bool = true):
	save_holding_hand_trader(true, callab)

func stop_holding_hand_trader():
	save_holding_hand_trader(false)

func holding_hand_trader():
	if g_man.tutorial and load_return_holding_hand_trader() and not load_return_holding_hand_to_surface():
		g_man.mold_window.set_instructions_only(["good work you sold material", trader_string])
		g_man.changes_manager.add_key_change("tutorial: ", trader_string)
		stop_holding_hand_trader()
#endregion trader
#region trader_buy
var trader_buy_string: String = "now try to fight off the enemy, to fire use f or shift key [fire] binding"
var trader_buy_string_introduction: String = "good work you bought your item"

func load_return_holding_hand_trader_buy():
	return DataBase.select(_server, g_man.dbms, _path, "trader_buy", id, true)

func save_holding_hand_trader_buy(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "trader_buy", id, yes)
	if callab:
		trader_buy_options_callable.call(yes)

func still_holding_hand_trader_buy(callab: bool = true):
	save_holding_hand_trader_buy(true, callab)

func stop_holding_hand_trader_buy():
	save_holding_hand_trader_buy(false)

func holding_hand_trader_buy():
	if g_man.tutorial and load_return_holding_hand_trader_buy() and not load_return_holding_hand_trader():
		g_man.mold_window.set_instructions_only([trader_buy_string_introduction, trader_buy_string])
		g_man.changes_manager.add_key_change("tutorial: ", trader_buy_string)
		stop_holding_hand_trader_buy()
		g_man.player.weapon_controller.weapon.activated = true
		await g_man.map.get_tree().create_timer((trader_buy_string_introduction.length() + trader_buy_string.length()) * g_man.misc.slow_writing).timeout
		GameControl.enter_enemy(Vector2(1, 1), false, Vector2i(randi_range(2, 7), randi_range(2, 5)), true)
#endregion trader_buy
#region enemy
var enemy_string: String = "try to make obsticles for defending your prey you'll get reward this enemy can't be defeated"
var enemy_string_introduction: String = "good work you know how to manage inventory and it's system"

func load_return_holding_hand_enemy():
	return DataBase.select(_server, g_man.dbms, _path, "enemy", id, true)

func save_holding_hand_enemy(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "enemy", id, yes)
	if callab:
		enemy_options_callable.call(yes)

func still_holding_hand_enemy(callab: bool = true):
	save_holding_hand_enemy(true, callab)

func stop_holding_hand_enemy():
	save_holding_hand_enemy(false)

func holding_hand_enemy():
	if g_man.tutorial and load_return_holding_hand_enemy() and not load_return_holding_hand_trader_buy():
		g_man.mold_window.set_instructions_only([enemy_string_introduction, enemy_string])
		g_man.changes_manager.add_key_change("tutorial: ", enemy_string)
		stop_holding_hand_enemy()
		await g_man.map.get_tree().create_timer((enemy_string_introduction.length() + enemy_string.length()) * g_man.misc.slow_writing).timeout
#endregion enemy
#region enemy_finished
var enemy_finished_string: String = "this is all for tutorial feel free to play around with trader and NPC, if you'll bring him iron he will tell you more about it."

func load_return_holding_hand_enemy_finished():
	return DataBase.select(_server, g_man.dbms, _path, "enemy_finished", id, true)

func save_holding_hand_enemy_finished(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "enemy_finished", id, yes)
	if callab:
		enemy_finished_options_callable.call(yes)

func still_holding_hand_enemy_finished(callab: bool = true):
	save_holding_hand_enemy_finished(true, callab)

func stop_holding_hand_enemy_finished():
	save_holding_hand_enemy_finished(false)

func holding_hand_enemy_finished():
	if g_man.tutorial and load_return_holding_hand_enemy_finished():
		g_man.mold_window.set_instructions_only(["good work you know how to manage inventory and it's system", enemy_finished_string])
		g_man.changes_manager.add_key_change("tutorial: ", enemy_finished_string)
		stop_holding_hand_enemy_finished()
#endregion enemy_finished
#region believe
var believe_string: String = "To convince in to believing in to god you must choose correct pharse for his dialog.\nIf you don't convince him, than he will strenghten the bond to other side.\nEach character has unique dialogs."

func load_return_holding_hand_believe():
	return DataBase.select(_server, g_man.dbms, _path, "believe", id, true)

func save_holding_hand_believe(yes, callab: bool = true):
	DataBase.insert(_server, g_man.dbms, _path, "believe", id, yes)
	if callab:
		believe_options_callable.call(yes)

func still_holding_hand_believe(callab: bool = true):
	save_holding_hand_believe(true, callab)

func stop_holding_hand_believe():
	save_holding_hand_believe(false)

func holding_hand_believe():
	if load_return_holding_hand_believe():
		g_man.mold_window.set_instructions_only([believe_string])
		#g_man.changes_manager.add_key_change("tutorial: ", believe_string)
		stop_holding_hand_believe()
#endregion believe
#region quadrant1
var quadrant1_string: String = "what is this seems like everything is wrong maybe I should ask assistant."

func load_return_holding_hand_quadrant1():
	return DataBase.select(_server, g_man.dbms, _path, "quadrant1", id, true)

func save_holding_hand_quadrant1(yes):
	DataBase.insert(_server, g_man.dbms, _path, "quadrant1", id, yes)

func still_holding_hand_quadrant1():
	save_holding_hand_quadrant1(true)

func stop_holding_hand_quadrant1():
	save_holding_hand_quadrant1(false)

func holding_hand_quadrant1() -> bool:
	if load_return_holding_hand_quadrant1():
		g_man.mold_window.set_instructions_only([quadrant1_string], 7)
		stop_holding_hand_quadrant1()
		return true
	return false
#endregion quadrant1
