class_name EntityButtonInventory extends TextureRect

@export var dragging_sprite: PackedScene
@export var slot_texture: TextureRect
var inventory_slot: InventorySlot
var entity

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {
		"inv_node" = self,
		"tex" = slot_texture.texture
	}
	if entity:
		var sprite = dragging_sprite.instantiate()
		sprite.texture = slot_texture.texture
		sprite.entity = entity
		sprite.entity_button_inventory = self
		g_man.entity_manager.add_child_to_dragging(sprite)
		data["entity"] = entity
		
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
		if cost <= user.gold_coins:
			return true
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	g_man.inventory_system.dragging = false
	# target is changed
	var temp_entity = entity
	var e = data.get("entity")
	if e:
		change_entity(e, self)
	
	var temp_texture = slot_texture.texture
	slot_texture.texture = data.get("tex")
	
	reset_trader_manager_cost()
	
	#overwrite origin is changed
	var origin_node = data.get("inv_node")
	if origin_node:
		#origin_node.entity = temp_entity
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
	# buy from trader
	var entity_number_buy = data.get("buy")
	var trader: Trader = data.get("trader")
	var user: User = g_man.user
	var cost = Entity.cost(true, entity_number_buy, user.gold_coins, trader.gold_coins)
	user.gold_coins -= cost
	user.save_gold_coins()
	trader.gold_coins += cost
	trader.save_gold_coins()
	g_man.trader_manager.recount_gold()
	entity = Entity.create_from_scratch(entity_number_buy, true, false, true)
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
	else:
		node.inventory_slot.id_entity = 0
	node.inventory_slot.save_id_entity()

func update_texture(_texture):
	slot_texture.texture = _texture
	if not _texture:
		entity = null
