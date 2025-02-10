class_name EntityMaterial extends ISavable
#region Constructors
func copy():
	return EntityMaterial.new()

func set_material(set_weight, material):
	weight = set_weight
	type_material = material
#endregion Constructors
#region Destructor
## destroy material of this entity
## id_entity: it has to be
## id_material: if it's 0 they are all destroyed of this id_entity
static func destroy_me(_id_entity, id_material):
	g_man.savable_multi_entity__material.delete_p_s(_id_entity, id_material)

#endregion Destructor
#region inputs
var weight
var id_entity
var type_material: Enums.material
var metal
## weight cooked 3X overweight means it's burned
var cooked: float = 0
#endregion inputs
#region change weight
## weight: add weight to me
## set_it: set it or just add it
func change_weight(add_weight: float, set_it: bool):
	if set_it:
		weight = add_weight
	else:
		weight += add_weight
	if weight <= 0:
		var entity: Entity = Entity.get_entity(id_entity)
		entity.materials.erase(self)
		g_man.savable_multi_entity__material.delete_id_row(id)
		return weight
	save_weight()
	return true
#func change_weight_depend_on_per_ratio(old_per_ratio, new_per_ratio):
	#weight = (1 - old_per_ratio + new_per_ratio) * weight
#endregion change weight
#region burn/cool/digest
## damage: damage from entity which is made with burning
## returns: [[above liquid border is true below it's calculated burn], [damage], [current_heat], [air]]
func burn(damage, current_heat, air, k):
	var mat_obj = mp.material_container[type_material]
	# water cools down materials
	if mat_obj.type_material == Enums.material.water:
		current_heat = clampf(current_heat, -273, 100)
	else:
		current_heat = clampf(current_heat, -273, 5000)
	if current_heat >= mat_obj.burn_start:
		var added_heat = mat_obj.burn_speed
		if mat_obj.burn_speed < air:
			added_heat = air
		if weight < added_heat:
			added_heat = weight
		current_heat += (added_heat * mat_obj.burn_strength) * k
		weight -= mat_obj.burn_speed * k
		air -= (added_heat * mat_obj.burn_strength) * k
		if type_material == Enums.material.wood:
			damage = mat_obj.burn_speed * k# * 0.001
		# save weight
		if k != 1:
			save_weight()
	elif current_heat >= mat_obj.liquid_border:
		return [true, damage, current_heat, air]
	## it only applies to cooking materials
	elif mat_obj.type_material > 8 and current_heat >= mat_obj.cooking_border:
		# burned meal
		if current_heat >= mat_obj.cooking_burn:
			cooked = weight * 3
		# cooking meal
		else:
			cooked += weight * (0.005 * 6) # 0.5g * 6 seconds
		save_cooked()
	return [false, damage, current_heat, air]

func cool(current_heat):
	var mat_obj = mp.material_container[type_material]
	return current_heat < mat_obj.liquid_border

func digest(current_heat):
	if type_material > Enums.material.water:
		var mat_obj = mp.material_container[type_material]
		# if it's sutable for eating
		if current_heat < 50:
			var eating_speed_ratio = clampf(cooked / weight, 0.01, 3)
			# cannot digest it's burned
			if eating_speed_ratio == 3:
				return
			# if it's warm
			var warm = current_heat / 37
			eating_speed_ratio += warm * 0.03
			# digest
			change_weight(-eating_speed_ratio, false)
			cooked -= eating_speed_ratio
			cooked = clampf(cooked, 0, cooked)
			save_weight()
			save_cooked()
			# how much energy can be taken out
			return [eating_speed_ratio, mat_obj.energy]
#endregion Burn/Cool
#region save
func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "id_entity", id, id_entity)
	DataBase.insert(_server, g_man.dbms, _path, "material", id, type_material)
	DataBase.insert(_server, g_man.dbms, _path, "metal", id, metal)
	save_weight()

func save_weight():
	DataBase.insert(_server, g_man.dbms, _path, "weight", id, weight)

func save_cooked():
	DataBase.insert(_server, g_man.dbms, _path, "cooked", id, weight)
#endregion save
#region load
func fully_load():
	id_entity = DataBase.select(_server, g_man.dbms, _path, "id_entity", id)
	type_material = DataBase.select(_server, g_man.dbms, _path, "material", id)
	metal = DataBase.select(_server, g_man.dbms, _path, "metal", id)
	weight = DataBase.select(_server, g_man.dbms, _path, "weight", id)
#endregion
