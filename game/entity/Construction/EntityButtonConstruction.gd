class_name EntityButtonConstruction extends Node

enum ButtonType{
	TOOL,
	WORKPIECE,
	RESULT,
	FINISHED_PRODUCT
}

@export var dragging_sprite: PackedScene
@export var slot_texture: TextureRect
@export var counter: Label
@export var button_type: ButtonType

var entity

func set_entity(_entity):
	entity = _entity
	if button_type == ButtonType.TOOL:
		g_man.construction_manager.add_tool(entity)
	elif button_type == ButtonType.WORKPIECE:
		g_man.construction_manager.add_workpiece(entity)
	elif button_type == ButtonType.FINISHED_PRODUCT:
		g_man.construction_manager.add_finished_product(entity)
	recount()

func recount():
	if entity:
		var entity_obj: EntityObject = mp.get_item_object(entity.entity_num)
		slot_texture.tooltip_text = entity.to_string_name()
		slot_texture.texture = entity_obj.texture
		counter.text = str(entity.quantity)
	else:
		slot_texture.tooltip_text = ""
		slot_texture.texture = null
		counter.text = ""

func destroy_entity():
	if entity:
		entity.destroy_me()
		entity = null
		slot_texture.texture = null
		counter.text = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	if not button_type == ButtonType.RESULT:
		data["entity"] = entity
		data["finished_product"] = self
		if entity:
			data["tex"] = slot_texture.texture
			var sprite: DraggingSprite = dragging_sprite.instantiate()
			sprite.texture = slot_texture.texture
			sprite.entity = entity
			#sprite.entity_button_inventory = self
			sprite.quantity_label.text = str(entity.quantity)
			g_man.entity_manager.add_child_to_dragging(sprite)
			data["entity"] = entity
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# if it's not correct data at all
	if not (data.get("node2d") or data.get("inv_node") or data.get("finished_product")):# or not data.get("entity"):
		return false
	# if it's result never drop data
	if button_type == ButtonType.RESULT or button_type == ButtonType.FINISHED_PRODUCT:
		return false
	# if node 2d and entity exists don't add it
	if data.get("node2d") and entity:
		return false
	var button_construction: EntityButtonConstruction = data.get("finished_product")
	if button_construction:
		if button_type == ButtonType.WORKPIECE or button_type == ButtonType.TOOL:
			if button_construction.button_type == ButtonType.TOOL or button_construction.button_type == ButtonType.WORKPIECE:
				return false
		# if entity exists on finished product don't drag it here
		if entity and button_construction.button_type == ButtonType.FINISHED_PRODUCT:
			return false
	# everything else can be added even finished product
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	g_man.inventory_system.dragging = false
	
	var temp_entity = entity
	var temp_texture = slot_texture.texture
	# target is changed
	var e: Entity = data.get("entity")
	set_entity(e)
	
	if button_type == ButtonType.TOOL:
		g_man.construction_manager.add_tool(entity)
	elif button_type == ButtonType.WORKPIECE:
		g_man.construction_manager.add_workpiece(entity)
	
	#overwrite origin is changed
	var origin_node = data.get("inv_node")
	if origin_node:
		if change_entity(temp_entity, temp_texture, origin_node):
			pass
		else:
			origin_node.entity = null
			origin_node.slot_texture.texture = null
	else:
		origin_node = data.get("node2d")
		if origin_node:
			origin_node.queue_free()
			g_man.inventory_system.add_remove_hover_over_sprite(-1)
		else:
			origin_node = data.get("finished_product")
			if origin_node:
				origin_node.entity = null
				origin_node.recount()
	if origin_node:
		pass
		#g_man.holding_hand.holding_hand_npc_give_item()


func _on_gui_input(event: InputEvent) -> void:
	if button_type == ButtonType.RESULT:
		if event.is_action_pressed("select"):
			if not g_man.construction_manager.finished_product.entity:
				var new_entity = Entity.create_from_scratch(entity, true, false, false)
				g_man.construction_manager.finished_product.set_entity(new_entity)
				g_man.construction_manager.destroy_entity_workpiece()
				g_man.changes_manager.add_change("select")
			elif g_man.construction_manager.finished_product.entity.entity_num == entity:
				g_man.construction_manager.finished_product.entity.quantity += 1
				g_man.construction_manager.finished_product.entity.save_quantity()
				g_man.construction_manager.finished_product.recount()
				g_man.construction_manager.destroy_entity_workpiece()

func change_entity(_entity, tex, node: EntityButtonInventory):
	node.entity = _entity
	if _entity:
		node.inventory_slot.id_entity = _entity.id
		node.quantity_label.text = str(_entity.quantity)
		node.slot_texture.texture = tex
	else:
		node.inventory_slot.id_entity = 0
		node.quantity_label.text = ""
	node.inventory_slot.save_id_entity()
	if _entity:
		return true
