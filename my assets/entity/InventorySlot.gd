class_name InventorySlot extends ISavable

var id_entity: int
var entity_button_inventory: EntityButtonInventory

func copy():
	return InventorySlot.new()

func destroy():
	id_entity = 0
	save_id_entity()

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
		var entity: Entity = g_man.savable_entity.get_index_data(id_entity)
		entity_button_inventory.entity = entity
		if entity:
			var entity_object: EntityObject = mp.get_item_object(entity.entity_num)
			entity_button_inventory.update_texture(entity_object.texture)
			entity_button_inventory.quantity_label.text = entity.quantity
