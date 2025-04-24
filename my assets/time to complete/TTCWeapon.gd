class_name TTCWeapon extends ITimeComplete

func _init(weapon: Weapon):
	if not weapon.activated:
		g_man.changes_manager.add_change("you need weapon to fire")
		queue_free()
		return
	_weapon = weapon
	if weapon:
		var weapon_obj: EntityObject = mp.get_item_object(_weapon.entity_num)
		delay_sound = weapon_obj.delay_sound
		is_sound_on_end = weapon_obj.is_sound_on_end
		working_sound = weapon_obj.working_sound
		start_delay_sound = 0
		one_shot = weapon_obj.sound_one_shot
	if check():
		g_man.sliders_manager.add_work(self)
	else:
		queue_free()

var _weapon: Weapon

func stop():
	queue_free()

func start_of_ttc():
	var constumption = check_constumption()
	if constumption:
		g_man.sliders_manager.mana_slider.value -= constumption
		# fire
		_weapon.fire_weapon(true)
		return true
	return false

func set_complete_time():
	var entity_object
	if _weapon:
		entity_object = mp.get_item_object(_weapon.entity_num)
	if entity_object:
		working_sound = entity_object.working_sound
		delay_sound = entity_object.delay_sound
		
		#var exps = entity_object.experience_use
		
		var _min_time = entity_object.time_to_finish_min
		var _max_time = entity_object.time_to_finish_max
		#var exp_level: int = g_man.experience_manager.get_exp_level(exps)
		var exp_level = 1
		
		var user: User = g_man.user
		calc_time_to_complete(exp_level, user._weapon_reflexes, user._weapon_reflexes)
		
		hard = entity_object.hard_use
		hard *= user._weapon_reflexes
	else:
		hard = 3
		calc_time_to_complete(1, 1, 3)

func to_string_name():
	return "TTCWeapon"

func check():
	if g_man.sliders_manager.mana_slider.value <= 0 or g_man.sliders_manager.waiting_work or not check_constumption():
		g_man.changes_manager.add_change("battery is empty")
		return false
	return true

func check_constumption():
	var strength
	# gathering crafting weapon strength so battery constumption is faster
	if g_man.user.weapon_strength == 1:
		strength = g_man.user.weapon_strength
	# fighting strength so battery constumption is slower
	else:
		strength = g_man.user.weapon_strength * 0.2
	
	var constumption = ((_weapon.distance * strength) / _weapon.battery_constumption)
	# if enough battery fire
	if g_man.sliders_manager.mana_slider.value >= constumption:
		return constumption
	return false
