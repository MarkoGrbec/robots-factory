class_name DraggingSprite extends Sprite2D

@export var quantity_label: Label
var quantity = 1
var entity
var entity_button_inventory: EntityButtonInventory

var can_change_quantity = false

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if Input.is_action_just_released("select"):
		var local_position = g_man.camera.global_position - global_position
		var q_opened = true
		var c_opened = true
		if g_man.quests_manager.is_visible_in_tree():
			q_opened = local_position.x < -125
		if g_man.construction_manager.is_visible_in_tree():
			c_opened = local_position.x < -125
		# boundries of inventory
		if entity_button_inventory and (local_position.x > -125 or local_position.y < -40) and q_opened and c_opened and entity:
			# make entity in world as it didn't go in any of the slots
			g_man.entity_manager.drop_entity_in_world(entity, g_man.entity_manager.get_global_mouse_position(), g_man.tile_map_layers.active_layer)
			entity_button_inventory.update_texture(null)
			entity_button_inventory.inventory_slot.id_entity = 0
			entity_button_inventory.inventory_slot.save_id_entity()
		queue_free()
	if can_change_quantity:
		if Input.is_action_just_pressed("plus stack"):
			quantity += 1
			refresh_quantity()
		elif Input.is_action_just_pressed("minus stack"):
			quantity -= 1
			refresh_quantity()

func refresh_quantity():
	quantity = clampi(quantity, 1, 20)
	quantity_label.text = str(quantity)
