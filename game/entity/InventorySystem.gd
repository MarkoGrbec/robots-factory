class_name InventorySystem extends TabContainer

@export var inventory_slot_scene: PackedScene
var dragging: bool = false
var hover_over_sprite: int = 0
@export var grid_container_inventory_slots: GridContainer
var picked_entity

func _ready() -> void:
	g_man.inventory_system = self

func close_window():
	hide()
	g_man.quests_manager.set_anchors()

func open_window(open: bool = false):
	if is_visible_in_tree():
		if not open:
			close_window()
		return
	else:
		show()
		g_man.quests_manager.set_anchors()

func generate_inventory_slots():
	for i in range(1, 21):
		var slot:InventorySlot = g_man.savable_inventory_slot.get_or_set(i, false)
		slot.entity_button_inventory = inventory_slot_scene.instantiate()
		slot.entity_button_inventory.inventory_slot = slot
		grid_container_inventory_slots.add_child(slot.entity_button_inventory)
		slot.fully_load()

func add_remove_hover_over_sprite(counter):
	hover_over_sprite += counter
	hover_over_sprite = clampi(hover_over_sprite, 0, 10000)

func drag_inventory(data):
	force_drag(data, self)
