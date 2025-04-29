class_name ConstructionManager extends TabContainer

@export var entity_button_construction: PackedScene

@export var results_grid: GridContainer

@export var tool: EntityButtonConstruction
@export var workpiece: EntityButtonConstruction
@export var finished_product: EntityButtonConstruction

func _ready() -> void:
	g_man.construction_manager = self

func open_close_window():
	if is_visible_in_tree():
		close_window()
	else:
		open_window()

func open_window():
	tool.set_entity(Entity.get_entity(g_man.user.load_return_id_tool()))
	workpiece.set_entity(Entity.get_entity(g_man.user.load_return_id_workpiece()))
	finished_product.set_entity(Entity.get_entity(g_man.user.load_return_id_finished_product()))
	fetch_results()
	g_man.quests_manager.close_window()
	show()

func close_window():
	hide()

func set_anchors():
	if is_visible_in_tree():
		if g_man.inventory_system.is_visible_in_tree():
			anchor_right = 0.609
		else:
			anchor_right = 1

func add_tool(entity):
	if entity:
		g_man.user.save_id_tool(entity.id)
	else:
		g_man.user.save_id_tool(null)
	#if workpiece.entity:
	fetch_results()

func add_workpiece(entity):
	if entity:
		g_man.user.save_id_workpiece(entity.id)
	else:
		g_man.user.save_id_workpiece(null)
	#if tool.entity:
	fetch_results()

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
	
	if not _tool or not _workpiece:
		return
	
	var results = mp.get_work_pieces(_tool.entity_num, _workpiece.entity_num)
	if results:
		for result in results:
			var result_slot: EntityButtonConstruction = entity_button_construction.instantiate()
			results_grid.add_child(result_slot)
			
			result_slot.entity = result
			result_slot.slot_texture.texture = mp.get_item_object(result).texture
