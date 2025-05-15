class_name EntityButtonInventory extends TextureRect

@export var dragging_sprite: PackedScene
@export var slot_texture: TextureRect
@export var quantity_label: Label
var inventory_slot: InventorySlot
var entity

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {
		"inv_node" = self,
		"tex" = slot_texture.texture
	}
	if entity:
		var sprite: DraggingSprite = dragging_sprite.instantiate()
		sprite.texture = slot_texture.texture
		sprite.entity = entity
		sprite.entity_button_inventory = self
		sprite.can_change_quantity = true
		sprite.quantity = entity.quantity
		sprite.refresh_quantity()
		g_man.entity_manager.add_child_to_dragging(sprite)
		data["entity"] = entity
		data["dragging_sprite"] = sprite
		
		if g_man.trader_manager._trader:
			var user_gold_coins = g_man.user.gold_coins
			g_man.trader_manager.sell_for.text = str("sell for: ", Entity.cost(false, entity.entity_num, user_gold_coins, g_man.trader_manager._trader.gold_coins))
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if (entity and data.get("node2d")) or not data.get("entity"):
		var entity_number_buy = data.get("buy")
		# it is picked from ground and goes through inventory that has already entity
		if not entity_number_buy:
			return false
		elif entity:
			return false
		var trader: Trader = data.get("trader")
		var user: User = g_man.user
		var cost = Entity.cost(true, entity_number_buy, user.gold_coins, trader.gold_coins)
		cost = cost * data.get("dragging_sprite").quantity
		
		if cost <= user.gold_coins:
			return true
		return false
	if data.get("finished_product") and entity:
		return false
	return true

func drop_data_quantity_update(e, _quantity, data):
	e.quantity -= _quantity
	e.save_quantity()
	if e.quantity <= 0:
		e.destroy_me()
	update_entity()
	var origin_node = data.get("inv_node")
	if origin_node:
		origin_node.update_entity()
		return
	origin_node = data.get("node2d")
	if origin_node:
		origin_node.queue_free()
		g_man.inventory_system.add_remove_hover_over_sprite(-1)
		g_man.holding_hand.holding_hand_inventory()
		return
	origin_node = data.get("finished_product")
	if origin_node:
		origin_node.set_entity(null)
		return

func get_dragging_sprite_drop_quantity(e, data):
	var _dragging_sprite = data.get("dragging_sprite")
	var _quantity = e.quantity
	if _dragging_sprite:
		_quantity = _dragging_sprite.quantity
	return _quantity

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	g_man.inventory_system.dragging = false
	
	var origin_node = data.get("inv_node")
	
	# target is changed
	var temp_entity = entity
	var e: Entity = data.get("entity")
	if e:
		# split
		if temp_entity and temp_entity.entity_num == e.entity_num:
			var _quantity = get_dragging_sprite_drop_quantity(e, data)
			temp_entity.add_quantity(_quantity)
			drop_data_quantity_update(e, _quantity, data)
			return
		# split on empty tile
		if not temp_entity:
			var _quantity = get_dragging_sprite_drop_quantity(e, data)
			entity = Entity.create_from_scratch(e.entity_num, true, false, true)
			entity.quantity = _quantity
			drop_data_quantity_update(e, _quantity, data)
			return
		# change entity for entity (they aren't same)
		else:
			change_entity(e, self)
	
	var temp_texture = slot_texture.texture
	slot_texture.texture = data.get("tex")
	
	reset_trader_manager_cost()
	
	#overwrite origin is changed
	if origin_node:
		change_entity(temp_entity, origin_node)
		origin_node.slot_texture.texture = temp_texture
		return
	else:
		origin_node = data.get("node2d")
		if origin_node:
			origin_node.queue_free()
			g_man.inventory_system.add_remove_hover_over_sprite(-1)
			g_man.holding_hand.holding_hand_inventory()
			return
		origin_node = data.get("finished_product")
		if origin_node:
			origin_node.set_entity(null)
			return
	
	# buy from trader
	var entity_number_buy = data.get("buy")
	var trader: Trader = data.get("trader")
	var user: User = g_man.user
	var cost = Entity.cost(true, entity_number_buy, user.gold_coins, trader.gold_coins)
	var quantity = data.get("dragging_sprite").quantity
	cost = cost * quantity
	
	user.gold_coins -= cost
	user.save_gold_coins()
	trader.gold_coins += cost
	trader.save_gold_coins()
	g_man.trader_manager.recount_gold()
	entity = Entity.create_from_scratch(entity_number_buy, true, false, true)
	entity.quantity = quantity
	entity.save_quantity()
	quantity_label.text = str(quantity)
	inventory_slot.id_entity = entity.id
	inventory_slot.save_id_entity()
	g_man.holding_hand.holding_hand_trader_buy()

func reset_trader_manager_cost():
	g_man.trader_manager.sell_for.text = ""
	g_man.trader_manager.buy_for.text = ""

func change_entity(_entity, node: EntityButtonInventory):
	node.entity = _entity
	if _entity:
		node.inventory_slot.id_entity = _entity.id
		node.quantity_label.text = str(_entity.quantity)
	else:
		node.inventory_slot.id_entity = 0
		node.quantity_label.text = ""
	node.set_tooltip()
	node.inventory_slot.save_id_entity()

func update_entity():
	if entity:
		var entity_obj = mp.get_item_object(entity.entity_num)
		update_texture(entity_obj.texture)
		set_tooltip()
		update_quantity()
	else:
		update_texture(null)
	

func set_tooltip():
	if entity:
		tooltip_text = entity.to_string_name()
	else:
		tooltip_text = ""

func update_texture(_texture):
	slot_texture.texture = _texture
	if not _texture:
		entity = null
		quantity_label.text = ""

func update_quantity():
	if entity:
		quantity_label.text = str(entity.quantity)
	else:
		quantity_label.text = ""
