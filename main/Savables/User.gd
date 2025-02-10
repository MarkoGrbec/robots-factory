class_name User extends ISavable

var avatar_name: String
var gold_coins = 500
var _weapon_reflexes: float = 3
func copy():
	return User.new()

func destroy():
	save_user_time_change_name(0)
	save_user_type(0)
	gold_coins = 500
	save_gold_coins()
	save_weapon_activated(false)
	save_battery_constumption(75, true)
	save_weapon_range(75, true)
	save_weapon_reflexes(1, true)
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
	DataBase.insert(_server, g_man.dbms, _path, "gold_coins", id, gold_coins)

func save_weapon_activated(activate):
	DataBase.insert(_server, g_man.dbms, _path, "weapon", id, activate)

func save_battery_constumption(battery_constumption, default: bool = false):
	if default:
		DataBase.insert(_server, g_man.dbms, _path, "battery_constumption", id, float(battery_constumption))
	else:
		g_man.player.weapon_controller.weapon.battery_constumption *= battery_constumption
		DataBase.insert(_server, g_man.dbms, _path, "battery_constumption", id, float(g_man.player.weapon_controller.weapon.battery_constumption))

func save_weapon_range(weapon_range, default: bool = false):
	if default:
		DataBase.insert(_server, g_man.dbms, _path, "weapon_range", id, float(weapon_range))
	else:
		g_man.player.weapon_controller.weapon.distance *= weapon_range
		DataBase.insert(_server, g_man.dbms, _path, "weapon_range", id, float(g_man.player.weapon_controller.weapon.distance))

func save_weapon_reflexes(weapon_reflexes, default: bool = false):
	if default:
		_weapon_reflexes = 3
	_weapon_reflexes *= weapon_reflexes
	DataBase.insert(_server, g_man.dbms, _path, "weapon_reflexes", id, float(_weapon_reflexes))
	#endregion save
	#region load
func load_username():
	avatar_name = DataBase.select(_server, g_man.dbms, _path, "username", id, "")

func load_return_position():
	var position = DataBase.select(_server, g_man.dbms, _path, "position", id, Vector3.ZERO)
	return Vector2(position.x, position.y)

func load_return_user_time_change_name():
	return DataBase.select(_server, g_man.dbms, _path, "time_changed_name", id, 0)

func load_return_user_type(type):
	return DataBase.select(_server, g_man.dbms, _path, "type", id, 0)

func load_gold_coins():
	gold_coins = DataBase.select(_server, g_man.dbms, _path, "gold_coins", id, 500)

func load_weapon():
	g_man.player.weapon_controller.weapon.activated = DataBase.select(_server, g_man.dbms, _path, "weapon", id, false)

func load_battery_constumption():
	g_man.player.weapon_controller.weapon.battery_constumption = DataBase.select(_server, g_man.dbms, _path, "battery_constumption", id, 75)
	g_man.player.weapon_controller.weapon.battery_constumption = 75
	save_battery_constumption(1)

func load_weapon_range():
	g_man.player.weapon_controller.weapon.distance = DataBase.select(_server, g_man.dbms, _path, "weapon_range", id, 75)

func load_weapon_reflexes():
	_weapon_reflexes = DataBase.select(_server, g_man.dbms, _path, "weapon_reflexes", id, 3)
	#endregion load
#endregion save load
func set_weapon(activate):
	g_man.player.weapon_controller.weapon.activated = activate
	if activate:
		save_weapon_activated(activate)
