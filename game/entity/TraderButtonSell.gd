class_name TraderButtonSell extends TextureRect

@export var slot_texture: TextureRect
@export var timer: Timer
var trader: Trader


func _ready() -> void:
	timer.timeout.connect(update_texture)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not (data.get("node2d") or data.get("inv_node")) or not data.get("entity"):
		return false
	var entity = data.get("entity")
	var user: User = g_man.user.get_index_data(1)
	var cost = Entity.cost(false, entity.entity_num, user.gold_coins, trader.gold_coins)
	if trader.gold_coins >= cost:
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# target is changed
	var entity: Entity = data.get("entity")
	
	slot_texture.texture = data.get("tex")
	timer.start()
	
	#overwrite origin is changed
	var origin_node = data.get("inv_node")
	if origin_node:
		origin_node.entity = null
		origin_node.inventory_slot.id_entity = 0
		origin_node.inventory_slot.save_id_entity()
		origin_node.slot_texture.texture = null
	else:
		origin_node = data.get("node2d")
		if origin_node:
			origin_node.queue_free()
			g_man.inventory_system.dragging = false
			g_man.inventory_system.add_remove_hover_over_sprite(-1)
	
	var user: User = g_man.user.get_index_data(1)
	var cost = Entity.cost(false, entity.entity_num, user.gold_coins, trader.gold_coins)
	trader.gold_coins -= cost
	trader.save_gold_coins()
	user.gold_coins += cost
	user.save_gold_coins()
	entity.destroy_me()
	g_man.trader_manager.sell_for.text = ""
	g_man.trader_manager.buy_for.text = ""

func update_texture(tex = null):
	slot_texture.texture = tex
	g_man.trader_manager.recount_gold()
