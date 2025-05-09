class_name InventorySlot extends ISavable

var id_entity: int
var entity_button_inventory: EntityButtonInventory

func copy():
	return InventorySlot.new()

func destroy():
	id_entity = 0
	save_id_entity()

func set_id_entity_and_entity(_id_entity):
	id_entity = _id_entity
	save_id_entity()
	set_entity()
	

func save_id_entity():
	DataBase.insert(_server, g_man.dbms, _path, "id_entity", id, id_entity)
	if id_entity:
		var entity: Entity = Entity.get_entity(id_entity)
		if entity:
			entity.special = id
			entity.save_special()

func load_id_entity():
	id_entity = DataBase.select(_server, g_man.dbms, _path, "id_entity", id, 0)

func fully_load():
	load_id_entity()
	if id_entity:
		set_entity()

func set_entity():
	var entity: Entity = g_man.savable_entity.get_index_data(id_entity)
	entity_button_inventory.entity = entity
	if entity:
		entity_button_inventory.update_entity()
