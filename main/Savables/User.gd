class_name User extends ISavable

var avatar_name: String
var gold_coins = 500
var _weapon_reflexes: float = 3
var believe_in_god: bool = false

var weapon_strength: float = 1
var armor_strength: float = 1

#var id_tool
#var id_workpiece
#var id_finished_product

func copy():
	return User.new()

func destroy():
	avatar_name = ""
	save_username()
	save_user_time_change_name(0)
	save_user_type(0)
	gold_coins = 500
	save_gold_coins()
	save_weapon_activated(false)
	save_battery_constumption(75, true)
	save_weapon_range(75, true)
	save_weapon_reflexes(1, true)
	save_layer(0)
	save_position(Vector2.ZERO)
#region fully
func fully_load():
	if not avatar_name:
		partly_load()

func fully_save():
	partly_save()
#endregion fully
#region partly
func partly_load():
	load_username()
	load_gold_coins()
	load_believe_in_god()

func partly_save():
	save_username()
#endregion partly
#region save load
	#region save
func save_username():
	DataBase.insert(_server, g_man.dbms, _path, "username", id, avatar_name)

func save_position(position):
	DataBase.insert(_server, g_man.dbms, _path, "position", id, position)

func save_user_time_change_name(time_changed_name):
	DataBase.insert(_server, g_man.dbms, _path, "time_changed_name", id, int(time_changed_name))

func save_user_type(type):
	DataBase.insert(_server, g_man.dbms, _path, "type", id, type)

func save_gold_coins():
	if not g_man.tutorial:
		DataBase.insert(_server, g_man.dbms, _path, "gold_coins", id, gold_coins)

func save_weapon_activated(activate):
	DataBase.insert(_server, g_man.dbms, _path, "weapon", id, activate)

func save_battery_constumption(battery_constumption, default: bool = false):
	if default:
		DataBase.insert(_server, g_man.dbms, _path, "battery_constumption", id, float(battery_constumption))
	else:
		g_man.player.weapon_controller.weapon.battery_constumption *= battery_constumption
		DataBase.insert(_server, g_man.dbms, _path, "battery_constumption", id, float(g_man.player.weapon_controller.weapon.battery_constumption))
	set_battery_constumption()

func save_weapon_range(weapon_range, default: bool = false):
	if default:
		DataBase.insert(_server, g_man.dbms, _path, "weapon_range", id, float(weapon_range))
	else:
		g_man.player.weapon_controller.weapon.distance *= weapon_range
		DataBase.insert(_server, g_man.dbms, _path, "weapon_range", id, float(g_man.player.weapon_controller.weapon.distance))
	set_weapon_distance()

func save_weapon_reflexes(weapon_reflexes, default: bool = false):
	if default:
		_weapon_reflexes = 3
	_weapon_reflexes *= weapon_reflexes
	DataBase.insert(_server, g_man.dbms, _path, "weapon_reflexes", id, float(_weapon_reflexes))

func save_add_weapon_strength(strength, add = true):
	if add:
		weapon_strength += strength
	else:# overwrite
		weapon_strength = strength
	save_uni("weapon_strength", weapon_strength)
	set_weapon_strength()

func save_add_armor_strength(strength, add = true):
	if add:
		armor_strength += strength
	else:# overwrite
		armor_strength = strength
	save_uni("armor_strength", armor_strength)
	set_armor_strength()
	

func save_believe_in_god():
	DataBase.insert(_server, g_man.dbms, _path, "believe_in_god", id, believe_in_god)

func save_layer(layer):
	save_uni("layer", layer)

func save_id_tool(id_tool):
	save_uni("id_tool", id_tool)

func save_id_workpiece(id_workpiece):
	save_uni("id_workpiece", id_workpiece)

func save_id_finished_product(id_finished_product):
	save_uni("id_finished_product", id_finished_product)
	#endregion save
	#region load
func load_username():
	avatar_name = DataBase.select(_server, g_man.dbms, _path, "username", id, "")

func load_return_position():
	return load_uni("position", Vector2.ZERO)

func load_return_user_time_change_name():
	return DataBase.select(_server, g_man.dbms, _path, "time_changed_name", id, 0)

func load_return_user_type():
	return DataBase.select(_server, g_man.dbms, _path, "type", id, 0)

func load_gold_coins():
	gold_coins = DataBase.select(_server, g_man.dbms, _path, "gold_coins", id, 500)

func load_weapon():
	set_weapon( load_uni("weapon", false) )

func load_battery_constumption():
	g_man.player.weapon_controller.weapon.battery_constumption = DataBase.select(_server, g_man.dbms, _path, "battery_constumption", id, 75)
	g_man.player.weapon_controller.weapon.battery_constumption = 75
	save_battery_constumption(1)
	set_battery_constumption()

func load_weapon_range():
	g_man.player.weapon_controller.weapon.distance = load_uni("weapon_range", 75)
	set_weapon_distance()

func load_weapon_reflexes():
	_weapon_reflexes = load_uni("weapon_reflexes", 3)

func load_believe_in_god():
	believe_in_god = load_uni("believe_in_god", false)

func load_return_layer():
	return load_uni("layer", 0)

func load_armor_strength():
	armor_strength = load_uni("armor_strength", 1)
	set_armor_strength()

func load_weapon_strength():
	weapon_strength = load_uni("weapon_strength", 1)
	set_weapon_strength()

func load_return_id_tool():
	return load_uni("id_tool", 0)

func load_return_id_workpiece():
	return load_uni("id_workpiece", 0)

func load_return_id_finished_product():
	return load_uni("id_finished_product", 0)
	#endregion load
#endregion save load

#region set labels and activate/deactivate weapon weapon
func set_weapon(activate):
	g_man.player.weapon_controller.weapon.activated = activate
	if activate:
		save_weapon_activated(activate)
		g_man.stats_labels.show()
	else:
		g_man.stats_labels.hide()

func set_armor_strength():
	if g_man.stats_labels:
		g_man.stats_labels.set_label(StatsLabels.TypeLabel.ARMOR_STRENGTH, armor_strength)

func set_weapon_strength():
	if g_man.stats_labels:
		g_man.stats_labels.set_label(StatsLabels.TypeLabel.WEAPON_STRENGTH, weapon_strength)

func set_weapon_distance():
	if g_man.player and g_man.player.weapon_controller and g_man.player.weapon_controller.weapon:
		g_man.stats_labels.set_label(StatsLabels.TypeLabel.WEAPON_DISTANCE, g_man.player.weapon_controller.weapon.distance)

func set_battery_constumption():
	if g_man.player and g_man.player.weapon_controller and g_man.player.weapon_controller.weapon:
		g_man.stats_labels.set_label(StatsLabels.TypeLabel.BATTERY_CONSTUMPTION, g_man.player.weapon_controller.weapon.battery_constumption)
#endregion
