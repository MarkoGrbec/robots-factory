class_name Terrain extends ISavable

var dict_ground_pos___id__left: Dictionary[Vector2i, Array]

func copy():
	return Terrain.new()

#region fully
func fully_load():
	if not dict_ground_pos___id__left:
		partly_load()

func fully_save():
	partly_save()
#endregion fully
#region partly
func partly_load():
	load_position__array_data()

func partly_save():
	pass
#endregion partly
#region delete all
func remove_all():
	remove_quadrant(1)
	remove_quadrant(2)
	remove_quadrant(3)
	remove_quadrant(4)
	remove_quadrant(5)

func remove_quadrant(quadrant):
	var str_arr = get_quadrant_string(quadrant)
	var last_id = DataBase.last_id(_server, g_man.dbms, _path, str_arr[0])
	if last_id:
		for i in range(1, last_id):
			DataBase.insert(_server, g_man.dbms, _path, str_arr[0], i, null)
#endregion delete all
#region save load
func save_position__array_data_array(position: Vector2i, array_data_array: Array):
	var id_quadrant_index = get_unique(position)
	var quadrant = id_quadrant_index[0]
	var id_index = id_quadrant_index[1]
	var str_quadrant = get_quadrant_string(quadrant)
	
	DataBase.reserve(_server, g_man.dbms, _path, str_quadrant[0], 1048576)
	DataBase.insert(_server, g_man.dbms, _path, str_quadrant[0], id_index, position)
	
	DataBase.reserve(_server, g_man.dbms, _path, str_quadrant[1], 10480576)
	DataBase.insert(_server, g_man.dbms, _path, str_quadrant[1], id_index, array_data_array)

func load_position__array_data():
	load_position__array_data_from_quadrant(1)
	load_position__array_data_from_quadrant(2)
	load_position__array_data_from_quadrant(3)
	load_position__array_data_from_quadrant(4)
	load_position__array_data_from_quadrant(5)

func load_position__array_data_from_quadrant(quadrant: int):
	var str_arr = get_quadrant_string(quadrant)
	var str_pos = str_arr[0]
	var str_arr_data = str_arr[1]
	var last_id = DataBase.last_id(_server, g_man.dbms, _path, str_pos)
	if last_id:
		for i in last_id:
			var position = DataBase.select(_server, g_man.dbms, _path, str_pos, i, Vector2.ZERO)
			var data_array = DataBase.select(_server, g_man.dbms, _path, str_arr_data, i, [])
			if data_array:
				dict_ground_pos___id__left.set(Vector2i(position), data_array)

func get_quadrant_string(quadrant):
	var str_pos = "position"
	var str_arr = "array_data"
	if quadrant == 5:
		str_pos = str(str_pos, "_c")
		str_arr = str(str_arr, "_c")
	elif quadrant == 1:
		str_pos = str(str_pos, "_br")
		str_arr = str(str_arr, "_br")
	elif quadrant == 2:
		str_pos = str(str_pos, "_bl")
		str_arr = str(str_arr, "_bl")
	elif quadrant == 3:
		str_pos = str(str_pos, "_tr")
		str_arr = str(str_arr, "_tr")
	elif quadrant == 4:
		str_pos = str(str_pos, "_tl")
		str_arr = str(str_arr, "_tl")
	return [str_pos, str_arr]
#endregion save load
#region id unique
func get_unique(coord: Vector2i):
	var id_index
	if coord == Vector2i.ZERO:
		id_index = [5, 1]
	# bottom right
	elif coord.x >= 0 and coord.y >= 0:
		id_index = [1, _coord_unique(coord)]
	# bottom left
	elif coord.x <= 0 and coord.y >= 0:
		id_index = [2, _coord_unique(coord)]
	# top right
	elif coord.x >= 0 and coord.y <= 0:
		id_index = [3, _coord_unique(coord)]
	# top left
	elif coord.x <= 0 and coord.y <= 0:
		id_index = [4, _coord_unique(coord)]
	return id_index

func _coord_unique(coord: Vector2i):
	coord = abs(coord)
	coord += Vector2i(1,1)
	return ( ((coord.x + coord.y) * (coord.x + coord.y)) / 2 + coord.y )+ 2
#endregion id unique
