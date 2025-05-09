class_name ConstructionManager extends TabContainer

@export var entity_button_construction: PackedScene

@export var results_grid: GridContainer

@export var tool: EntityButtonConstruction
@export var workpiece: EntityButtonConstruction
@export var finished_product: EntityButtonConstruction

var window_manager: WindowManager

func _ready() -> void:
	window_manager = get_parent()
	window_manager.set_id_window(2, "construction manager")
	g_man.construction_manager = self

func open_close_window():
	if is_visible_in_tree():
		close_window()
	else:
		open_window()

func open_window():
	# crafting fork
	if g_man.user and g_man.user.load_return_user_type() == 2:
		tool.set_entity(Entity.get_entity(g_man.user.load_return_id_tool()))
		workpiece.set_entity(Entity.get_entity(g_man.user.load_return_id_workpiece()))
		finished_product.set_entity(Entity.get_entity(g_man.user.load_return_id_finished_product()))
		fetch_results()
		g_man.quests_manager.close_window()
		window_manager.open_window()
		set_anchors()
	else:
		g_man.changes_manager.add_change("you cannot craft you need to learn how to craft first")

func close_window():
	window_manager.close_window()
	set_anchors()

func set_anchors():
	pass
	if is_visible_in_tree():
		if g_man.inventory_system.is_visible_in_tree():
			window_manager.set_relative_size(0.6, true, true)
		else:
			window_manager.set_relative_size(0.6, true, false)

func add_tool(entity):
	if entity:
		g_man.user.save_id_tool(entity.id)
	else:
		g_man.user.save_id_tool(null)
	fetch_results()

func add_workpiece(entity):
	if entity:
		g_man.user.save_id_workpiece(entity.id)
	else:
		g_man.user.save_id_workpiece(null)
	fetch_results()

func add_finished_product(entity):
	if entity:
		g_man.user.save_id_finished_product(entity.id)
	else:
		g_man.user.save_id_finished_product(null)

func destroy_entity_workpiece():
	if workpiece.entity:
		if workpiece.entity.quantity == 1:
			workpiece.destroy_entity()
			fetch_results()
		else:
			workpiece.entity.quantity -= 1
			workpiece.counter.text = str(workpiece.entity.quantity)

func fetch_results():
	var _tool = tool.entity
	var _workpiece = workpiece.entity
	
	for child in results_grid.get_children():
		child.queue_free()
	
	if not _workpiece:
		return
	
	# make tool null or get tool entity_num
	var tool_entity_num = Enums.Esprite.nul
	if _tool:
		tool_entity_num = _tool.entity_num
	
	var results = mp.get_work_pieces(tool_entity_num, _workpiece.entity_num)
	if results:
		for result in results:
			var result_slot: EntityButtonConstruction = entity_button_construction.instantiate()
			results_grid.add_child(result_slot)
			
			result_slot.entity = result
			result_slot.slot_texture.texture = mp.get_item_object(result).texture
			result_slot.tooltip_text = str(Enums.Esprite.find_key(result)).replace("_", " ")
			result_slot.counter.text = str(1)
