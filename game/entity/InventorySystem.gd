class_name InventorySystem extends TabContainer

@export var inventory_slot_scene: PackedScene
@export var grid_container_inventory_slots: GridContainer

var window_manager: WindowManager
var picked_entity
var dragging: bool = false
var hover_over_sprite: int = 0


func _ready() -> void:
	window_manager = get_parent()
	window_manager.set_id_window(2, "inventory")
	g_man.inventory_system = self

func close_window():
	window_manager.close_window()
	g_man.quests_manager.set_anchors()
	g_man.construction_manager.set_anchors()

func open_window(open: bool = false):
	if is_visible_in_tree():
		if not open:
			close_window()
		return
	else:
		window_manager.open_window()
		g_man.quests_manager.set_anchors()
		g_man.construction_manager.set_anchors()

func generate_inventory_slots():
	var rang = range(1, 21)
	if g_man.tutorial:
		rang = range(22, 42)
	for i in rang:
		var slot:InventorySlot = g_man.savable_inventory_slot.get_or_set(i, false)
		slot.entity_button_inventory = inventory_slot_scene.instantiate()
		slot.entity_button_inventory.inventory_slot = slot
		grid_container_inventory_slots.add_child(slot.entity_button_inventory)
		if not g_man.tutorial:
			slot.fully_load()

func destroy_inventory_slots():
	for slot in grid_container_inventory_slots.get_children():
		slot.queue_free()

func add_remove_hover_over_sprite(counter):
	hover_over_sprite += counter
	hover_over_sprite = clampi(hover_over_sprite, 0, 10000)

func drag_inventory(data):
	force_drag(data, self)
