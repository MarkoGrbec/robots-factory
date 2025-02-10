class_name EntitySpriteWorld extends EntityBase2D

@export var sprite: Sprite2D
@export var static_body_2d: StaticBody2D
var selected = false
var entity: Entity

func _ready() -> void:
	g_man.trader_manager.sell_for.text = ""
	g_man.trader_manager.buy_for.text = ""
	g_man.holding_hand.holding_hand_drop()

func destroy_me():
	entity.destroy_me()
	queue_free()

func _process(delta: float) -> void:
	if selected:
		global_position = get_global_mouse_position()
		if Input.is_action_just_released("right mouse button"):
			g_man.inventory_system.dragging = false
			static_body_2d.set_collision_layer_value(1, true)
			g_man.inventory_system.add_remove_hover_over_sprite(-1)
			GlobalSignals.select_tile_node.emit(entity.entity_num, global_position, destroy_me)
			selected = false
		elif Input.is_action_just_released("left mouse button"):
			g_man.inventory_system.dragging = false
			g_man.entity_manager.reparent_to_layer(self, g_man.tile_map_layers.active_layer)
			static_body_2d.set_collision_layer_value(1, true)
			selected = false
			entity.pos = global_position
			entity.save_position_rotation()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if not g_man.inventory_system.dragging:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					selected = true
					g_man.inventory_system.dragging = true
					g_man.entity_manager.reparent_dragging(self)
					static_body_2d.set_collision_layer_value(1, false)
					var data = {
						"entity" = entity,
						"tex" = sprite.texture,
						"node2d" = self
					}
					
					if g_man.trader_manager._trader:
						var user_gold_coins = g_man.user.get_index_data(1).gold_coins
						g_man.trader_manager.sell_for.text = str("sell for: ", Entity.cost(false, entity.entity_num, user_gold_coins, g_man.trader_manager._trader.gold_coins))
					
					g_man.inventory_system.drag_inventory(data)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					static_body_2d.set_collision_layer_value(1, false)
					g_man.inventory_system.dragging = true
					selected = true


func _on_area_2d_mouse_entered() -> void:
	g_man.inventory_system.add_remove_hover_over_sprite(1)


func _on_area_2d_mouse_exited() -> void:
	g_man.inventory_system.add_remove_hover_over_sprite(-1)
