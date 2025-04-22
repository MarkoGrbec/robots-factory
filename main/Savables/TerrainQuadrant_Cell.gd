class_name TerrainQuadrant_Cell extends ISavable

var layer
var position
var array_data_array

func copy():
	return TerrainQuadrant_Cell.new()

func destroy():
	layer = null
	position = null
	array_data_array = null
	fully_save()
	##DEBUGGING :TODO:
	#fully_load()

func fully_save():
	save_uni("position", position)
	save_uni("array_data_array", array_data_array)
	save_uni("layer", layer)

func fully_load():
	position = load_uni("position")
	array_data_array = load_uni("array_data_array")
	layer = load_uni("layer")
	pass

func save_data(_position, _layer, _array_data_array):
	position = _position
	array_data_array = _array_data_array
	layer = _layer
	fully_save()

func load_data():
	fully_load()
	return [position, array_data_array, layer]
