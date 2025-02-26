class_name EntityButtonQuest extends TextureRect

@export var slot_texture: TextureRect
@export var timer: Timer

var entity: Entity

func _ready() -> void:
	timer.timeout.connect(update_texture)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not (data.get("node2d") or data.get("inv_node")) or not data.get("entity"):
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	g_man.inventory_system.dragging = false
	# target is changed
	var e: Entity = data.get("entity")
	e.add_to_parent(entity, true, null)
	
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
			g_man.inventory_system.add_remove_hover_over_sprite(-1)
	if origin_node and g_man.tutorial:
		g_man.holding_hand.holding_hand_npc_give_item()

func update_texture(tex = null):
	slot_texture.texture = tex
	g_man.quests_manager.recount_entities()
