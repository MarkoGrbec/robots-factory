class_name Mob extends ISavable


var position: Vector2
var layer: int
var entity_num: Enums.Esprite
var body
func copy():
	return Mob.new()

func fully_load():
	load_position()
	load_entity_num()

func partly_load():
	partly_loaded = 2
	fully_load()
	body = CreateMob.target_create_bot(position, entity_num, id)

func fully_save():
	save_position()
	save_entity_num()

func destroy():
	if body:
		body.queue_free()

#region position
func save_position():
	DataBase.insert(_server, g_man.dbms, _path, "position", id, position)

func load_position():
	position = DataBase.select(_server, g_man.dbms, _path, "position", id, Vector2.ZERO)
#endregion position
#region entity num
func save_entity_num():
	DataBase.insert(_server, g_man.dbms, _path, "entity_num", id, entity_num)

func load_entity_num():
	entity_num = DataBase.select(_server, g_man.dbms, _path, "entity_num", id, Enums.Esprite.nul)
#endregion entity num
#region entity num
func save_layer():
	DataBase.insert(_server, g_man.dbms, _path, "layer", id, layer)

func load_layer():
	layer = DataBase.select(_server, g_man.dbms, _path, "layer", id, g_man.tile_map_layers.active_layer)
#endregion entity num
