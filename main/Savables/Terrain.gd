class_name Terrain extends ISavable

var array_layers__dict_ground_pos___id__left: Array#: Array[Dictionary[Vector2i, Array]]

var terrain_resource: TerrainRes = TerrainRes.new()
var save_path = "user://save/"
var save_file_name = "terrain.tres"

func verify_save_dir():
	DirAccess.make_dir_absolute(save_path)

func load_terrain():
	terrain_resource = ResourceLoader.load(save_path + save_file_name).duplicate(true)

func save_terrain():
	ResourceSaver.save(terrain_resource, save_path + save_file_name)

func copy():
	return Terrain.new()

#region fully
func fully_load():
	if not array_layers__dict_ground_pos___id__left:
		partly_load()

func fully_save():
	partly_save()
#endregion fully
#region partly
func partly_load():
	verify_save_dir()
	load_terrain()
	array_layers__dict_ground_pos___id__left = terrain_resource.array_layers__dict_ground_pos___id__left
	#array_layers__dict_ground_pos___id__left.clear()
	#for i in 5:
		#array_layers__dict_ground_pos___id__left.push_back({})
	#load_new_terrain_style()

func partly_save():
	pass
#endregion partly
#region delete all
func destroy():
	remove_all()

func remove_all():
	g_man.savable_multi_tarrain_user__layer.remove_all()
	g_man.savable_multi_terrain_layer__quadrant.remove_all()
	g_man.savable_multi_terrain_quadrant__cell.remove_all()

#endregion delete all
#region save load
func save_position__array_data_array(position: Vector2i, layer: int, array_data_array: Array):
	array_layers__dict_ground_pos___id__left.resize(5)
	array_layers__dict_ground_pos___id__left.fill({})
	var positions = array_layers__dict_ground_pos___id__left[layer].get_or_add({})
	var _array_data_array = positions.get_or_add(position)
	_array_data_array = array_data_array
	terrain_resource.array_layers__dict_ground_pos___id__left = array_layers__dict_ground_pos___id__left
	verify_save_dir()
	save_terrain()
	#var id_quadrant_index = get_unique(position)
	#var quadrant = id_quadrant_index[0]
	#var id_index = id_quadrant_index[1]
	#save_new_terrain_style(quadrant, id_index, position, layer, array_data_array)

func save_new_terrain_style(quadrant, id_index, position, layer, array_data_array):
	if g_man.user:
		var user_layer: TerrainUser_Layer = g_man.savable_multi_tarrain_user__layer.new_data(g_man.user.id, layer)
		var layer_quadrant: TerrainLayer_Quadrant = g_man.savable_multi_terrain_layer__quadrant.new_data(user_layer.id, quadrant)
		var quadrant_cell: TerrainQuadrant_Cell = g_man.savable_multi_terrain_quadrant__cell.new_data(layer_quadrant.id, id_index)
		quadrant_cell.save_data(position, layer, array_data_array)

func load_new_terrain_style():
	if g_man.user:
		var user_layers = g_man.savable_multi_tarrain_user__layer.get_all(g_man.user.id, 0)
		for layer: TerrainUser_Layer in user_layers:
			if layer:
				var layer_quadrants = g_man.savable_multi_terrain_layer__quadrant.get_all(layer.id, 0)
				for quadrant: TerrainLayer_Quadrant in layer_quadrants:
					if quadrant:
						var cells = g_man.savable_multi_terrain_quadrant__cell.get_all(quadrant.id, 0)
						for cell: TerrainQuadrant_Cell in cells:
							if cell:
								var position__array_data_array__layer = cell.load_data()
								if position__array_data_array__layer and position__array_data_array__layer[1]:
									array_layers__dict_ground_pos___id__left[position__array_data_array__layer[2]].set(Vector2i(position__array_data_array__layer[0]), position__array_data_array__layer[1])

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
	@warning_ignore("integer_division")
	return ( ((coord.x + coord.y) * (coord.x + coord.y)) / 2 + coord.y ) + 2
#endregion id unique
