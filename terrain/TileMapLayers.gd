class_name TileMapLayers extends Node

@export var ground_layer: Array[TileMapLayer]
@export var save: bool
@export var timer: Timer
@export var navigation_region_2d: NavigationRegion2D

#region grund layer
var dict_ground_pos___id__left: Array#[Dictionary[Vector2i, Array]]
var dict_ground_pos__dirt: Dictionary[Vector2i, int]

var savables: Terrain
var array_layer_loaded: Array[bool]
#endregion grund layer

var active_layer: int = 0

const NEW_ROCK_ARRAY: Array = [Tile.ROCK, 35]
enum Tile{
	EMPTY = -1,
	CLAY = 0,
	DIRT = 1,
	GRASS = 2,
	ROCK = 3,
	SOFT_ROCK = 4,
	TUNNEL = 5, ## goes down
	SOFT_ROCK_TUNNEL = 6, ## goes up
	SOFT_ROCK_UNDERGROUND = 7,
	FAKE_TUNNEL = 8, ## it's where mobs come from
	HOUSE = 9,
	HOUSE_DOOR = 10
}
enum Left{
	CLAY = 5,
	DIRT = 4,
	GRASS = 1,
	ROCK = 20,
	SOFT_ROCK = 7,
	TUNNEL = 0,
	SOFT_ROCK_TUNNEL = 0,
	SOFT_ROCK_UNDERGROUND = 15,
	FAKE_TUNNEL = 0
}
## overwrite -> overwrite all tiles except tunnel
## discard -> add only on tiles that don't exist yet
## add -> add on top of the tile
enum RegionActionType{
	OVERWRITE,
	DISCARD,
	ADD
}
enum Layers{
	GROUND_LAYER = 0,
	HOUSE_LAYER = 4
}

func bake():
	if not navigation_region_2d.is_baking():
		#await navigation_region_2d.bake_finished
		navigation_region_2d.bake_navigation_polygon()

func load_map():
	if savables.array_layers__dict_ground_pos___id__left:
		dict_ground_pos___id__left[0] = savables.array_layers__dict_ground_pos___id__left[0]
		dict_ground_pos___id__left[1] = savables.array_layers__dict_ground_pos___id__left[1]
		dict_ground_pos___id__left[2] = savables.array_layers__dict_ground_pos___id__left[2]
		dict_ground_pos___id__left[3] = savables.array_layers__dict_ground_pos___id__left[3]
	if not dict_ground_pos___id__left[0]:
		set_new_terrain()
	reload_terrain()
	timer.timeout.connect(change_dirt_to_grass_overtime)
	timer.start(45)

func change_dirt_to_grass_overtime():
	change_ground_dirt()

func _ready() -> void:
	g_man.tile_map_layers = self
	for i in ground_layer.size():
		dict_ground_pos___id__left.push_back({})
		array_layer_loaded.push_back(false)
	GlobalSignals.select_tile_node.connect(add_or_dig)

func destroy_me():
	GlobalSignals.select_tile_node.disconnect(add_or_dig)

## does not set active layer only replaces it IT NEEDS to replace with old active layer before end of frame
func active_layer_temporary_new_return_old(new_active_layer) -> int:
	var old_active_layer = active_layer
	active_layer = new_active_layer
	return old_active_layer

## just to know the function where it is called from
func active_layer_replace_with_old(old_active_layer):
	active_layer = old_active_layer

func get_position_by_mouse_position() -> Vector2i:
	return ground_layer[active_layer].local_to_map(ground_layer[active_layer].get_local_mouse_position())

func get_position_by_global_position(global_position) -> Vector2i:
	return ground_layer[active_layer].local_to_map(ground_layer[active_layer].to_local(global_position) )

func get_id_by_global_position(global_position):
	var position: Vector2i = get_position_by_global_position(global_position)
	var cell_id = ground_layer[active_layer].get_cell_source_id(position)
	return cell_id

func add_or_dig(entity, mouse_global_position, callable):
	var index = entity
	if entity is Entity:
		index = entity.entity_num
	
	if index == 0:
		g_man.holding_hand.holding_hand_dig()
		dig(mouse_global_position)
		return
	var position: Vector2i = get_position_by_mouse_position()
	var cell_id = ground_layer[active_layer].get_cell_source_id(position)
	if not (cell_id == Tile.TUNNEL or cell_id == Tile.SOFT_ROCK_TUNNEL or cell_id == Tile.FAKE_TUNNEL or cell_id == Tile.HOUSE or cell_id == Tile.HOUSE_DOOR):
		if index == Enums.Esprite.dirt:
			add(Tile.DIRT, entity.quantity, callable)
		elif index == Enums.Esprite.clay:
			add(Tile.CLAY, entity.quantity, callable)
		elif index == Enums.Esprite.rock:
			add(Tile.ROCK, entity.quantity, callable)

func add(id, quantity, callable):
	g_man.holding_hand.holding_hand_drop()
	var position: Vector2i = ground_layer[active_layer].local_to_map(ground_layer[active_layer].get_local_mouse_position())
	_fill_around(position)
	var cell_id = ground_layer[active_layer].get_cell_source_id(position)
	
	if cell_id == Tile.FAKE_TUNNEL:
		return
	
	if not add_on_top(position, id, true, cell_id, quantity) == false:
		callable.call()

func dig(mouse_global_position: Vector2):
	if save and not active_layer < ground_layer.size():
		return
	var position: Vector2i = ground_layer[active_layer].local_to_map(ground_layer[active_layer].get_local_mouse_position())
	# get data
	var id = ground_layer[active_layer].get_cell_source_id(position)
	if id == -1:
		return
	_fill_around(position)
	
	var data_array = get_data_array_from_position(id, position)
	if id == Tile.TUNNEL:
		g_man.changes_manager.add_change("you went a layer underground")
		in_to_tunnel()
		return
	if id == Tile.SOFT_ROCK_TUNNEL:
		g_man.changes_manager.add_change("you went a layer up to the surface")
		up_to_the_surface()
		return
	if id == Tile.FAKE_TUNNEL:
		return
	if id == Tile.HOUSE:
		return
	if id == Tile.HOUSE_DOOR:
		return
	# dig
	var new_id_type = dig_in_to_tile(data_array, position)
	# id duged
	if not (id == Tile.EMPTY or id == Tile.TUNNEL or id == Tile.SOFT_ROCK_TUNNEL):
		g_man.entity_manager.create_entity_in_world(id, mouse_global_position)
	# change tile
	if new_id_type != null and new_id_type is int:
		set_ground_cell(position, new_id_type, active_layer)
	if not new_id_type is bool:
		g_man.changes_manager.add_change(str("you dug a ", str(Tile.find_key(id)).to_lower().replace("_", " ")))
#region in to change layer
func in_to_tunnel():
	activate_layer(active_layer +1)
	g_man.holding_hand.holding_hand_underground()
	
func up_to_the_surface():
	activate_layer(active_layer -1)
	g_man.holding_hand.holding_hand_to_surface()

func in_to_house(vec):
	activate_layer(Layers.HOUSE_LAYER)
	return ground_layer[active_layer].map_to_local(vec) + Vector2(0, - 10)

func out_of_house(vec):
	activate_layer(Layers.GROUND_LAYER)
	return ground_layer[active_layer].map_to_local(vec) * 0.5 + Vector2(0, 100)

func activate_layer(new_layer: Layers):
	@warning_ignore("int_as_enum_without_cast")
	new_layer = clampi(new_layer, 0, ground_layer.size() -1)
	
	ground_layer[active_layer].enabled = false
	active_layer = new_layer
	ground_layer[active_layer].enabled = true
	g_man.player.layer = active_layer
	if active_layer == Layers.GROUND_LAYER:
		g_man.map.activate(true)
	else:
		g_man.map.activate(false)
	g_man.entity_manager.activate_layer(active_layer)
	reload_terrain()
	bake()
	# save layer on user
	g_man.user.save_layer(active_layer)
	# position is saved at PlayerWeaponController
	# set sound
	if active_layer == Layers.HOUSE_LAYER:
		g_man.player.rain_particles.start_in_door_sfx()
	elif active_layer == Layers.GROUND_LAYER:
		g_man.player.rain_particles.start_out_door_sfx()
	else:
		g_man.player.rain_particles.start_in_door_sfx()

#endregion in to change layer
#region dirt reference
	#region set
func set_ground_cell(position: Vector2i, id: int, layer: int):
	# to not have underground grass I don't set dirts up here
	if id == Tile.DIRT and layer == 0:
		dict_ground_pos__dirt.set(position, id)
	elif layer == 0:
		dict_ground_pos__dirt.erase(position)
	# save
	var array_data_array = dict_ground_pos___id__left[layer].get(position)
	if not array_data_array:
		array_data_array = [NEW_ROCK_ARRAY.duplicate(true)]
		dict_ground_pos___id__left[layer].set(position, array_data_array)
	if save:
		#savables.save_position__array_data_array(position, layer, array_data_array)
		savables.save_array_layers_and_all(dict_ground_pos___id__left)
	# set floor
	ground_layer[layer].set_cell(position, id, Vector2i.ZERO)
	bake()
	#endregion set
	#region change
func change_ground_dirt(random: float = 0.025):
	
	var temp_active_layer = active_layer
	active_layer = Layers.GROUND_LAYER
	
	var dict = dict_ground_pos__dirt.duplicate(true)
	for position in dict:
		if randf_range(0, 1) < random:
			var array__data_array = dict_ground_pos___id__left[active_layer].get(position)
			remove_one(array__data_array, position)
			add_on_top(position, Tile.GRASS)
	active_layer = temp_active_layer
	#endregion change
#region override cell
func override_fake_tunnel(position, id = 8):
	var before_id = ground_layer[0].get_cell_source_id(position)
	if before_id == Tile.FAKE_TUNNEL:
		return false
	ground_layer[0].set_cell(position, id, Vector2i.ZERO)
	return [ground_layer[0].map_to_local(position), before_id]

func override_fake_tunnel_back(position, id):
	ground_layer[0].set_cell(position, id, Vector2i.ZERO)
#endregion override cell
#endregion dirt reference
#region generating new terrain
func set_new_terrain():
	#set_region(Rect2i(0, 0, 20, 10), [[Tile.DIRT, 1]], [Vector2i(5, 8)], RegionActionType.ADD, true, 0.8, [Tile.DIRT, 2], Vector2i(3, 4))
	#set_region(Rect2i(0, 10, 20, 10), [[Tile.CLAY, 1], [Tile.DIRT, 1]], [Vector2i(8, 12), Vector2i(10, 15)], RegionActionType.OVERWRITE, true, 0.3, [Tile.DIRT, 2], Vector2i(3, 6))
	set_region(Rect2i(10, 3, 5, 3), [[Tile.CLAY, 3], [Tile.DIRT, 1]], [Vector2i(3, 6), Vector2i(1, 3)], RegionActionType.ADD, true, 0.2, [Tile.CLAY, 4], Vector2i(3, 8))
	#set_region(Rect2i(0, 0, 20, 1), [[Tile.ROCK, 1]], [Vector2i(20, 30)], RegionActionType.OVERWRITE, false)
	#set_region(Rect2i(0, 0, 1, 20), [[Tile.ROCK, 1]], [Vector2i(20, 30)], RegionActionType.OVERWRITE, false)
	#set_region(Rect2i(0, 20, 20, 1), [[Tile.ROCK, 1]], [Vector2i(20, 30)], RegionActionType.OVERWRITE, false)
	#set_region(Rect2i(20, 0, 1, 21), [[Tile.ROCK, 1]], [Vector2i(20, 30)], RegionActionType.OVERWRITE, false)
	reload_terrain()
	bake()
## example:
##
## Rect2i(0, 10, 20, 10), [[Tile.CLAY, 1], [Tile.DIRT, 1]], [Vector2i(8, 12), Vector2i(10, 15)], true, true, 0.3, [Tile.DIRT, 2], Vector2i(3, 6)
func set_region(region: Rect2i, data_arrays: Array, data_arrays_range: Array = [], action_type: RegionActionType = RegionActionType.OVERWRITE, grass_on_top: bool = true, grass_random: float = 1, other_tile_instead_of_grass: Array = [Tile.DIRT, 2], other_tile_range: Vector2i = Vector2i(1, 1)):
	save = false
	for x in range(region.position.x, region.position.x + region.size.x):
		for y in range(region.position.y, region.position.y + region.size.y):
			var duplicate_data_arrays = data_arrays.duplicate(true)
			for i in data_arrays_range.size():
				if duplicate_data_arrays.size() > i:
					duplicate_data_arrays[i][1] = randi_range(data_arrays_range[i].x, data_arrays_range[i].y)
			var grass
			if grass_on_top:
				grass = [Tile.GRASS, 1]
				if randf_range(0, 1) > grass_random:
					var duplicate_other_tile = other_tile_instead_of_grass.duplicate(true)
					duplicate_other_tile[1] = randi_range(other_tile_range.x, other_tile_range.y)
					grass = duplicate_other_tile
			if action_type == RegionActionType.OVERWRITE or action_type == RegionActionType.DISCARD:
				# if it has tile don't do nothing and continue with next tile
				if action_type == RegionActionType.DISCARD:
					if dict_ground_pos___id__left[active_layer].has(Vector2i(x, y)):
						continue
				# if tile is tunnel don't overwrite it
				var tile = dict_ground_pos___id__left[active_layer].get(Vector2i(x, y))
				if tile:
					if tile[0][0] == Tile.TUNNEL:
						#print("there's tunnel")
						continue
				dict_ground_pos___id__left[active_layer][Vector2i(x, y)] = duplicate_data_arrays
				if grass:
					dict_ground_pos___id__left[active_layer].get(Vector2i(x, y)).push_back(grass)
			elif action_type == RegionActionType.ADD:
				var old_data: Array = dict_ground_pos___id__left[active_layer].get(Vector2i(x, y), [])
				if old_data:
					# underneeth won't be grass any longer
					if old_data[old_data.size() - 1][0] == Tile.GRASS:
						old_data[old_data.size() - 1][0] = Tile.DIRT
				old_data.append_array(duplicate_data_arrays)
				if grass:
					old_data.push_back(grass)
				dict_ground_pos___id__left[active_layer][Vector2i(x, y)] = old_data
			# when data is done
			var _array_data_array = dict_ground_pos___id__left[active_layer][Vector2i(x, y)]
			if _array_data_array:
				var _data_array = _array_data_array[_array_data_array.size() - 1]
				set_ground_cell(Vector2i(x, y), _data_array[0], active_layer)
	save = true

func reload_terrain():
	save = false
	if array_layer_loaded[active_layer]:
		save = true
		return
	else:
		array_layer_loaded[active_layer] = true
	var layer = dict_ground_pos___id__left[active_layer]
	for position in layer:
		var array_data_array = layer.get(position)
		if array_data_array:
			var id = array_data_array[array_data_array.size() - 1][0]
			set_ground_cell(position, id, active_layer)
		else:
			push_error("layer is probably empty should never be: ", layer)
			printerr("layer is probably empty should never be: ", layer)
			g_man.changes_manager.add_key_change("CRITICAL ERROR 2:", str("layer is probably empty should never be: ", layer.get(position)))
	save = true

func add_on_top(position: Vector2i, tile: Tile = Tile.GRASS, override: bool = false, below_tile: Tile = Tile.GRASS, quantity: int = 1):
	var array__data_array = dict_ground_pos___id__left[active_layer].get(position)
	if array__data_array:
		var data_array = array__data_array[array__data_array.size() - 1]
		# can't add on this type of tiles only if override
		if data_array[0] == Tile.ROCK and not override:
			return false
		# can't add on this type of tiles
		if data_array[0] == Tile.TUNNEL or data_array[0] == Tile.SOFT_ROCK_TUNNEL:
			return false
		if data_array[0] == tile:
			if tile == Tile.GRASS:
				# remove on end
				remove_one(array__data_array, position)
				if array__data_array:# if it still has tiles
					data_array = array__data_array[array__data_array.size() - 1]
					if data_array[0] == Tile.DIRT:# if last tile is dirt add to it and push back GRASS
						data_array[1] += 1
						# push back new tile
						array__data_array.push_back([tile, quantity])
					else:# add 2 tiles
						array__data_array.append_array([[Tile.DIRT, 1], [tile, quantity]])
						pass
				else:# add 2 tiles if it's empty
					array__data_array.append_array([[Tile.DIRT, 1], [tile, quantity]])
			else:# not grass and same tile add to it
				data_array[1] += quantity
		else:# if tile is not same as bottom tile just add to it
			array__data_array.append_array([[tile, quantity]])
			set_ground_cell(position, tile, active_layer)
	else:
		var material_name = Tile.find_key(below_tile)
		
		dict_ground_pos___id__left[active_layer].set(position, [[below_tile, Left[material_name]], [tile, quantity]])
		set_ground_cell(position, tile, active_layer)

func remove_one(array_data_array: Array, position: Vector2i):
	if array_data_array:
		var data_array = array_data_array[array_data_array.size() - 1]
		if data_array[1] > 0:
			data_array[1] -= 1
		if data_array[1] <= 0:
			change_to_new_tile(data_array, position)
			if array_data_array.size() > 1:
				array_data_array.pop_back()
			
#endregion generating new terrain
#region fill empty
## only position it makes rock around empty tiles
func _fill_around(position, id = Tile.SOFT_ROCK, rect: Rect2i = Rect2i(0, 0, 0, 0)):
	save = false
	if rect == Rect2i(0, 0, 0, 0):
		var first = 0
		var second = 2
		if position.y % 2 == 0:
			first = -1
			second = 1
		_fill_first_second(position, first, second, -1)
		_fill_first_second(position, first, second, 1)
		_fill_left_to_right(position)
	else:
		set_region(rect, [[id, 20]], [], RegionActionType.DISCARD, false)
		# top
		set_region(Rect2i(rect.position.x-1, rect.position.y - 1, rect.size.x + 2, 1), [[Tile.ROCK, 10]], [], RegionActionType.DISCARD, false)
		# left
		set_region(Rect2i(rect.position.x-1, rect.position.y - 1, 1, rect.size.y + 2), [[Tile.ROCK, 10]], [], RegionActionType.DISCARD, false)
		# right
		set_region(Rect2i(rect.position.x + rect.size.x, rect.position.y, 1, rect.size.y + 1), [[Tile.ROCK, 10]], [], RegionActionType.DISCARD, false)
		# bottom
		set_region(Rect2i(rect.position.x, rect.position.y + rect.size.y, rect.size.x, 1), [[Tile.ROCK, 10]], [], RegionActionType.DISCARD, false)
	save = true
	
func _fill_first_second(position, first, second, y):
	save = false
	for x in range(first, second):
		_fill_position(position, x, y)
	save = true

func _fill_left_to_right(position):
	save = false
	for x in range(-1, 2):
		_fill_position(position, x, 0)
	save = true

func _fill_position(position, x, y):
	var new_position: Vector2i = position + Vector2i(x, y)
	var id = ground_layer[active_layer].get_cell_source_id(new_position)
	if id == Tile.EMPTY:
		set_ground_cell(position + Vector2i(x, y), Tile.ROCK, active_layer)
#endregion fill empty
#region get new data
## set if it doesn't exist yet
func get_data_array_from_position(id, position):
	var data_array = dict_ground_pos___id__left[active_layer].get(position)
	if not data_array:
		if id == Tile.ROCK:
			data_array = NEW_ROCK_ARRAY.duplicate(true)
		elif id == Tile.CLAY:
			data_array = [Tile.CLAY, Left.CLAY]
		elif id == Tile.DIRT:
			data_array = [Tile.DIRT, Left.DIRT]
		elif id == Tile.GRASS:
			data_array = [Tile.GRASS, Left.GRASS]
		elif id == Tile.SOFT_ROCK:
			data_array = [Tile.SOFT_ROCK, Left.SOFT_ROCK]
		elif id == Tile.TUNNEL:
			data_array = [Tile.TUNNEL, Left.TUNNEL]
		dict_ground_pos___id__left[active_layer].set(position, [data_array])
		return [data_array]
	return data_array
#endregion get new data
#region change data
## returns new tile type (id)
func dig_in_to_tile(array__data_array: Array, position):
	var data_array = array__data_array[array__data_array.size() - 1]
	if array__data_array.size() == 1:
		if data_array[1] == 1:# change to new tile
			return change_to_new_tile(data_array, position)
		if data_array[1] == 0:# reload terrain
			return data_array[0]
	else:# still has some tiles left
		if data_array[1] == 1:
			#change tile
			array__data_array.pop_back()
			# if grass is underneeth replace it to dirt
			if array__data_array[array__data_array.size() -1][0] == Tile.GRASS:
				array__data_array[array__data_array.size() -1][0] = Tile.DIRT
			return array__data_array[array__data_array.size() -1][0]
	# remove 1 layer from the tile
	if data_array[1] != Left.TUNNEL:
		data_array[1] -= 1
		array__data_array[array__data_array.size() - 1] = data_array
		if data_array[1] != 0:
			if data_array[0] == Tile.GRASS:
				return data_array[0]

func change_to_new_tile(data_array: Array, position: Vector2i):
	if data_array[0] == Tile.ROCK:
		if active_layer > 0:
			data_array[0] = Tile.SOFT_ROCK_UNDERGROUND
			data_array[1] = Left.SOFT_ROCK_UNDERGROUND
		else:
			data_array[0] = Tile.SOFT_ROCK
			data_array[1] = Left.SOFT_ROCK
	elif data_array[0] == Tile.GRASS: # if dirt was change_ground_dirt in to grass and it's last of it's kind change it in to something else 2 else it's emdless loop
		data_array[0] = Tile.SOFT_ROCK
		data_array[1] = Left.SOFT_ROCK
	elif data_array[0] == Tile.DIRT:
		data_array[0] = Tile.SOFT_ROCK
		data_array[1] = Left.SOFT_ROCK
	elif data_array[0] == Tile.CLAY:
		data_array[0] = Tile.DIRT
		data_array[1] = Left.DIRT
	elif data_array[0] == Tile.SOFT_ROCK or data_array[0] == Tile.SOFT_ROCK_UNDERGROUND:# create tunnel
		var temp_active_layer = active_layer + 1
		temp_active_layer = clampi(temp_active_layer, 0, ground_layer.size() -1)
		if active_layer == temp_active_layer:
			g_man.changes_manager.add_change("cannot dig deeper")
			return false
		
		var big_fill_around = true
		
		var array__data_array_underneeth = dict_ground_pos___id__left[temp_active_layer].get(position)
		if array__data_array_underneeth:
			var data_array_underneeth = array__data_array_underneeth[array__data_array_underneeth.size() -1]
			if data_array_underneeth[0] == Tile.TUNNEL:
				g_man.changes_manager.add_change("can't dig in to tunnel underneeth")
				return false
			elif data_array_underneeth[0] == Tile.SOFT_ROCK_TUNNEL:
				g_man.changes_manager.add_change("should never happen up is already tunnel to up on surface")
				
			big_fill_around = false
		# dig tunnel
		data_array[0] = Tile.TUNNEL
		data_array[1] = Left.TUNNEL
		# underneeth
		dict_ground_pos___id__left[temp_active_layer][position] = [[Tile.SOFT_ROCK_TUNNEL, 0]]
		active_layer = temp_active_layer
		if big_fill_around:
			_fill_around(position, Tile.SOFT_ROCK_UNDERGROUND, Rect2i(position.x - 1, position.y - 1, 3, 3))
		else:
			_fill_around(position)
		active_layer -= 1
	else:
		g_man.changes_manager.add_change(str("CRITICAL ERROR 1:", "wrong data type: ", Tile.find_key(data_array[0])))
		push_error("wrong data type: ", Tile.find_key(data_array[0]))
		printerr("wrong data type: ", Tile.find_key(data_array[0]))
	return data_array[0]
#endregion change data
