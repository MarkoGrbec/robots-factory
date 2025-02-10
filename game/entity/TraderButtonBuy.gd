class_name TraderButtonBuy extends TextureRect

@export var entity_num: Enums.Esprite
@export var slot_texture: TextureRect
@export var dragging_sprite: PackedScene

var trader: Trader

func _ready() -> void:
	var e_obj = mp.get_item_object(entity_num)
	if e_obj:
		slot_texture.texture = e_obj.texture
	tooltip_text = str(str(Enums.Esprite.find_key(entity_num)).replace("_", " "), " cost around: ", e_obj.cost * 0.6)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {
		"buy" = entity_num,
		"trader" = trader,
		"tex" = slot_texture.texture
	}
	var node: DraggingSprite = dragging_sprite.instantiate()
	node.texture = slot_texture.texture
	g_man.entity_manager.add_child_to_dragging(node)
	
	var user_gold_coins = g_man.user.get_index_data(1).gold_coins
	g_man.trader_manager.buy_for.text = str("costs: ", Entity.cost(true, entity_num, user_gold_coins, trader.gold_coins))
	
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return false
