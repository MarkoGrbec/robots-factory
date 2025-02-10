class_name DraggingSprite extends Sprite2D

var entity
var entity_button_inventory: EntityButtonInventory

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if Input.is_action_just_released("select"):
		var local_position = g_man.camera.global_position - global_position
		var q_opened = true
		if g_man.quests_manager.is_visible_in_tree():
			q_opened = local_position.x < -125
		# boundries of inventory
		if (local_position.x > -125 or local_position.y < -40) and q_opened and entity:
			g_man.entity_manager.drop_entity_in_world(entity, g_man.entity_manager.get_global_mouse_position(), g_man.tile_map_layers.active_layer)
			entity_button_inventory.update_texture(null)
			entity_button_inventory.inventory_slot.id_entity = 0
			entity_button_inventory.inventory_slot.save_id_entity()
		queue_free()
