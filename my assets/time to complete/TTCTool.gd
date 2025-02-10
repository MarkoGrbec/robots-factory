class_name TTCTool extends ITimeComplete
func _init(tool, point, dig: Callable):
	_dig = dig
	_tool = tool
	_point = point
	if tool:
		var tool_obj: EntityObject = mp.get_item_object(_tool.entity_num)
		delay_sound = tool_obj.delay_sound
		is_sound_on_end = tool_obj.is_sound_on_end
		working_sound = tool_obj.working_sound
	if check():
		g_man.sliders_manager.add_work(self)

var _dig: Callable
var _tool
#region dig
var _point: Vector2
#endregion dig
var finished: bool = false
func complete():
	finished = true
	# dig
	_dig.call(_point)

func stop():
	if not finished:
		_point = Vector2.ZERO
		_dig.call(false)
	queue_free()

func set_complete_time():
	var entity_object
	if _tool:
		entity_object = mp.get_item_object(_tool.entity_num)
	#else:
		#entity_object = mp.get_item_object(Enums.Esprite.right_hand)
	if entity_object:
		working_sound = entity_object.working_sound
		delay_sound = entity_object.delay_sound
		
		var exps = entity_object.experience_use
		
		var min_time = entity_object.time_to_finish_min
		var max_time = entity_object.time_to_finish_max
		var exp_level: int = 1#g_man.experience_manager.get_exp_level(exps)
		calc_time_to_complete(exp_level, min_time, max_time)
		
		hard = entity_object.hard_use
	else:
		hard = 4.55
		calc_time_to_complete(1, 1, 2)

func to_string_name():
	return "TTCTool"

func check():
	return true
	#if harvest_tool_needed == Enums.Esprite.undefined or harvest_tool_needed == _tool.entity_num:
		#return true
	#if _tool.entity_num == Enums.Esprite.shovel or _tool.entity_num == Enums.Esprite.pickaxe or _tool.entity_num == Enums.Esprite.hatchet:
		#return true
