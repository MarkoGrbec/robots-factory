class_name QQDeep extends ISavable

var index
var basis
var i

func copy():
	return QQDeep.new()

func fully_load():
	load_index()

func partly_load():
	fully_load()

func save_index():
	DataBase.insert(_server, g_man.dbms, _path, "index", id, index)

func load_index():
	index = DataBase.select(_server, g_man.dbms, _path, "index", id, -1)

func save_basis():
	DataBase.insert(_server, g_man.dbms, _path, "basis", id, basis)

func load_basis():
	basis = DataBase.select(_server, g_man.dbms, _path, "basis", id, -1)
