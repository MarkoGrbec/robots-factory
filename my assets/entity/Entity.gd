class_name Entity extends ISavable


#region input
##<summary>for server</summary>
#//[NonSerialized] private Savable<Entity> NSLServerEntity
#// [NonSerialized] private List<MOBDiedData> ListDeadEntities
#//[NonSerialized] public NullList<EntityMaterial> NSLMaterials
#//[NonSerialized] public DataBase.MultiTable MultiEntityMaterial
##<summary>for ally warehouses when have they been updated</summary>


#[NonSerialized] public static Dictionary<long, float> timeOfChangeWareHouse = new Dictionary<long, float>()



## factor how much is it multiplied maybe some times varies depends on sinus and time by month by time newly started character
const _K_FACTOR: float = 1
const _K_DAMAGE: float = 0.0001
const _K_COST: float = 0.85
static var _K_DAMAGE_IMP_REPAIR: float = 0.05
const _K_REPAIR: float = 10
static var _K_HARD: float = 0.075
## at 100 it's 1.5 times bigger ql
#const _K_EXP: float = 0.005
#const min_ql: float = 0.1
#const MIN_WEIGHT_PERCENT: float = 0.92
#const MAX_WEIGHT_PERCENT: float = 1.2
## bigger slower it cools
#const SLOW_DOWN_COOL: float = 17
## how much heat does make start burning [fire]
#const START_BURNING: float = 45
var parent = 0
var container: Array[int]
var e_container: Array[Entity]
var entity_num: Enums.Esprite = Enums.Esprite.nul
var entity_string: String
var body
#var batch_entity_server
var pos = Vector2.ZERO
var rot = Vector2.ZERO
#var volume: float = 0
#var group_volume: float = 0
#var ql: float = 1000
var quantity = 1
var damage: float = 0
## how much I weight in kilo grams
#var weight: float = 0
## how much weight all children weights
#var group_weight: float = 0
#var per_ratio: float = 1
## if it's already fully constructed
#var constructed: bool = true
#var imp_tool: Enums.Esprite = Enums.Esprite.undefined
var special = 0
var layer = 0
#var id_avatar: int = 0
#var current_heat: float = 49
#var time_heat: float = 0
#var air: float = 0

#var materials: Array[EntityMaterial]


#endregion end input
func copy():
	return Entity.new()


#region constuctors
static func _create_from_scratch_with_volume(sprite: Enums.Esprite, _volume: float) -> Entity:
	var e: Entity = g_man.savable_entity.get_set_new()
	e.entity_num = sprite
	e._calc_weight_from_new_volume(_volume)
	return e
## world space
func config_world_space(sprite:Enums.Esprite, position:Vector3, rotation:Vector3, is_entity:bool, is_constructed:bool):
	entity_num = sprite
	create_me_and_header(self, position, rotation)
	#push_error(entity_num, " ", weight)
	# if it's real entity not construct material needed to replace
	#if is_entity:
		#set_volume_weight(entity_num)
	reset_container()
	
	#/*if(sprite == Esprite.warehouse){
		#DeadByDawn.singleton.customerSpawner.Add(body)
	#}*/
	save_position_rotation()
	#if is_constructed:
		#create_construct()
	fully_save()

static func create_me_and_header(entity: Entity, position, rotation):
	if not entity.body:
		var header = mp.create_me(Enums.Esprite.plan_entity)
		header.global_position = position
		header.global_rotation = rotation
		entity.body = mp.create_me(entity.entity_num)
		entity.body.server = true
		var entity_object = mp.get_item_object(entity.entity_num)
		if entity_object.is_container:
			entity.body.is_container = entity_object.is_container
			entity.body.inventory = entity
		
		entity.body.reparent(header)
		entity.body.id = entity.id
		entity.body.global_rotation = rotation
		entity.body.global_position = position
		entity.pos = position
		entity.rot = rotation
		return header

## entity with parent
static func create_entity_with_parent(sprite: Enums.Esprite, param_parent: Entity, is_entity: bool, is_constructed: bool, force: bool):
	var e: Entity = g_man.savable_entity.get_set_new()
	e.entity_num = sprite
	if is_entity:
		e.set_volume_weight(e.entity_num)
	if e.add_to_parent(param_parent, force, null):
		#if is_constructed:
			#e.create_construct()
		e.fully_save()
		return e
	else:
		e.destroy_me()

## new entity with custom weight and parent
## parent: parent of self entity always needs it</param>
## weight: custom weight</param>
## is_entity: if it's entity</param>
## is_constructed: if it's going to be constructed</param>
## per_stone: how much % is minimum stone / random what remains will be iron</param>
static func create_from_scratch_with_weight(sprite: Enums.Esprite, param_parent: Entity,
	new_weight: float, is_entity: bool, is_constructed: bool, k_stone: float = 1) -> Entity:
	var e: Entity = g_man.savable_entity.get_set_new()
	e.entity_num = sprite
	if is_entity:
		e.weight = new_weight
		#e.calc_per_ratio()
		#e.calc_volume()
		#e.add_materials(k_stone)
	
	e.add_to_parent(param_parent, true, null)
	#if is_constructed:
		#e.create_construct()
	e.fully_save()
	return e

## ment for making from scratch
func config_from_scratch(sprite: Enums.Esprite, is_entity: bool, is_constructed: bool, default_material: bool):
	entity_num = sprite
	#if is_entity:
		#set_volume_weight(entity_num)
	reset_container()
	# not mix makes something
	#if default_material:
		#add_materials()
	
	#if is_constructed:
		#create_construct()
	fully_save()

## new from scratch
static func create_from_scratch(sprite: Enums.Esprite, is_entity: bool, is_constructed: bool, default_material: bool, default_ql: float = 50) -> Entity:
	var e: Entity = g_man.savable_entity.get_set_new()
	#e.ql = default_ql
	e.config_from_scratch(sprite, is_entity, is_constructed, default_material)
	return e

### if it's constructed object construct make it with construct elements
#func create_construct():
	##constructed = true
	##push_error($"maybe construction {entity_num}")
	#var materials_in_object = mp.get_item_object(entity_num).construct_materials
	#if not materials_in_object:
		#return
	#push_error("construction started")
	#damage = -2
	#save_damage()
	##constructed = false
	###save_constructed()
	#reset_container()
	###constructed = true
	#weight = 0
	#volume = 1
	#save_parent_volume_weight()
	#for item in materials_in_object:
		#pass
		#var e = create_from_scratch(item, false, false, false)
		#e.damage = -2
		#e.save_damage()
		#e.weight = 0
		#e.per_ratio = 1
		#e.save_ql_weight()
		#e.add_to_parent(self, true, null)
	#constructed = false
	#save_constructed()

#endregion constructors
#region dead inv
##<summary>deleates the rest if too old inventorys</summary>
#public static void AddDeadInventory(long inv, long idPlayer, long idMob) {
	#var e = Get(inv)
	#e.special = idMob
#
	#NetMan.sin.ListDeadEntities.Add(new MOBDiedData(inv, idPlayer, idMob))
	#while (NetMan.sin.ListDeadEntities.Count > 0){
		#MOBDiedData mData = NetMan.sin.ListDeadEntities[0]
		#//if mob is dead for 120 seconds it's inv is released
		#if(mData.timeOfDeath + 10 < Time.get_unix_time_from_system()){
			#var p = NetMan.sin.SavableServerPerson.Get(mData.idPlayer)
			#p?.gos.netAvatar.netC?.TargetMobLostInventory(p.id_net, mData) 
			#push_error($"count of invs {NetMan.sin.ListDeadEntities.Count}")
			#//destroy dead mob inventory
			#Entity eDeadInv = Get(mData.idDeadInventory)
			#eDeadInv?.destroy_me()
			#MOBData.halfSingleton.NSLMOBsList.Get(mData.idMob).Imob.DamageMOB(100000, mData.idPlayer)
			#MOBData.halfSingleton.NSLMOBsList.RemoveAt(mData.idMob)
			#NetMan.sin.SavableEntity.RemoveAt(mData.idDeadInventory)
			#NetMan.sin.ListDeadEntities.RemoveAt(0)
		#}
		#//if next mob isn't released stop the loop and leave them rest.
		#else{
			#push_error($"count of invs {NetMan.sin.ListDeadEntities.Count}")
			#return
		#}
	#}
	#//*/
#}

#public static void Add(Entity entityWareHouse, float time) {
	#if(entityWareHouse.entity_num == Esprite.ally_warehouse){
		#if (! timeOfChangeWareHouse.ContainsKey(entityWareHouse.id)){
			#timeOfChangeWareHouse.Add(entityWareHouse.id, time)
		#}
		#else{
			#timeOfChangeWareHouse[entityWareHouse.id] = time
		#}
	#}
#}
#endregion dead inv
##region material
#func set_time_heat():
	#for item in e_container:
		#item.set_time_heat()
	#time_heat = Time.get_unix_time_from_system()
#
#func heat_k():
	#var k = Time.get_unix_time_from_system() - time_heat
	#time_heat = Time.get_unix_time_from_system()
	#return k
#
#func add_materials(k_stone: float = 1):
	#var io = mp.get_item_object(entity_num)
	#if entity_num == Enums.Esprite.ore or entity_num == Enums.Esprite.rock:
		#var stone_weight: float = randf_range(weight * k_stone, float(weight))
		#add_material(Enums.material.stone, Enums.metal.metalAndMix, stone_weight)
		#add_material(Enums.material.iron, Enums.metal.metalAndMix, weight - stone_weight)
	#else:
		#var _weight = weight
		#for i in io.type_materials.size():
			#var weight_ratio_materials
			#if io.weight_ratio_materials.size() > i:
				#weight_ratio_materials = io.weight_ratio_materials[i]
			#else:
				#weight_ratio_materials = 1
			#var sub_weight = weight * weight_ratio_materials
			#if _weight < sub_weight:
				#sub_weight = _weight
			#_weight -= sub_weight
			#if sub_weight:
				#add_material(io.type_materials[i], io.type_metal, sub_weight)
			#else:
				#break
### add material weight of the entity
#func add_material(mat: Enums.material, met: Enums.metal, set_weight:float):
	## config
	#var e_mat: EntityMaterial = g_man.savable_multi_entity__material.new_data(id, 0)
	#e_mat.id_entity = id
	#e_mat.weight = set_weight
	#e_mat.type_material = mat
	##//if(e_mat.type_material == EntityMaterial.material.iron)
	##{
	#e_mat.metal = met#//EntityMaterial.Metal.metalAndMix
	##}
	#e_mat.fully_save()
	## add to entity
	#materials.push_back(e_mat)
#
### stream material from 1 entity to another entity
#func stream_material(mat: EntityMaterial):
	## check if material exists already
	#for item: EntityMaterial in materials:
		#if item.type_material == mat.type_material:
			#item.change_weight(mat.weight, false)
			#mat.change_weight(-mat.weight, false)
			##//return
	## stream to another entity
	#if mat.weight > 0:
		#mat.id_entity = id
	#mat.fully_save()
	#materials.push_back(mat)
#
### stream material from mat to me
### from: sub self entity
### mat: subtract
### streamed_weight: how much to stream
#func stream_material_weight(from: Entity, mat: EntityMaterial, streamed_weight: float):
	## we remove weight
	#mat.change_weight(-streamed_weight, false)
	#mat.save_weight()
	#for item in materials:
		#if item.type_material == mat.type_material:
			## we add weight to existing weight
			#var minus_weight = item.change_weight(streamed_weight, false)
			#if minus_weight < 0:
				#streamed_weight += minus_weight
			#item.save_weight()
			#weight += streamed_weight
			#from.weight -= streamed_weight
			## it's only 1 material by 1 material so I can return here
			#return
	## if it doesn't have weight yet we add it
	#weight += streamed_weight
	#from.weight -= streamed_weight
	#push_error("add weight", streamed_weight)
	#var new_em: EntityMaterial = g_man.savable_multi_entity__material.new_data(id, 0)
	#new_em.id_entity = id
	#new_em.weight = streamed_weight
	#new_em.type_material = mat.type_material
	#new_em.metal = mat.metal
	## save on disc
	#new_em.fully_save()
	## add to entity
	#materials.push_back(new_em)
	#pass
#
#func load_materials():
	#var mats = g_man.savable_multi_entity__material.get_all(id, 0)
	#for item:EntityMaterial in mats:
		#if ! materials.has(item):
			#materials.push_back(item)
#
#func burn(temp_current_heat: float, param_air: float, batch):
	#air = param_air
	#var ref = burn_materials(temp_current_heat, param_air, batch)
	#temp_current_heat = ref[0]
	#param_air = ref[1]
	#calc_heat(temp_current_heat)
	#for item:Entity in e_container:
		#ref = item.burn(temp_current_heat, param_air, batch)
		#temp_current_heat = ref[0]
		#param_air = ref[1]
	#if mp.get_item_object(entity_num).is_container and e_container.size() == 0:
		#calc_per_ratio()
		#calc_volume()
		#calc_weight(per_ratio)
		#group_weight = 0
		#group_volume = 0
		#save_group_weight()
		#save_group_volume()
	#return [temp_current_heat, param_air]
#
#func burn_materials(param_current_heat: float, param_air: float, batch):
	#var not_burned_weight: float = 0
	##//var metalChanged = false
	#var p = get_entity(parent)
	## usually inventory or something on top
	#if not p:
		#return [param_current_heat, param_air]
	## material to remove from materials
	#var rem = []
	#var entity_object = mp.get_item_object(entity_num)
	## if material is removed that we don't skip one
	#var mats = materials.duplicate()
	#for item:EntityMaterial in mats:
		## if it's liquid now
		#var ref = item.burn(damage, param_current_heat, param_air, calc_heat_k(heat_k()) )
		#damage += ref[1]
		#param_current_heat = ref[2]
		#param_air = ref[3]
		## if more than 900°C it turns in to the hard clay
		#if entity_object.new_clay_type != Enums.Esprite.undefined and entity_object.entity_type == Enums.entity_type.clay and param_current_heat > 900:
			#entity_num = entity_object.new_clay_type
			#save_entity_num()
		## above liquid border
		#if ref[0]:
			#not_burned_weight += item.weight
			#var material_object = mp.material_container[item.type_material]
			## transforming iron to liquid
			#if entity_num != Enums.Esprite.liquid:
				#if material_object.type_material == Enums.material.iron:
					## self is kinda burned as it's in new material
					#not_burned_weight -= item.weight
					## remove weight of liquid material
					#var liquid = create_from_scratch(Enums.Esprite.liquid, true, false, false)
					#push_error(param_current_heat, " ", current_heat)
					#liquid.current_heat = param_current_heat
					#var liquidMat = item
					#
					#liquid._stream_material(liquidMat, liquidMat.weight)
					## do not calculate from parent because we are calculating it OR we could say we are calculating the burning weight volume
					#liquid._add_to_parent_liquid(p, batch, false)
		#else:
			#not_burned_weight += item.weight
			#if entity_num == Enums.Esprite.liquid:
				#transform_liquid(batch)
			#if not (item.weight <= 0):
				#continue
			#EntityMaterial.destroy_me(item.id_entity, item.id)
			#rem.push_back(item)
	#for r in rem:
		#materials.erase(r)
	#var sub_weight = (weight - not_burned_weight)
	#sub_weight = clampf(sub_weight, 0, weight)
	#weight -= sub_weight
	#if weight <= 0 || damage > 1000:
		#push_error("burn up")
		#destroy_me()
		#batch.remove_only_entity(self)
		#batch.reload_entity(p)
		#return [param_current_heat, param_air]
	#calc_per_ratio()
	#calc_volume()
	#if p:
		#if sub_weight:
			#p.subtract_weight_calc_volume(sub_weight, entity_num)
		#batch.reload_entity(p)
	#save_parent_volume_weight()
	#batch.reload_entity(self)
	#return [param_current_heat, param_air]
#
#func calc_heat(temp_current_heat: float):
	#if current_heat < 20:
		#current_heat = 20
	#current_heat = (current_heat + temp_current_heat) * 0.5
#
#func cool_down(heat: float, batch):
	#heat = clampf(heat, -273, 5000)
	#current_heat = clampf(current_heat, -273, 5000)
	#current_heat *= calc_heat_k(heat_k())
	#calc_heat(heat)
	#for entity in e_container:
		#entity.cool_down(current_heat, batch)
	#transform_liquid(batch)
	#time_heat = Time.get_unix_time_from_system()
#
#func transform_liquid(batch_or_client):
	#if entity_num == Enums.Esprite.liquid or entity_num == Enums.Esprite.ore:
		#for item in materials:
			## if it's lower than liquid border
			#if not item.cool(current_heat):
				#continue
			#push_warning("not liquid any longer: ", id)
			## mold stuff
			#if len(materials) == 1:
				#if materials[0].type_material == Enums.material.iron:
					#entity_num = Enums.Esprite.hard_metal
					#ql = 350
					#calc_per_ratio()
					#calc_volume()
				#if materials[0].type_material == Enums.material.stone:
					#entity_num = Enums.Esprite.rock
					#ql = 350
					#calc_per_ratio()
					#calc_volume()
			## if more materials is iron
			##/*
			##else if (materials[i].type_material == EntityMaterial.material.iron)
			##{
				##//throw new NotImplementedException("z demenzionirat kako narest da isti material gre na isti ga drugačen na drugega")
				##/*foreach (var item in materials)
				##{
					##item.metal = EntityMaterial.Metal.metalAndMix
				##}*
				##entity_num = Esprite.hard_metal
			##}*/
		#if entity_num == Enums.Esprite.hard_metal:
			#var mold_parent: Entity = get_entity(parent)
			#var parent_object = mp.get_item_object(mold_parent.entity_num)
			#if parent_object.new_hard_metal_type != Enums.Esprite.undefined:
				#push_warning(Enums.Esprite.find_key(parent_object.new_hard_metal_type))
				#entity_num = parent_object.new_hard_metal_type
				#calc_per_ratio()
				#calc_volume()
		#save_entity_num()
		#save_ql_weight()
		##if batch_or_client is Batch: #TODO
			##batch_or_client.reload_entity(self)
		##elif batch_or_client is NetworkNode:
			##var ser = Serializable.serialize([self])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(batch_or_client.id_net, ser)
#
#func fireplace_cool_down(ref_current_heat: float, batch):
	#ref_current_heat = clampf(ref_current_heat, -273, 5000)
	#ref_current_heat *= calc_heat_k(heat_k())
	#for item in e_container:
		#item.cool_down(ref_current_heat, batch)
	#transform_liquid(batch)
	#time_heat = Time.get_unix_time_from_system()
	#return ref_current_heat
#
#func non_fireplace_cool_down(param_parent: Entity, client):
	## cooling down
	#param_parent.current_heat = clampf(param_parent.current_heat, -273, 5000)
	#param_parent.current_heat *= calc_heat_k(param_parent.heat_k())
	#cool_down(param_parent.current_heat, client)
	#for item in e_container:
		#item.cool_down(current_heat, null)
	#transform_liquid(client)
	#param_parent.time_heat = Time.get_unix_time_from_system()
#
#func calc_heat_k(time):
	#time = clampf(time, 1, 3600)
	#return 1-(1/(time * SLOW_DOWN_COOL))
#
##endregion material
#region parent

## needs something with damage too
func has_container():
	return mp.get_item_object(entity_num).is_container

## set containerTemp if it's forcibly or it should be containerTemp and even if it's something inside it's deleted


## it's always same as it cannot be null
func reset_container():
	container = []
	e_container = []

func _add_to_container(entity: Entity):
	if container.has(entity.id):
		push_error("it has been already added: ", entity.entity_to_string(), entity_to_string())
		return
	if entity.id == 0:
		push_error("entity is null")
		return
	#var ratio = mp.get_item_object(entity.entity_num)
	#group_volume += ratio * entity.weight
	#group_weight -= entity.weight
	#save_group_volume()
	
	container.push_back(entity.id)
	e_container.push_back(entity)
	entity.parent = id
	entity.save_parent()
	return true

## I'm parent of self entity
## id_child: I'm child
func _remove_from_container(id_child):
	if container.has(id_child):
		var entity = get_entity(id_child)
		if entity:
			entity.parent = 0
			if entity.id == id_child:
				#var ratio = mp.get_item_object(entity.entity_num)
				#group_volume -= ratio * entity.weight
				#group_weight -= entity.weight
				#save_group_volume()
				
				container.erase(id_child)
				e_container.erase(entity)
				entity.save_parent()
			else:
				push_error("entity id: ", entity.id, " and child_id: ", id_child, " aren't same should never come to self")
		else:
			push_error("entity doesn't exist whild in container id does: ", id_child)
	else:
		var entity = get_entity(id_child)
		push_error("self parent doesn't have the id_child: ", id_child, " id: ", id, " child parent is actually: ", entity.parent)

func remove_parent(save: bool = false):
	if parent:
		var parent_entity: Entity = get_entity(parent)
		if parent_entity:
			#change_volume(false, parent_entity)
			#parent_entity.group_volume -= volume
			#parent_entity.parents_change_weight(-weight)#, -volume)
			parent_entity._remove_from_container(id)
			#if len(parent_entity.container) == 0:
				#parent_entity.volume = mp.get_item_object(parent_entity.entity_num).volume_get
				#parent_entity.group_weight = 0
				#parent_entity.group_volume = 0
			#parent_entity.save_parent_volume_weight()
		else:
			push_error("parent is null")
	else:
		push_error("id parent is null")
	#calc_per_ratio()
	#calc_volume()
	#if save:
		#save_parent_volume_weight()

static func get_top_parent(entity):
	if entity:
		if entity.parent == 0:
			return entity
	return get_entity(entity.parent)

## if it's not same or container or compatible or volume is too small
func check_to_parent_intengrity(param_parent: Entity, force: bool = false) -> bool:
	# if same don't add
	if param_parent.id == id:
		push_error("same entity")
		return false
	var parent_io = mp.get_item_object(param_parent.entity_num)
	#if damage == -2:
		#return true
	# if new parent doesn't have container_temp don't add me
	if not parent_io.is_container:
		push_error(Enums.Esprite.find_key(param_parent.entity_num), " is not a container")
		return false
	# if parent isn't compatible don't add
	if not parent_io.is_compatible(entity_num):
		push_error("not compatible: ", Enums.Esprite.find_key(entity_num))
		return false
	## parent volume availability is too small
	#var io = mp.get_item_object(entity_num)
	#if (param_parent.group_volume + volume > param_parent.volume && not force) and not io.is_dividable:# or (not (parent_io.clay_mold_volume_ratio * volume > volume)):
		#push_error(param_parent.entity_to_string(), " parent volume ", param_parent.volume, " is too small")
		#return false
	var self_count = 0
	if param_parent.id == parent or parent == 0:
		self_count += 1
	if parent_io.inventory_quantity != 0 and (param_parent.e_container.size() - self_count) >= parent_io.inventory_quantity:
		if not force:
			push_error("parent has too many items inside: ", param_parent.e_container.size(), " available quantity: ", parent_io.inventory_quantity, " self_count: ", self_count, " id: ", id)
			return false
	## debug
	#if param_parent.group_volume + volume > param_parent.volume:
		#push_warning("too small volume but it's forcibly", entity_to_string())
	## it can be added
	return true

#func add_liquid_to_parent(param_parent: Entity, force: bool, batch, client):
	#push_error(1)
	#if is_new_parents_parent_me(param_parent, id):
		#push_error("wrong parent!!!")
		#return
	#if not check_to_parent_intengrity(param_parent, force):
		#push_error("cannot add to ", Enums.Esprite.find_key(param_parent.entity_num))
		#check_to_parent_intengrity(param_parent, force)
		#return
	#push_error(2)
	#_remove_parent()
	##self.parent = param_parent.id
	##calculate how much liquid it can get in to the parent
	## if liquid stream correct volume for mold
	#var to_object = mp.get_item_object(param_parent.entity_num)
	#if to_object.entity_num == Enums.Esprite.hard_mold_arrow_tip:
		#pass
	#var to_object_ratio = to_object.volume_get / to_object.weight_get
	#var weight_to_stream
	#if to_object.clay_mold_volume_ratio:
		#var parent_available_volume = to_object.clay_mold_volume_ratio * param_parent.volume
		#weight_to_stream = to_object_ratio * parent_available_volume
	#else:
		#weight_to_stream = to_object_ratio * (param_parent.volume - param_parent.group_volume)
	#
	#var divided_entity = divide(false, weight_to_stream)
	#if divided_entity.size() > 0:
		#var new_e = self
		##if divided_entity.size() == 2:
			##new_e = divided_entity[1]
			###.add_to_parent(param_parent, true, client)
			##param_parent._add_to_container(divided_entity[0])
			##if get_entity(divided_entity[0].id) == null:
				##pass
			##if get_entity(new_e.id) == null:
				##pass
		##else:
			##new_e = divided_entity[0]
		##param_parent.group_volume += divided_entity.volume
		##divided_entity.calc_per_ratio()
		##divided_entity.calc_volume()
		##param_parent.parents_change_weight(divided_entity.weight)
		##param_parent.calc_per_ratio()
		### we save changed parent
		##param_parent.save_parent_volume_weight()
		##param_parent.save_group_volume()
		##var liquid = param_parent.e_container.find(Enums.Esprite.liquid)
		#var liquid: Entity
		#for entity_parent in param_parent.e_container:
			#if entity_parent.entity_num == Enums.Esprite.liquid:
				#liquid = entity_parent
				#break
		#if liquid:
			#push_error("check self block if it's same as while")
			##for mat in materials:
				##liquid.stream_material_weight(self, mat, mat.weight)
			#if new_e != liquid:
				#while len(new_e.materials) > 0:
					#liquid.stream_material_weight(new_e, new_e.materials[0], new_e.materials[0].weight)
				## destroy entity
				##if client:
					##destroy_me()
					##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [new_e.id])
				##elif batch != null:
					##batch.remove_only_entity(new_e)
			##NetMan.sin.SavableEntity.set_father(liquid.id, parent.id, true)
			#liquid.calc_per_ratio()
			#liquid.calc_volume()
			#liquid.save_parent_volume_weight()
			#
			## load entity
			##if client: # TODO
				##var serialized_liquid_parent = Serializable.serialize([param_parent, liquid])
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, serialized_liquid_parent)
			##elif batch != null:
				##batch.reload_entity(param_parent)
				##batch.reload_entity(liquid)
			#return liquid
		## add me to new parent
		#new_e.entity_num = Enums.Esprite.liquid
		#param_parent._add_to_container(new_e)
		##NetMan.sin.SavableEntity.set_father(id, parent.id, true)
		#new_e.save_parent_volume_weight()
		#
		## load entity
		##if client: # TODO
			##var ser = Serializable.serialize([new_e])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			###client.gos.netAvatar.netC.target_entities_load(client.id_net, self)
		##else:
			##batch.reload_entity(new_e)
		#return new_e
		##for (var i = 0 i < parent.container.Count i++)
		##{
			##var child = parent.e_container[i]
			##if (child.entity_num != Esprite.liquid) continue
			##while(materials.Count > 0){
				##//stream material from me to child
				##child.add_material(materials[0])
			##}
			##push_error(3)
			##/*if it's liquid it's alone nothing else inside only materials water, iron, ...
				##while(containerTemp.Count > 0){
					##Entity.Get(containerTemp[0]).Add *Liquid* ToParent(child, true)
				##}
				##*/
			##return true
		##}
		##push_error("uncomment: 4")
		##//parent.containerTemp.Add(id)
		##NetMan.sin.SavableEntity.set_father(id, parent.ID, true)
		##save_parent_volume_weight()
		##return true


func compatible_for_movement(to) -> bool:
	if not to:
		push_error("to is null")
		return false
	if to.parent == 0:
		push_error("parent is 0")
		return false
	## construction of entity
	#if not to.constructed:
		#if damage < 0:
			#push_error("materials cannot be entitys")
			#return false
		#if per_ratio < 0.92:
			#push_error("material needs to be full weight")
			#g_man.mold_window.set_instructions_only(["construction error", str("material ", entity_to_string(), " is too small weight: ", str(weight).pad_decimals(2)), str("needs to be at least: ", mp.get_item_object(entity_num).weight_get * 0.92)])
			#return false
		#return true
	# if parent isn't compatible don't add
	if not mp.get_item_object(to.entity_num).is_compatible(entity_num):
		push_error("not compatible: ", Enums.Esprite.find_key(entity_num))
		return false
	## parent volume availability is too small
	#if to.volume < to.group_volume + volume:
		#push_error("too small volume but it's forcibly ", Enums.Esprite.find_key(entity_num))
		#return false
	# it can be added
	return true

#func add_water_to_parent(param_parent: Entity, client):
	## does it have water
	#if param_parent.e_container.size() == 1:
		#var pot_water = param_parent.e_container[0]
		#var pot_obj = mp.get_item_object(pot_water.entity_num)
		## if it has water
		#if pot_obj.entity_type == Enums.entity_type.water:
			#pot_water.stream_entity(self, weight, client, false)
			#var ser = Serializable.serialize([pot_water, param_parent])
			#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			#return
	## if it has everythinbg else inside place all in water
	#if param_parent.e_container.size() != 0:
		## put everything in water
		#var duplicate = param_parent.e_container.duplicate()
		#for d: Entity in duplicate:
			#d.add_to_parent(self, true, client)
	#if param_parent.e_container.size() == 0:
		#var subs = divide(false, 50)
		#if subs.size() > 1:
			#param_parent._add_to_container(subs[1])
			#var ser = Serializable.serialize([subs[1], param_parent])
			#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			#return
		#return
		### now add water to the param_parent





























#region intengrity
func _container_intengrity(_entity: Entity):
	var entity_obj = mp.get_item_object(entity_num)
	if entity_obj.is_container:
		return true

#func _has_enough_volume(_par_obj: EntityObject, ent_obj: EntityObject, entity: Entity) -> bool:
	#if ent_obj.is_dividable:
		#return true
	#var a = _calc_how_much_volume_does_it_have()
	#return a >= entity.volume

func _moving_compatibility(param_parent: Entity):
	var parent_obj: EntityObject = mp.get_item_object(param_parent.entity_num)
	for comp in parent_obj.compatibility:
		if comp == entity_num:
			return true
	var entity_obj = mp.get_item_object(entity_num)
	for comp in entity_obj.i_am_compatible:
		if comp == param_parent.entity_num:
			return true
	if parent_obj.compatibility.size() == 0 and entity_obj.i_am_compatible.size() == 0:
		return true
	# if all fails it's not compatible
	return false
#endregion intengrity
#region calculation
#func _calc_how_much_volume_does_it_have():
	#return volume - group_volume
#
#func _calc_weight_from_new_volume(new_volume):
	#volume = new_volume
	#weight = _return_calc_weight(volume)
	#save_volume()
	#save_weight()

func _calc_and_reparent(entity_new_parent: Entity):
	if parent != entity_new_parent.id:
		var param_parent: Entity = get_entity(parent)
		if param_parent:
			#param_parent.group_volume -= volume
			#param_parent.group_weight -= weight
			param_parent._remove_from_container(id)
		_calc_and_add_to_parent(entity_new_parent)
	
func _calc_and_add_to_parent(param_parent: Entity):
	#param_parent.group_volume += volume
	#param_parent.group_weight += weight
	param_parent._add_to_container(self)
	#param_parent.save_group_volume()
	#param_parent.save_group_weight()

#func _return_calc_weight(_volume):
	#var entity_obj = mp.get_item_object(entity_num)
	#return entity_obj.weight_get * _return_calc_per_ratio(_volume, entity_obj)

#func _return_calc_per_ratio(_volume, entity_obj = null):
	#if not entity_obj:
		#entity_obj = mp.get_item_object(entity_num)
	#return (_volume / entity_obj.volume_get)
#endregion calculation
##region division
## self if no new entity
## else new entity
## they are one is allways headless
#func _get_divided_entity(new_volume: float, calc_from_parent: bool = true) -> Entity:
	#if new_volume == 0:
		#return
	#if volume <= new_volume:
		#if parent != 0:
			#_remove_parent()
			#save_volume()
			#save_weight()
		#return self
	#var entity = _create_from_scratch_with_volume(entity_num, new_volume)
	#_stream_materials(entity, new_volume)
	#if calc_from_parent:
		#_remove_volume_from_parent(null, new_volume)
	#volume -= new_volume
	#_calc_weight_from_new_volume(volume)
	#save_volume()
	#save_weight()
	#entity.save_weight()
	#entity.save_volume()
	#return entity

### self if no new entity
### else self is added to new parent
#func _divide_volume_to_parent(param_parent: Entity, new_volume: float):
	#var divided_entity = _get_divided_entity(new_volume)
	#if divided_entity:
		#divided_entity._calc_and_add_to_parent(param_parent)
		#return divided_entity
##endregion division
##region stream
#func _stream_water_to(entity_to_parent: Entity):
	#if parent == entity_to_parent.id:
		#for e in entity_to_parent.e_container:
			#var e_obj = mp.get_item_object(e.entity_num)
			#if e_obj.entity_type == Enums.entity_type.water and e.id != id:
				#_stream_materials(e, volume)
				#e.volume += volume
				#e._calc_weight_from_new_volume(e.volume)
				#
				#entity_to_parent.group_volume += volume
				#entity_to_parent.group_weight += weight
				#entity_to_parent.save_group_volume()
				#entity_to_parent.save_group_weight()
				#
				#volume -= volume
				#_calc_weight_from_new_volume(volume)
				#save_volume()
				#save_weight()
				#return e
#
### change to entity weight and volume
#func _stream_materials(to_entity: Entity, stream_volume: float):
	#var stream_weight = _return_calc_weight(stream_volume)
	#if materials:
		#var per = stream_weight / weight
		#var c = 0
		#var count = materials.size()
		#for i in count:
			#var weight_per = materials[i - c].weight * per
			#weight -= weight_per
			#if not to_entity._stream_material(materials[i - c], materials[i - c].weight * per):
				#c += 1
	#if materials.size() == 0:
		##var to_parent = get_entity(to_entity.parent)
		##to_parent.group_volume += stream_volume
		##if weight != 0:
			##stream_weight = weight
		##to_parent.group_weight += stream_weight
		#destroy_me(true)
#
### you need to change weight of entity your self
#func _stream_material(material: EntityMaterial, weight_material: float):
	#var got_it = false
	#for mat in materials:
		#if mat.type_material == material.type_material:
			#mat.change_weight(weight_material, false)
			#got_it = true
			#break
	#if not got_it:
		#add_material(material.type_material, material.metal, weight_material)
	#material.change_weight(-weight_material, false)
	#
	#if material.weight <= 0:
		#return false
	#return true
#
#
##endregion stream
#region removing
#func _remove_volume_from_parent(param_parent = null, sub_volume: float = 0):
	#if param_parent == null:
		#param_parent = get_entity(parent)
	#if param_parent != null:
		#param_parent.group_volume -= sub_volume
		#param_parent.group_weight -= _return_calc_weight(sub_volume)
		#param_parent.save_group_volume()
		#param_parent.save_group_weight()

func _remove_parent(save: bool = false):
	var param_parent: Entity = get_entity(parent)
	#_remove_volume_from_parent(param_parent, volume)
	if param_parent != null:
		param_parent.e_container.erase(self)
		param_parent.container.erase(id)
		#if param_parent.e_container.size() == 0:
			#param_parent.group_volume = 0
			#param_parent.group_weight = 0
		#param_parent.save_group_volume()
		#param_parent.save_group_weight()
	parent = 0
	if save:
		save_parent()
## child loweres weight and it affects my weight and group volume
#func subtract_weight_calc_volume(sub_weight: float, sub_entity_num: Enums.Esprite):
	#group_weight -= sub_weight
	#var item_obj = mp.get_item_object(sub_entity_num)
	## get ratio and from it get sub volume
	#var sub_volume = (item_obj.volume_get / item_obj.weight_get) * sub_weight
	#group_volume -= sub_volume
	#save_parent_volume_weight()
	#save_group_volume()
	#save_group_weight()
#
#func _digest(client):
	#var energy = 0
	#var digested_weight = 0
	#for material in materials:
		#var weight_energy = material.digest(current_heat)
		#if weight_energy and weight_energy[0]:
			#digested_weight += weight_energy[0]
			#energy += weight_energy[0] * weight_energy[1]
	## update food if it was digested
	#if energy != 0:
		#digested_weight = clampf(digested_weight, 0, weight)
		#weight -= digested_weight
	## if food eaten whole destroy it
	#if weight <= 0 || damage > 1000:
		#print("eaten")
		#destroy_me()
		#g_man.local_server_network_node.net_dp_node.target_entitis_destroy([id])
	#calc_per_ratio()
	#calc_volume()
	## calc parent the weight
	#var p = get_entity(parent)
	#if p:
		#p.subtract_weight_calc_volume(digested_weight, entity_num)
	##var ser = Serializable.serialize([self, p]) # TODO
	##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	#return energy
##endregion removing
##region cut
func cut_me(param_parent: Entity, client, force = false):
	var before_parent = get_entity(parent)
	var parent_obj = mp.get_item_object(param_parent.entity_num)
	var entity_obj = mp.get_item_object(entity_num)
	
	var serialize_entities = [before_parent, param_parent, self]
	
	if force or param_parent._container_intengrity(self):
		#if param_parent._has_enough_volume(parent_obj, entity_obj, self):
			#var new_volume = param_parent._calc_how_much_volume_does_it_have()
			#if new_volume == 0:
				#return
			# if it has divided correctly it's all done
			#var cut = _divide_volume_to_parent(param_parent, new_volume)
			#if cut != null:
				#serialize_entities.push_back(cut)
			#if entity_obj.entity_type == Enums.entity_type.water:
				#var e = cut._stream_water_to(param_parent)
				#if e != null:
					# ser different entity
					#serialize_entities.push_back(e)
				#if param_parent.e_container.size() > 1:
					#var temp = param_parent.e_container.duplicate()
					#for t in temp:
						#if t.id != cut.id:
							#t._calc_and_reparent(cut)
		#elif force: # TODO 	tab next line
		_calc_and_add_to_parent(param_parent)
		#var ser = Serializable.serialize(serialize_entities) # TODO
		#if client:
			#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
		#return serialize_entities[serialize_entities.size() - 1]
		return self

#func _add_to_parent_liquid(param_parent: Entity, client_batch, calc_from_parent = true):
	#if entity_num == Enums.Esprite.liquid:
		#var liquid = get_entity_with_enum(param_parent, Enums.Esprite.liquid)
		#if liquid:
			#var divided_e = _get_divided_entity(volume, calc_from_parent)
			#divided_e._stream_materials(liquid, divided_e.volume)
			##var ser = [param_parent, liquid] # TODO
			##if divided_e.entity_num != 0:
				##ser.push_back(divided_e)
			##elif client_batch is NetworkNode:
				##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client_batch.id_net, [divided_e.id])
			##elif client_batch is Batch:
				##client_batch.remove_only_entity(divided_e)
			##if client_batch is NetworkNode:
				##ser = Serializable.serialize(ser)
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client_batch.id_net, ser)
			##elif client_batch is Batch:
				##for e in ser:
					##client_batch.reload_entity(e)
			#return true
		#
		#var divided_p = _divide_volume_to_parent(param_parent, volume)
		##if client_batch is NetworkNode: # TODO
			##var ser = Serializable.serialize([param_parent, divided_p])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client_batch.id_net, ser)
		##elif client_batch is Batch:
			##client_batch.reload_entity(param_parent)
			##client_batch.reload_entity(divided_p)
		#return true
	#return false

##endregion cut
#region outer functions
#func digest(client):
	#var energy = 0
	#for entity in e_container:
		#energy += entity.digest(client)
	#energy += _digest(client)
	#return energy
## self entity to new parent
## returns: true if it succeed
func add_to_parent(param_parent: Entity, force: bool, client):
	if not _moving_compatibility(param_parent):
		g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, [str("you cannot move: ", to_string_name()), str(" to: ", param_parent.to_string_name())])
		return
	#var to_ser = [] # TODO
	#if client:
		#to_ser.push_back(client.client.playing_avatar.experiences.add_exp_to(Enums.exp.support))
		#var parent_obj = mp.get_item_object(param_parent.entity_num)
		#if parent_obj.experience_move != Enums.exp.nul:
			#to_ser.push_back(client.client.playing_avatar.experiences.add_exp_to(parent_obj.experience_move))
		#var ser = Serializable.serialize(to_ser)
		#g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser)
	
	#non_fireplace_cool_down(param_parent, client)
	var entity_obj = mp.get_item_object(entity_num)
	#region locking mechanism
	# parent's container
	if parent:
		var _parent = get_entity(parent)
		# inside locked container can't take it out
		if _parent.load_return_locked():
			return
	var lockeds = [param_parent.load_return_locked()]
	# if it's locked don't put anything in ("for" to bypass return)
	for locked in lockeds:
		# if it's key maybe lock or unlock
		if entity_obj.is_key:
			var id_key = load_return_key_id()
			var id_lock = param_parent.load_return_key_id()
			# if they match lock or unlock
			if id_key == id_lock:
				param_parent.save_locked(not locked)
				#if locked: # TODO
					#var ser = Serializable.serialize([param_parent])
					#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			# if they don't match put key inside the container (bypass return)
			else:
				break
		# never leave anything in if it's locked
		if locked:
			return
	#endregion locking mechanism
	#if _add_to_parent_liquid(param_parent, client):
		#return
	##region construction
	#if not param_parent.constructed:
		#force = true
		#var index = Constructed(param_parent, client)
		#if index == 0:
			#return false
		#elif index == 1:
			#destroy_me()
			#return true
		#elif index == 2:
			#destroy_me()
			## finishing construction
			#param_parent.damage = 0
			#param_parent.constructed = true
			#param_parent.save_damage()
			#param_parent.save_constructed()
			#param_parent.calc_per_ratio()
			#param_parent.calc_volume()
			## save volume that was calculated
			#param_parent.save_volume()
			#return true
	##endregion construction
	## cut 1
	#if entity_obj.entity_type == Enums.entity_type.water:
		#return cut_me(param_parent, client, force)
	#
	#if param_parent.e_container.size() == 1:
		#entity_obj = mp.get_item_object(param_parent.e_container[0].entity_num)
		#if entity_obj.entity_type == Enums.entity_type.water:
			#return cut_me(param_parent.e_container[0], client, force)
			
	return cut_me(param_parent, client, force)
#endregion outer functions
#func add_to_marketplace(entity: Entity, min_amount: int, max_amount: int, max_time: int, _id_avatar):
	#var avatars = g_man.savable_multi_client__avatar.get_all(0, _id_avatar)
	#if avatars:
		#entity.remove_parent(true)
		#_add_to_container(entity)
		#set_indexes(entity)
		#entity.save_article_cost(min_amount, max_amount)
		#entity.save_article_avatar(_id_avatar)
		#entity.save_time_auction(max_time)
#
#
#func add_bidder(_id_avatar, bid, _cost):
	#if switch_bidder(_id_avatar, bid, _cost[0]):
		#save_bidder(_id_avatar)
		#save_article_cost(bid, _cost[1])
#
#func switch_bidder(_id_avatar, bid, min_cost):
	#var id_before_bidder = load_return_bidder()
	#if id_before_bidder:
		#var before_bidder = g_man.savable_multi_client__avatar.get_all(0, id_before_bidder)
		#if before_bidder:
			#printerr("before bidder")
			#before_bidder = before_bidder[0]
			#before_bidder.gold_coins += min_cost
			#before_bidder.save_gold_coins()
			#g_man.local_server_network_node.net_dp_node.target_update_avatar_gold_coins.rpc_id(before_bidder.id_unique, before_bidder.gold_coins)
	#var bidder = g_man.savable_multi_client__avatar.get_all(0, _id_avatar)
	#if bidder:
		#bidder = bidder[0]
		#bidder.gold_coins -= bid
		#bidder.save_gold_coins()
		#g_man.local_server_network_node.net_dp_node.target_update_avatar_gold_coins.rpc_id(bidder.id_unique, bidder.gold_coins)
		#return true































### self entity to new parent
### returns: true if it succeed
#func _X_add_to_parent(param_parent: Entity, force: bool, client):
	## it should be his parent current heat but somewhere it ends
	#param_parent.cool_down(current_heat, null)
	#if entity_num == Enums.Esprite.liquid:
		#var before_parent = Entity.get_entity(parent)
		#var b = add_liquid_to_parent(param_parent, false, null, client)
		#if b:
			##if b.size() == 2:
				##b[0].add_to_parent(before_parent, true, null, client)
			#return true
		#else:
			#return false
	#var entity_obj = mp.get_item_object(entity_num)
	### get water in this container #####TODO#####if it can be in it
	#if entity_obj.entity_type == Enums.entity_type.water:
		#add_water_to_parent(param_parent, client)
		#return
	#non_fireplace_cool_down(param_parent, client)
	## construction of entity
	#
	##region construction
	#if not param_parent.constructed:
		#force = true
		#var index = Constructed(param_parent, client)
		#if index == 0:
			#return false
		#elif index == 1:
			#destroy_me()
			#return true
		#elif index == 2:
			## finishing construction
			#param_parent.constructed = true
			#param_parent.damage = 0
			#param_parent.save_constructed()
			#param_parent.calc_per_ratio()
			##create_and_put_in(param_parent, client)
			#return true
	##endregion
	#push_error("added")
	#if(entity_num == Enums.Esprite.bullet):
		#entity_num = mp.get_item_object(param_parent.entity_num).get_new_bullet_type(entity_num)
		#save_entity_num()
		#set_volume_weight(entity_num)
		#save_parent_volume_weight()
	## if parent is going in to child don't add WARNING
	#if is_new_parents_parent_me(param_parent, id):
		#push_error("wrong parent!!!")
		#return false
	#if not check_to_parent_intengrity(param_parent, force):
		#push_error("cannot add to ",Enums.Esprite.find_key(param_parent.entity_num))
		#return false
	## remove from parent
	#var parentBefore: Entity = null
	#if parent:
		#parentBefore = get_entity(parent)
	## if parent is being constructed
	#if parentBefore:
		#if parentBefore.damage < 0:
			#if damage < 0:
				#push_error("parent is a constructor not full entity yet you cannot take it's materials out")
				#return false
			#var material: Entity = create_from_scratch(entity_num, false, false, false)
			#material.damage = -2
			#material.save_damage()
			#material.weight = 0
			#material.per_ratio = 1
			#material.save_ql_weight()
			#parentBefore.constructed = true
			#material.add_to_parent(parentBefore, true, client)
			#parentBefore.constructed = false
	## if universal box we remove it
	#remove_parent()
	## if uni box is empty destroy it
	#if parentBefore and parentBefore.entity_num == Enums.Esprite.entity_visual_universal:
		#if len(parentBefore.container) == 0:
			#if not parentBefore.body:
				#push_error(parentBefore.entity_to_string(), " body is null!!!")
			#else:
				##position = Vector3.one
				#parentBefore.destroy_me()
				##// parentBefore.body.GetComponent<IEntityVisual>().batchEntitysServer.DestroyBody(parentBefore)
	## we configure our new parent
	#push_error("check if it works correctly")
	#if not param_parent._add_to_container(self):
		#return false
	##NetMan.sin.SavableEntity.set_father(id, param_parent.ID, true)
	##change_volume(true, param_parent)
	#param_parent.group_volume += volume
	#calc_per_ratio()
	#calc_volume()
	#param_parent.parents_change_weight(weight)
	#param_parent.calc_per_ratio()
	## we save changed parent
	#param_parent.save_volume_weight()
	#param_parent.save_group_volume()
	##save_volume_weight()
	#if param_parent.constructed:
		#if client:
			#var ser = Serializable.serialize([self, param_parent])
			#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			#push_error("parent is constructed", param_parent.to_string_name())
		#return true
	#push_error("parent isn't constructed")
	##finishing the construction
	## checking if construction is really finished
	#for item in param_parent.e_container:
		#if item.damage < 0:
			#push_error("return")
			#return true
	## finishing the construction
	#push_error("finishing the construction")
	#param_parent.constructed = true
	#param_parent.save_constructed()
	## we save total weight before we remove all entities
	#var parent_parent = get_entity(param_parent.parent)
	#if parent_parent:
		#parent_parent.group_weight += param_parent.weight
		#parent_parent.group_volume += volume
	## add to the construction and destroy the material
	#var count = len(param_parent.e_container)
	#for e in count:
		#var entity: Entity = get_entity(param_parent.container[0])
		## the least ql is the ql that represents the constructed entity
		#if entity.ql < param_parent.ql:
			#param_parent.ql = entity.ql
			#push_error(param_parent)
		#if client:
			#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [entity.id])
		## we add all materials from before entity to the parent
		#while len(entity.materials) > 0:
			#push_error("add to parent the material!!! is weight lost when reloaded?")
			#param_parent.stream_material(entity.materials[0])
		#entity.destroy_me()
	#push_error("added all materials")
	#param_parent.damage = 0
	#param_parent.calc_per_ratio()
##
	#if param_parent.ql < min_ql:
		## destroy constructed entity
		#if mp.get_item_object(entity_num).scrap_type == Enums.Esprite.undefined:
			#push_error("destroy")
			#if client:
				#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [param_parent.id])
			#param_parent.destroy_me()
		##make scrap from constructed entity
		#else:
			#var t_parent = Entity.get_entity(parent)
			#var scrap: Entity = param_parent.make_scrap(t_parent, weight, client)
			#if client and scrap:
				#var serialize_scrap_parent = Serializable.serialize([Entity.get_entity(scrap.parent), scrap])
				#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, serialize_scrap_parent)
			#else:
				#push_error("scrap: ", scrap.entity_to_string())
		#return false
	##var item = mp.get_item_object(entity_num)
	## we set real containerTemp
	#param_parent.reset_container()
#
	#param_parent.fully_save()
	## world space
	#if not client:
		#push_error("Warning client is null")
	#create_and_put_in(param_parent, client)
	#return true

### parent: who is going to be constructed
### returns: 0 failed top add 1 added 2 constructed
#func Constructed(param_parent: Entity, client = null):
	#if damage < 0:
		#push_error("entities cannot be materials")
		#return 0
	#per_ratio = _return_calc_per_ratio(volume)
	#if per_ratio < MIN_WEIGHT_PERCENT:
		#push_error("material needs to be full weight")
		#if client:
			#g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["construction error" , str("material ", entity_to_string(), " is too small weight: ", str(weight).pad_decimals(2)), str("needs to be at least: ", str(mp.get_item_object(entity_num).weight_get * MIN_WEIGHT_PERCENT).pad_decimals(2)), str("per ratio: ", str(per_ratio).pad_decimals(2), " min: ", MIN_WEIGHT_PERCENT)])
			#return 0
	#if per_ratio > MAX_WEIGHT_PERCENT:
		#push_error("too big: ", MAX_WEIGHT_PERCENT * (mp.get_item_object(entity_num).weight_get))
		#var t_parent = Entity.get_entity(parent)
		#var weight_one = divide(false, mp.get_item_object(entity_num).weight_get)
		#var add_entity
		#if weight_one.size() == 1:
			#add_entity = weight_one[0]
		#if weight_one.size() == 2:
			#add_entity = weight_one[1]
			#weight_one[0].add_to_parent(t_parent, true, client)
		#add_entity.calc_per_ratio()
		#if add_entity.per_ratio == 1:
			#if add_entity.add_to_parent(param_parent, true, client):
				##if client: #TODO
					##push_error("client loading: ", entity_to_string(), ", ", add_entity.entity_to_string())
					##var serialized = Serializable.serialize([param_parent, add_entity, self])
					##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, serialized)
				#return 1
			#push_error("should never come to self!!")
			##if client: # TODO
				##var ser = Serializable.serialize([param_parent, self])
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
			#return 0
		## too large && can't be divided
		#elif per_ratio > MAX_WEIGHT_PERCENT:
			#if client:
				#g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["construction error", str("material ", entity_to_string(), " is too large weight: ", str(weight).pad_decimals(2)), str(" needs to be max: ", str(mp.get_item_object(entity_num).weight_get * MAX_WEIGHT_PERCENT).pad_decimals(2)), str("per_ratio: ", str(per_ratio).pad_decimals(2), " max: ", MAX_WEIGHT_PERCENT)])
			#return 0
	#push_error("construction of ", param_parent.to_string_name())
	#var added = false
	#for entity in param_parent.e_container:
		#if entity.damage < 0:
			## if material is correct
			#if entity.entity_num == entity_num:
				#var k = 1
				##if client: # TODO
					##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [entity.id])
					##var a: Avatar = client.client.playing_avatar
					##if a and a.experiences:
						##var exp_construct: Experience = a.experiences.get_exp(Enums.exp.construct)
						##k += exp_construct.experience_master_level * _K_EXP
						##exp_construct.add(1)
						##var ser_exp = Serializable.serialize([exp_construct])
						##g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser_exp)
				#param_parent.stream_entity(self, weight, client, true, k)
				##//param_parent.weight += entity.weight
				##//param_parent.save_ql_weight()
				##//destroy -2 damage plan material
				##var ser = Serializable.serialize([param_parent]) # TODO
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
				#entity.destroy_me()
				#push_warning(param_parent.to_string_name(), " ", param_parent.weight)
				#added = true
				#push_warning("entity ", to_string_name(), " destroyed")
				#break
			#push_error(param_parent.entity_to_string())
	#if not added:
		#push_error("failed to add")
		#return 0
	#if param_parent.e_container:
		#return 1
	#return 2

func give_all_my_children_and_destroy_me(_parent: Entity, force: bool):
	var i = 0
	while e_container:
		i += 1
		if i > 500:
			return false
		var child: Entity = e_container[0]
		if pos == Vector3.ZERO:
			return false
		if not child.add_to_parent(_parent, force, null):
			return false
	destroy_me()
	return true

## check if parent is going in to child
## parent: parent line to check
## id_self: id to check
func is_new_parents_parent_me(param_parent: Entity, id_self):
	if not param_parent:
		return false
	if param_parent.parent == 0:
		return false
	elif param_parent.parent == id_self:
		return true
	var pp = g_man.savable_entity.get_index_data(param_parent.parent)
	if not pp:
		push_error(param_parent.parent, " does not exist")
		return true
	return is_new_parents_parent_me(pp, id_self)

#func parents_change_weight(param_weight):#, param_volume):
	#if parent:
		#var parent_entity: Entity = get_entity(parent)
		#parent_entity.parents_change_weight(param_weight)#, param_volume)
		#push_error(parent_entity.to_string_name(), " // ", parent_entity.weight, " set volume weight ?!?")
		##// set_volume_weight(entity_num)
		##//self entity and self id
	#group_weight += param_weight
	##group_volume += param_volume
	#save_parent_volume_weight()

#endregion parent
#region main
## IF it's in world space && IF total parent has a body which should allways have
## entity: looses parent and is made as a master parent and get's body</param>
## client: client rotation
static func create_and_put_in(entity: Entity, client, global_position: Vector3 = Vector3.ZERO):
	if not entity.body:
		var item_object = mp.get_item_object(entity.entity_num)
		# for tree sprout
		if item_object.entity_type == Enums.entity_type.tree_sprout:
			# I change it here
			push_warning("in planting entity: ", entity.entity_to_string())
			#entity._transform(item_object.new_tree_type)
			var world_entity = create_push_me_in_world(entity, client, global_position)
			world_entity.server = true
			# make head of plan the plan_entity
			var _plan_entity = create_head_plan(world_entity)
			
			world_entity.time_of_plant = Time.get_unix_time_from_system()
			entity.save_time_of_plant(world_entity.time_of_plant)
			entity.save_entity_type(Enums.entity_type.tree_sprout)
			# calc max_ql
			var sowing_level = client.client.playing_avatar.experiences.get_exp_level(Enums.exp.sowing)
			var max_ql = randf_range(sowing_level, 1000)
			entity.ql = randf_range(500, max_ql)
		# for plan entity
		elif item_object.in_world_space:
			push_warning("in world space: ", entity.entity_to_string())
			var world_entity = create_drop_me_in_world(entity, client)
			world_entity.server = true
			# make head of plan the plan_entity
			create_head_plan(world_entity)
			
			world_entity.time_of_plant = Time.get_unix_time_from_system()
			entity.save_time_of_plant(world_entity.time_of_plant)
			
		#else if(item_object.house){
			#push_error($"{entity.entity_num} {item_object.fullyConstructed}")
			#IHouse ihouse = entity.body.GetComponentInParent<IHouse>()
			#ihouse.ChangeVisuals(item_object.fullyConstructed)
			#ihouse.FullyBuild()

static func load_and_put_in(entity: Entity, global_position: Vector3):
	if not entity.body:
		var item_object = mp.get_item_object(entity.entity_num)
		# for tree sprout
		if item_object.entity_type == Enums.entity_type.tree_sprout or item_object.entity_type == Enums.entity_type.tree_stump or item_object.entity_type == Enums.entity_type.tree_cut:
			# I change it here
			push_warning("in planting entity: ", entity.entity_to_string())
			#entity._transform(item_object.new_tree_type)
			var world_entity = load_push_me_in_world(entity, global_position)
			world_entity.server = true
			# make head of plan the plan_entity
			create_head_plan(world_entity)
			world_entity.time_of_plant = entity.load_return_time_of_plant()
			entity.save_entity_type(item_object.entity_type)
		# for plan entity
		elif item_object.in_world_space:
			push_warning("in world space: ", entity.entity_to_string())
			var world_entity = load_drop_me_in_world(entity)
			world_entity.server = true
			# make head of plan the plan_entity
			create_head_plan(world_entity)
			#if world_entity is IWorldContainer: # TODO
				#world_entity.inventory = entity
		##else if(item_object.house){
			##push_error($"{entity.entity_num} {item_object.fullyConstructed}")
			##IHouse ihouse = entity.body.GetComponentInParent<IHouse>()
			##ihouse.ChangeVisuals(item_object.fullyConstructed)
			##ihouse.FullyBuild()

## for transforming from plant in to growing tree for example weight, volume, stays same
func _transform(to_entity_num):
	remove_parent()
	entity_num = to_entity_num
	#calc_per_ratio()
	save_entity_num()

static func create_default_visual(entity: Entity):
	var total_parent: Entity = get_top_parent(entity)
	#var world_entity: IVisual: TODO
	#var entity_object = mp.get_item_object(entity.entity_num)
	#if entity_object.default_visual_entity == Enums.Esprite.undefined:
		#world_entity = mp.create_me(entity.entity_num)
	#else:
		## usually farm
		#world_entity = mp.create_me(entity_object.default_visual_entity)
		## usually vegetable like pumpkin
		#world_entity.entity_num_body_visuals = entity_object.harvest_type
	#entity.body = world_entity
	return total_parent

static func create_drop_me_in_world(entity: Entity, _client = null):
	var total_parent: Entity = create_default_visual(entity)
	g_man.dp.set_body_pos_rot_from_ray_to_server_planet(total_parent.body, entity.body)
	return config_me_in_world(entity)
	
static func load_drop_me_in_world(entity: Entity):
	var total_parent: Entity = create_default_visual(entity)
	total_parent.body.global_position = entity.pos
	g_man.dp.set_rot_from_body_to_server_planet(total_parent.body, entity.body)
	return config_me_in_world(entity)

static func create_push_me_in_world(entity: Entity, _client = null, global_position: Vector3 = Vector3.ZERO):
	var world_entity = mp.create_me(entity.entity_num)
	entity.body = world_entity
	world_entity.global_position = global_position
	g_man.dp.set_body_pos_rot_from_ray_to_server_planet(world_entity, entity.body)
	return config_me_in_world(entity)

static func load_push_me_in_world(entity: Entity, global_position: Vector3):
	var world_entity = mp.create_me(entity.entity_num)
	entity.body = world_entity
	world_entity.global_position = global_position
	g_man.dp.set_rot_from_body_to_server_planet(world_entity, entity.body)
	return config_me_in_world(entity)

static func config_me_in_world(entity: Entity):
	var world_entity = entity.body
	world_entity.id = entity.id
	world_entity.entity_num = entity.entity_num
	world_entity.entity_string = entity.to_string_name()
	world_entity.time_of_plant = entity.load_return_time_of_plant()
	world_entity.special = entity.special
	
	entity.pos = entity.body.global_position
	entity.rot = entity.body.global_rotation
	
	entity.remove_parent(true)
	entity.save_position_rotation()
	# save set ed special
	entity.save_special()
	push_warning(entity.special)
	return world_entity

static func create_head_plan(world_entity):
	var plan_entity = mp.create_me(Enums.Esprite.plan_entity)
	plan_entity.global_position = world_entity.global_position
	plan_entity.quaternion = world_entity.quaternion
	world_entity.reparent(plan_entity)
	return plan_entity

static func get_entity(id_entity):
	if id_entity:
		return g_man.savable_entity.get_index_data(id_entity)
	push_warning("someone wants entity 0 ", id_entity)

func destroy():
	parent = 0
	save_parent()
	pos = Vector2.ZERO
	save_position_rotation()
	entity_num = Enums.Esprite.nul
	save_entity_num()
	container.clear()
	e_container.clear()
	#destroy_me(false, false)
## we destroy all any containers inside and remove reference and save the entity to 0 ql
func destroy_me(remove_parent_weight_less = false, remove_from_savable: bool = true):
	push_warning("destroy ", entity_to_string())
	printerr("Entity destroy")
	# we remove all containerTemp inside any containers entities
	for e in e_container:
		e.destroy_me()
	
	container.clear()
	e_container.clear()
	var entity_parent
	if parent:
		entity_parent = get_entity(parent)
		if remove_parent_weight_less:
			entity_parent._remove_from_container(id)
		else:
			remove_parent()
		
		# destroy universal body on all clients
		if entity_parent and entity_parent.entity_num == Enums.Esprite.entity_visual_universal:
			if entity_parent.container.size() == 0:
				#entity_parent.EntityVisual?.batchEntitysServer?.DestroyBody(entity_parent)
				entity_parent.destroy_me()
	# destroy self body on all clients
	# EntityVisual?.batchEntitysServer?.DestroyBody(self)
	if body:
		body.destroy_me()

	# we pool back the body
	visual(false)
	pos = Vector2.ZERO
#
	# we save entity to nothing
	#ql = 0
	entity_num = Enums.Esprite.nul
	## we clear harvest history
	#DataBase.insert(_server, g_man.dbms, _path, "harvested", id, 0)
	# we delete reference
	if remove_from_savable:
		g_man.savable_entity.remove_at(id)
	#EntityMaterial.destroy_me(id, 0)
	#materials.clear()

func destroy_body():
	if body:
		if body.batch:
			body.batch.remove_only_body(body)
		g_man.dp.destroy_node(body)
		body = null
	pos = Vector3.ZERO
	save_position_rotation()
#endregion main
#region cost
## general cost ql excluded
## avatar_money: more avatar money bigger cost
static func cost(buy: bool, article: Enums.Esprite, avatar_money: float, trader_money: float):
	var total_money = avatar_money + trader_money
	if not total_money:
		total_money = 1
	var k = avatar_money / total_money
	var article_cost = mp.get_item_object(article).cost
	if buy:
		return int(cost_buy(k, article_cost))
	return int(cost_sell(k, article_cost))

##<summary>more and at least 1</summary>
static func cost_buy(k: float, article_cost: float):
	article_cost = (k * _K_COST + 0.2) * article_cost
	if article_cost == 0:
		return 1
	return article_cost
##<summary>less and minimum 0</summary>
static func cost_sell(k: float, article_cost: float):
	return (k * _K_COST + 0.15) * article_cost

static func cost_simulate(buy: bool, avatar_money: float, trader_money: float, param_entity_num: Enums.Esprite):#, param_ql: float, param_per_ratio: float):
	var article_cost = (cost(buy, param_entity_num, avatar_money, trader_money))# * (param_ql / 1000) * param_per_ratio)
	if article_cost < 1:
		push_error(" article_cost: ", str(article_cost).pad_decimals(1), ": ", Enums.Esprite.find_key(param_entity_num))#, " per_ratio: ", str(param_per_ratio).pad_decimals(2), " calced ql: ", str(param_ql/1000).pad_decimals(1), " ", Enums.Esprite.find_key(param_entity_num))

	if buy && article_cost < 1:
		article_cost = 1
	if article_cost < 0:
		article_cost = 0
	return int(article_cost)

## item's quality percent of trade
## avatar_money: more avatar money bigger cost
func this_entity_cost(buy: bool, avatar_money: float, trader_money: float):
	return cost_simulate(buy, avatar_money, trader_money, entity_num)#, ql, per_ratio)
#endregion cost
#region visual

## remove / create body
func visual(on: bool):
	if on && not body:
		body = mp.create_me(entity_num)
	elif not on && body:
		if entity_num != Enums.Esprite.entity_visual_universal and entity_num != Enums.Esprite.nul:
			push_error(entity_to_string())
			g_man.dp.destroy_node(body)
			body = null
		else:
			body.queue_free()
			body = null

#endregion visual
#region improving
## bigger it is harder it is
static func hard(tool, work_piece, result: Enums.Esprite, reverse_ql: bool):
	var item_hard
	if result == Enums.Esprite.undefined:
		item_hard = mp.get_item_object(work_piece.entity_num).hard
		return (item_hard * (work_piece.ql + work_piece.damage)) / (tool.ql - tool.damage)
	item_hard = mp.get_item_object(result).hard
	
	var ratio: float
	ratio = work_piece._return_calc_per_ratio(work_piece.volume)
	var wp_ql
	# bigger ql it is easyer it is
	# used for creating
	if reverse_ql:
		wp_ql = clampf((1000 - work_piece.ql), 1, 1000)
		# else it's too hard and too easy imp
		item_hard *= 0.2
	# bigger ql it is harder it is
	# used for imp repair
	else:
		wp_ql = work_piece.ql
	var wp = clampf(wp_ql * clampf(work_piece.damage * 0.01, 1, 1000), 1, 100000)
	var tool_ql = tool.ql
	# hands are workpiece ql
	if tool_ql == 1000:
		tool_ql = wp_ql
	var tol = clampf(tool_ql * ((1000 - tool.damage) / 1000), 25, 100000)
	return (((item_hard * _K_HARD) * wp) / tol) / ratio

## bigger it is harder it is
static func _success(how_hard: float, experience: float):
	how_hard = how_hard * clampf((1-(experience * 0.001)), 0.0001, 1)
	return how_hard

static func success_per(tool, workpiece, result: Enums.Esprite, experience: float, reverse_ql: bool):
	var how_hard: float = hard(tool, workpiece, result, reverse_ql)
	how_hard = _success(how_hard, experience)
	#experience += parent_exp
	#if how_hard < 1:
		#how_hard = 1
	#how_hard = experience / how_hard * 100
	how_hard = 1 - how_hard
	return clampf(how_hard, 0, 1)

func random_success(k):
	var rnd = randf_range(0, 1)
	k = k - rnd
	return k

#func damage_tool(k: float, client):
	#var tool_obj = mp.get_item_object(entity_num)
	#if tool_obj.is_top_inventory:
		#return self
	#if k < 0:
		#k = -k
	#var additional_damage = k * _K_DAMAGE# * clampf(1000 - ql, 0.1, 1000)
	#damage += additional_damage
	##if tool_obj.is_sharpable:
		##save_sharpening_damage(additional_damage, 0)
	#save_damage()
	#if damage > 1000:
		#var t_parent = get_entity(parent)
		##var scrap = make_scrap(t_parent, weight, client)
		##if not scrap:
			##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
			##destroy_body()
		#destroy_me()
			##return
		##var ser = Serializable.serialize([get_entity(parent), self]) # TODO
		##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
		#return
	##g_man.local_server_network_node.net_dp_node.target_load_id_entity_damage_ql_weight.rpc_id(client.id_net, id, damage, ql, weight)
	#return self

##slice a little bit and improve the workpiece
#func improve(tool: Entity, client):
	#imp_repair(tool, client, true)
#
#func check_imp_repair(tool: Entity):
	#if not tool:
		#return false
	#var item = mp.get_item_object(entity_num)
	#if not item.is_improvable:
		#push_error(to_string_name(), " it's not repairable improvable")
		#return false
	## if it's not compatible tool
	#if imp_tool != Enums.Esprite.undefined:
		#if imp_tool != tool.entity_num:
			#return false
	#return true
#
###slice a little bit and repair the workpiece
#func repair(tool: Entity, client):
	#if damage > 0:
		#imp_repair(tool, client, false)
#
#func imp_repair(tool: Entity, client, imp: bool):
	#var item = mp.get_item_object(entity_num)
	#if not item.is_improvable and not item.is_sharpable:
		#g_man.local_server_network_node.net_dp_node.target_load_id_entity_imptool.rpc_id(client.id_net, id, null)
		#g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, [str(to_string_name(), " is not improvable repairable")])
		#return
	#var sharpening = item.is_sharpable and (tool.entity_num == Enums.Esprite.whetstone or (entity_num == Enums.Esprite.whetstone and tool.entity_num == Enums.Esprite.flattening_stone))
	## repair on the fly so that changes don't need to be deleted each time
	#if imp_tool == Enums.Esprite.undefined:
		#if len(item.improvable_tools) > 0:
			#imp_tool = item.improvable_tools[0]
			#g_man.local_server_network_node.net_dp_node.target_load_id_entity_imptool.rpc_id(client.id_net, id, imp_tool)
		## only sharpable with tool whetstone can always sharpen the item
		#if not (sharpening):
			#return
	## improve compatibility
	#if not tool:
		#return
	#if tool.entity_num != imp_tool or (sharpening):
		#push_error("Not Compatible")
		#return
	## if it's done wrongly programmer needs to step in
	#if len(item.improvable_tools) == 0:
		#push_error("needs to set improvbable item in ItemObject ", to_string_name(), " probably needs item_object: ", tool.to_string_name())
		#return
	#var experience = 1
	#var create = 1
	##var a: Avatar = client.client.playing_avatar # TODO
	##if a:
		##if a.experiences:
			##if imp:
				##experience = a.experiences.get_exp_level(Enums.exp.improve)
			##else:
				##experience = a.experiences.get_exp_level(Enums.exp.repair)
			##create = a.experiences.get_average_create_exp_level(entity_num)
			##experience = (experience + create) / 2
	## final touch of config
	#var k = success_per(tool, self, entity_num, experience, false)
	#var item_hard: float = hard(tool, self, entity_num, false)
	#k = random_success(k)
	#
	#print("k = ", k)
	#if not tool.damage_tool(k, client):
		#push_error("tool is destroyed")
		#return
	#var t_parent = get_entity(parent)
	#if k < 0:
		#damage -= k * _K_DAMAGE_IMP_REPAIR * ql
		#if damage > 1000:
			#var workpieceScrap = make_scrap(t_parent, weight, client)
			##if not workpieceScrap: # TODO
				##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
				##destroy_me()
				##g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["unfortunately your workpiece was too much damaged, to do anything with it any longer"])
				##return
			##var ser = Serializable.serialize([workpieceScrap])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
		#damage = clampf(damage, 0, 999)
		#save_damage()
	#else:
		## only change between imp and repair
		#if imp:
			#var hard_k = clampf(1-(1/(item_hard * 0.01)), 0.30, 1)
			#print("hard_k:", hard_k)
			#ql += clampf(k * ((experience / clampf(ql, 1, 100000)) / hard_k), 0.1, 100)
			#save_ql()
		#else:
			## sharpening
			#if sharpening and not tool.entity_num == Enums.Esprite.flattening_stone:
				#var sharp_damage = load_return_sharpening_damage()
				#var repaired_damage = k * sharp_damage
				#damage -= repaired_damage
				#if damage < 0:
					#damage = 0
				#save_sharpening_damage(-repaired_damage, sharp_damage)
				#save_damage()
			#else:
				## normal repair
				#damage -= k * _K_REPAIR
				#ql -= k * 0.2
				#if damage < 0:
					#damage = 0
				#save_damage()
				#save_ql()
	## make a little bit of a scrap with each improvement / repair
	#if not sharpening:
		#var scrap_volume = volume * 0.001
		#if scrap_volume < 0.001:
			#scrap_volume = 0.001
		#if scrap_volume > volume:
			#scrap_volume = volume
		#var scrap = make_scrap(t_parent, scrap_volume, client)
		##if scrap: # TODO
			##var ser = Serializable.serialize([get_entity(scrap.parent), scrap])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	## if succeeded give new imp tool and add experience
	##if k > 0: # TODO
		##if a:
			##if a.experiences:
				##var to_ser_exp = a.experiences.add_exp_create_to_entity(entity_num, 1 + k)
				##if imp:
					##to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.improve))
				##else:
					##to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.repair))
				##var ser_exp = Serializable.serialize(to_ser_exp)
				##g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser_exp)
				##g_man.local_server_network_node.target_changes.rpc_id(client.id_net, str("you improved for ", str(k).pad_decimals(2)))
	##else:
		##if a:
			##if a.experiences:
				##k = absf(k)
				##var to_ser_exp = a.experiences.add_exp_create_to_entity(entity_num, k)
				##if imp:
					##to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.improve, k))
				##else:
					##to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.repair, k))
				##var ser_exp = Serializable.serialize(to_ser_exp)
				##g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser_exp)
				##g_man.local_server_network_node.target_changes.rpc_id(client.id_net, str("you failed to improve for ", str(k).pad_decimals(2)))
	## it always gets damaged
	#g_man.local_server_network_node.net_dp_node.target_load_id_entity_damage_ql_weight.rpc_id(client.id_net, tool.id, tool.damage, tool.ql, tool.weight)
	#if not get_entity(id):
		#push_error(id, " used up workpiece")
		#if client:
			#g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["Used up workpiece", "unfortunatelly you used up your work piece to 0 weight", "you may no longer improve or repair it"])
			#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
		#return
	## change imp tool
	#if not sharpening and item.improvable_tools.size() > 0:
		#imp_tool = item.improvable_tools[randi_range(0, len(item.improvable_tools) -1)]
		#g_man.local_server_network_node.net_dp_node.target_load_id_entity_imptool.rpc_id(client.id_net, id, imp_tool)
	## update imp tool
	##var ser_imp_workpiece = Serializable.serialize([self]) # TODO
	##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser_imp_workpiece)
	

## from self object to object
## returns: scrap
func transform(to: Enums.Esprite, tool: Entity, client):
	push_error("transform")
	if parent == 0:
		return
	var t_parent = get_entity(parent)
	# fetch config
	var item = mp.get_item_object(to)
	
	var a = client.client.playing_avatar
	var experience = 1
	var craft = 1
	if a:
		if a.experiences:
			craft = a.experiences.get_exp_level(Enums.exp.craft)
			experience = a.experiences.get_average_create_exp_level(to)
			experience = (experience + craft) / 2
	# final touch of config k 1 is max
	#var how_hard = hard(tool, self, to)
	var k = success_per(tool, self, to, experience, true)
	#var k = _success(how_hard, experience, craft)
	k = random_success(k)
	## CHANGE HERE!!!
	entity_num = to
	save_entity_num()
	## CHANGE HERE!!!
	
	push_error("K = ", k)
	# max ql
	#var max_ql
	#if experience < ql:
		#max_ql = ql
	#else:
		#max_ql = experience
		#if max_ql <= 0:
			#max_ql = 1
	#var result_ql = randf_range(experience, max_ql)
	
	# get bigger f if big enough workpiece
	#var f = k
	#if per_ratio > 0.3:
		#f = k * _K_FACTOR
		#if f < 0:
			#f *= -1
	# ql multi with k (0 - 1)
	#result_ql *= f
	## re calc max ql
	#if result_ql > max_ql:
		#result_ql = max_ql
	#if not tool.damage_tool(k, client):
		#push_error("tool is destroyed")
		#return
	# construction entity
	#if item.construct_materials.size() > 0:
		#push_error("construction")
		## failed
		#if k <= 0 || result_ql < min_ql:
			#push_error("failed: total scrap ", result_ql)
			#damage -= k * _K_DAMAGE * ql
			#if damage > 1000:
				#var total_scrap: Entity = make_scrap(t_parent, weight, client)
				#if total_scrap:
					##g_man.local_server_network_node.net_dp_node.target_entity_load_container.rpc_id(t_parent.id, t_parent.container, t_parent.volume, t_parent.weight, t_parent.group_weight, t_parent.group_volume)
					#pass
					##var seri = Serializable.serialize([t_parent, total_scrap, self]) # TODO
					##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, seri)
				#else:
					#push_error("Damage: ", damage, " ", id)
					#destroy_me()
					#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
					#return
			#push_error("warning maybe destroyed OR?")
			#g_man.local_server_network_node.net_dp_node.target_load_id_entity_damage_ql_weight.rpc_id(client.id_net, id, damage, ql, weight)
			#return
		#### too small/big workpiece for construction commented so that it can construct from 0 all materials
		###if per_ratio < MIN_WEIGHT_PERCENT:
			###g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["construction error", str("material ", to_string_name(), " is too small weight: ", weight), str("needs to be at least: ", mp.get_item_object(entity_num).weight_get * 0.92)])
			###return
		###if per_ratio > MAX_WEIGHT_PERCENT:
			###g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["construction error", str("material ", to_string_name(), " is too large weight: ", weight), str("needs to be max: ", mp.get_item_object(entity_num).weight_get * 1.2)])
			###return
			#
		## succeed
		## multi accuracy of the workpiece 
		#push_error("accuracy")
		#var accuracy = per_ratio - 1
		#accuracy = abs(accuracy)
		## almost impossible but if it is, ...
		#if accuracy == 0:
			#accuracy = 0.0001
		#k /= accuracy
		## again calculate result_ql as now we have accuracy
		#result_ql *= absf(k)
		#result_ql = randf_range(experience, result_ql)
		#if result_ql > max_ql:
			#result_ql = max_ql
		#
		#print("E construct")
		## here I get all the entity materials that are inside the construction entity
		#var entity_construction = create_from_scratch(to, true, true, false)
		#
		#entity_construction.ql = result_ql
		#
		#entity_construction.add_to_parent(t_parent, true, client)
		## we add tool and workpiece to the construction
		#add_to_parent(entity_construction, true, client)
		#tool.add_to_parent(entity_construction, true, client)
		#push_error(t_parent.entity_to_string(), " ", entity_construction, " ", tool.entity_to_string(), " ", entity_to_string())
		#
		#entity_construction.save_ql_weight()
		#var _ser = [entity_construction, self]
		#for e_mat in entity_construction.e_container:
			#_ser.push_back(e_mat)
		##g_man.local_server_network_node.net_dp_node.target_entity_load_container.rpc_id(client.id_net, t_parent.id, t_parent.container, t_parent.volume, t_parent.weight, t_parent.group_weight, t_parent.group_volume)
		##var ser = Serializable.serialize(_ser) # TODO
		##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	## fully constructed entity -> transformation
	#elif weight * MAX_WEIGHT_PERCENT >= item.weight_get or to == Enums.Esprite.fire:
		
		#var exps = a.experiences.get_average_create_exp_level(to)
		
		#var random_volume = randf_range(item.volume_get * MIN_WEIGHT_PERCENT * (exps/1000), item.volume_get * ( (( exps/1000) * MIN_WEIGHT_PERCENT) + MAX_WEIGHT_PERCENT))
		#if random_volume > volume:
			#random_volume = volume
		# failed
		#if k <= 0:# || result_ql < min_ql:
			#damage -= k
			#save_damage()
			#print("E total scrap")
			#var total_scrap: Entity = make_scrap(t_parent, random_volume * MAX_WEIGHT_PERCENT, client)
			#if total_scrap:
				##g_man.local_server_network_node.net_dp_node.target_entity_load_container.rpc_id(client.id_net, t_parent.id, t_parent.container, t_parent.volume, t_parent.weight, t_parent.group_weight, t_parent.group_volume, t_parent.constructed)
				#pass
				##var ser_scrap = Serializable.serialize([t_parent, total_scrap, self]) # TODO
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser_scrap)
			#return
		# succeed
		# if it cannot be created just don't do anything
		#var new_e = _divide_volume_to_parent(t_parent, random_volume)
		#if not new_e:
			#print("E not new_e")
			#return
		## if it's fire destroy it and lit the fire around it
		#if to == Enums.Esprite.fire:
			#var top_parent:Entity = get_top_parent(new_e)
			#top_parent.start_burning()
			#new_e.destroy_me()
			#if client:
				#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [new_e.id])
		#else:
			#print("E scrap from working")
			#new_e.ql = result_ql
			#new_e.damage = randf_range(0, damage)
			## scrap we make from working
			#var scrap = new_e.make_scrap(t_parent, random_volume * 0.03, client)
			#new_e.entity_num = to
			#new_e.calc_per_ratio()
			#new_e.calc_volume()
			#new_e.save_entity_num()
			#if scrap != new_e:
				#print("E scrap != new_e")
				#if new_e.add_to_parent(t_parent, true, client):
					#t_parent.save_parent_volume_weight()
					#new_e.save_parent_volume_weight()
					#new_e.save_ql_weight()
					#push_error(new_e.per_ratio, " ", new_e.to_string_name(), " ", new_e.id)
					#new_e.reset_container()
					#new_e.fully_save()
			#g_man.local_server_network_node.net_dp_node.target_entity_load_container.rpc_id(client.id_net, t_parent.id, t_parent.container, t_parent.volume, t_parent.weight, t_parent.group_weight, t_parent.group_volume)
			#if scrap: # TODO
				#var ser_scrap_new = Serializable.serialize([t_parent, scrap, new_e, self])
				#g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser_scrap_new)
			##if scrap and scrap.id != id:
				##var ser = Serializable.serialize([self])
				##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	## fully used entity just scrap is remaining
	#else:
		#g_man.local_server_network_node.target_instructions.rpc_id(client.id_net, ["construction error", str("fully used ", entity_to_string(), " just scrap is remaining"), str(Enums.Esprite.find_key(to), " weight would needed to be at least: ", item.weight_get)])
		#var scrap = make_scrap(t_parent, volume, client)
		#if scrap:
			##g_man.local_server_network_node.net_dp_node.target_entity_load_container.rpc_id(client.id_net, t_parent.id, t_parent.container, t_parent.volume, t_parent.weight, t_parent.group_weight, t_parent.group_volume)
			#pass
			##var ser_parent_scrap = Serializable.serialize([t_parent, scrap, self]) # TODO
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser_parent_scrap)
		#if scrap != self:
			#destroy_me()
			#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
	## experience
	#if k <= 0:
		#k = absf(k)
		#g_man.local_server_network_node.target_changes.rpc_id(client.id_net, str("you failed to construct for ", str(k).pad_decimals(2)))
		## add failed exp to the crafter
		#var to_ser_exp = a.experiences.add_exp_create_to_entity(to, k)
		#to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.craft, k))
		##var ser_exp = Serializable.serialize(to_ser_exp) # TODO
		##g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser_exp)
	##else:
		##g_man.local_server_network_node.target_changes.rpc_id(client.id_net, str("you constructed for ", str(k).pad_decimals(2)))
		### add exp to the crafter
		##var to_ser_exp = a.experiences.add_exp_create_to_entity(to, 1 + k)
		##to_ser_exp.push_back(a.experiences.add_exp_to(Enums.exp.craft))
		##var ser_exp = Serializable.serialize(to_ser_exp)
		##g_man.local_server_network_node.net_dp_node.target_update_experience.rpc_id(client.id_net, ser_exp)
	### update tool and workpiece
	##var ser_tool = Serializable.serialize([tool, self])
	##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser_tool)
	

## get part of me in to scrap and add to my parent
#func make_scrap(t_parent: Entity, scrap_volume: float, client) -> Entity:
	#var type = mp.get_item_object(entity_num).scrap_type
	#push_error("scrap type ", Enums.Esprite.find_key(type), " from ", to_string_name())
	#if type == Enums.Esprite.undefined:
		#push_error("Scrap from ", to_string_name(), " is undefined returned null")
		#return
	##var new_entities = divide(true, scrap_volume)
	#var new_e = _get_divided_entity(scrap_volume)
	##if new_entities.size() == 2:
		##new_e = new_entities[1]
		##new_entities[0].add_to_parent(t_parent, true, client)
	##elif new_entities.size() == 1:
		##new_e = new_entities[0]
	##else:
		##return
	#new_e.entity_num = type
	#push_error(materials)
	#new_e.ql = ql * 0.85
	##new_e.calc_per_ratio()
	##new_e.calc_volume()
	#var scrap = get_entity_with_enum(t_parent, type)
	#new_e.entity_num = type
	#if scrap:
		#t_parent.group_volume += new_e.volume
		#t_parent.group_weight += new_e.weight
		#t_parent.save_group_volume()
		#t_parent.save_group_weight()
		#scrap.volume += new_e.volume
		#scrap.weight += new_e.weight
		## give everything so it's destroyed
		#new_e._stream_materials(scrap, new_e.volume)
		#scrap.save_volume()
		#scrap.save_weight()
		#
		## set damage and ql
		#if ql < new_e.ql:
			#scrap.ql = ql
		#elif new_e.ql != 0:
			#scrap.ql = new_e.ql
			#
		#if damage > new_e.damage:
			#scrap.damage =  damage
		#else:
			#scrap.damage = new_e.damage
		#
		#if client:
			#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [new_e.id])
		##new_e.destroy_me()
		##if scrap.add_to_parent(t_parent, true, client):
			##t_parent.save_parent_volume_weight()
			##scrap.save_parent_volume_weight()
			##scrap.save_entity_num()
		#new_e.fully_save()
		##if weight <= 0:
			##destroy_me()
			##if client:
				##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id])
		##if client: # TODO
			##var ser = Serializable.serialize([t_parent, scrap])
			##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
		#return scrap
	#
	#if not new_e.add_to_parent(t_parent, true, client):
		#return new_e
	#
	#t_parent.save_parent_volume_weight()
	#new_e.fully_save()
	#push_warning(new_e.parent, " add to parent: ", Enums.Esprite.find_key(type), " ", new_e.entity_to_string())
	#return new_e

### returns: null = non in container
#static func get_entity_with_enum(entity: Entity, num: Enums.Esprite):
	#if not entity.has_container():
		#return
	#if entity.container.size() > 50:
		#return
	#for item: Entity in entity.e_container:
		#push_error("has entity ", item.to_string_name())
		#if item.entity_num == num:
			#return item
	#return
###get full scrap of me AND you NEED to destroy entity your self ment for world map
#static func transform_to_scrap(e: Entity, scrap_type: Enums.Esprite):
	#pass
	## create visual
	#var uni = g_man.savable_entity.get_set_new()
	#uni.config_world_space(Enums.Esprite.entity_visual_universal, e.pos, e.rot, true, false)
	## create new scrap
	#var scrap: Entity = g_man.savable_entity.get_set_new()
	## no material as we stream it
	#scrap.config_from_scratch(scrap_type, true, false, false)
	## config scrap
	#var e_weight = e.weight
	#e._stream_materials(scrap, e.volume)
	#scrap.weight = e_weight
	#scrap.calc_per_ratio()
	#scrap.calc_volume()
	## add scrap to uni
	#scrap.add_to_parent(uni, true, null)

#endregion end inproving
##region start burn
#func start_burning():
	#current_heat += START_BURNING
	#var totalParent: Entity = Entity.get_top_parent(self)
	#if totalParent.body:
		#var fireplace = totalParent.body
		##if fireplace is Fireplace: # TODO
			##totalParent.set_time_heat()
			##fireplace.empty_cooling_down = false
			##if fireplace.current_heat < 20:
				##fireplace.current_heat = 20
			##fireplace.current_heat += START_BURNING
			##fireplace.burning()
##endregion start burn
#region volumeWeight
#func set_volume_weight(newNum: Enums.Esprite):
	#var item_object = mp.get_item_object(newNum)
	#if item_object:
		#weight = item_object.weight_get
		#volume = item_object.volume_get
	#if weight == 0:
		#weight = 1
	#if volume == 0:
		#volume = 1
#
#static func get_volume(sprite: Enums.Esprite, my_weight: float):
	#var transform_volume = mp.get_item_object(sprite).volume_get
	#var default_weight = mp.get_item_object(sprite).weight_get
	#return (my_weight / default_weight) * transform_volume
#
### how much volume has parent left it substracts from child (me) volume
#func change_volume(add: bool, parent_entity: Entity):
	#var item_object_volume = mp.get_item_object(entity_num).volume_get
	#if add:
		#parent_entity.volume -= item_object_volume * per_ratio
	#else:
		#parent_entity.volume += item_object_volume * per_ratio
	#if parent_entity.volume < 0 && parent_entity.damage >= 0:
		#push_error("parent's ", Enums.Esprite.find_key(parent_entity.entity_num), " volume is negative should never be")
#
### if we need to divide the resources
### last one is divided one it could be hole one
#func divide(creatable: bool, sub_weight: float):
	#var item_object = mp.get_item_object(entity_num)
	#if not item_object.is_dividable and not creatable:
		#push_error("cannot divide ", to_string_name())
		#return [self]
	## too small to be divided
	#if per_ratio * item_object.weight_get <= sub_weight:
		#push_error("too small to be divided")
		#return [self]
	## save parent
	#push_error("parent id: ", self.parent)
	##var temp_parent: Entity = get_entity(parent)
	## calc ratio of sub of weight
	##//float perRatioSub = sub_weight / item_object.weight_get
	#
	## remove parent
	#remove_parent()
	## configure workpiece
	#push_error("maybe uncomment?")
	##//weight -= sub_weight
	#calc_per_ratio()
	#calc_volume()
	#
	## add to saved parent
	##if temp_parent:
		##push_error("add divided ", to_string_name(), " to my parent")
		##add_to_parent(temp_parent, true, null)
	### save config
	##save_parent_volume_weight()
##
	## create new entity
	#var entity = create_from_scratch(entity_num, true, false, false)
	#entity.ql = ql
	#entity.damage = damage # //config new entity
	#entity.weight = 0
	#
	#var temp = materials.duplicate()
	#for t in temp:
		#entity.stream_material_weight(self, t, sub_weight / materials.size())
	#entity.calc_per_ratio()
	#entity.calc_volume()
	## save config
	#entity.save_parent_volume_weight()
	#if weight > 0:
		#return [self, entity]
	## my weight is 0
	#destroy_me()
	#return [entity] # <-- self
#
### calc from per_ratio
#func calc_weight(new_per_ratio: float):
	#var entity_object = mp.get_item_object(entity_num)
	#weight = entity_object.weight_get * new_per_ratio
	#volume = entity_object.volume_get * new_per_ratio
	## change materials weight
	#calc_materials_weight()
	##for mat in materials:
		##mat.change_weight_depend_on_per_ratio(per_ratio, new_per_ratio)
	#per_ratio = new_per_ratio
	#save_weight()
#
### material calculated from weight
#func calc_materials_weight():
	#var materials_weight: float = 0
	## get total weight
	#for material in materials:
		#materials_weight += material.weight
	## calculate ratio depending on the entity weight
	#var ratio = weight / materials_weight
	## change all weights in to ratio together they sum up entity.weight
	#for material in materials:
		#material.change_weight(material.weight * ratio, true)
### flow of the entity from 1 object to self object
### entity_from: from entity to me
### streamed_weight: weight that will be streamed
### client: update data at client
### construct: if it's construction of an parent entity
### k is how good ql it will be
### returns: if object is destroyed it's true
#func stream_entity(entity_from: Entity, _streamed_weight: float, client, construct: bool, k: float = 1):
	#if not mp.get_item_object(entity_from.entity_num).is_combinable and not construct:
		#return false
	#var to_object = mp.get_item_object(entity_num)
	#var from_object = mp.get_item_object(entity_from.entity_num)
	#if (entity_from.entity_num != entity_num and not construct) and (not (from_object.entity_type == Enums.entity_type.clay and to_object.entity_type == Enums.entity_type.clay) ):
		#return false
	#if id == entity_from.id:
		#return false
	#### if it's done wrongly
	###if entity_from.group_weight < streamed_weight:
		###push_error("set weight is bigger than real weight")
		###streamed_weight = entity_from.weight
	#var from_before_parent = get_entity(entity_from.parent)
	#var this_before_parent = get_entity(parent)
	#
	#var e_per_ratio = _return_calc_per_ratio(volume)
	#var e_f_per_ratio = entity_from._return_calc_per_ratio(entity_from.volume)
	#
	#weight += entity_from.weight
	#volume += entity_from.volume
	#entity_from._stream_materials(self, entity_from.volume)
	#save_volume()
	#save_weight()
	#ql = ((ql * e_per_ratio + entity_from.ql * e_f_per_ratio) / (e_per_ratio + e_f_per_ratio)) * k
	#if damage >= 0:
		#damage = (damage * e_per_ratio + entity_from.damage * e_f_per_ratio) / (e_per_ratio + e_f_per_ratio)
	#
	#entity_from.destroy_me()
	##if client: # TODO
		##g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [entity_from.id])
		##var ser = Serializable.serialize([from_before_parent, this_before_parent, self])
		##g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	###entity_from.remove_parent()
	###remove_parent()
	###
	#### changes weights
	###var from_weight = entity_from.weight
	###
	###var temp = entity_from.materials.duplicate()
	###for t in temp:
		###push_error(to_string_name(), " ", weight)
		###stream_material_weight(entity_from, t, streamed_weight)
	#### set damage and ql
	###
	###if ql < entity_from.ql:
		###ql = ql
	###else:
		###ql = entity_from.ql
	#### set the ql of mold clay
	###if to_object.entity_type == Enums.entity_type.clay and entity_from.entity_num == Enums.Esprite.clay:
		#### 0.5 of added weight
		###var part_weight = ((weight - from_weight) / weight) * ql
		###ql = (ql + part_weight) * 0.5
	###
	###if not construct:
		###if damage < entity_from.damage:
			###damage = entity_from.damage
	#### self per ratio
	###calc_per_ratio()
	###calc_volume()
	#### add self to the self parent
	###add_to_parent(this_before_parent, true, client)
	#### destroy fromEntity as we have added him to the new entity
	###if entity_from.weight <= 0:
		###push_warning("destroy me ", entity_from.to_string_name(), " keep only ", to_string_name())
		###var id_destroyed = entity_from.id
		###entity_from.destroy_me()
		###if client:
			###g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [id_destroyed])
		###push_error("check next line it if it's right")
		###if client:
			###var to_ser = [self]
			###if from_before_parent:
				###to_ser.push_back(from_before_parent)
			###if this_before_parent:
				###to_ser.push_back(this_before_parent)
			###var ser = Serializable.serialize(to_ser)
			###g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
		###return true
	###push_error("keep both just stream")
	#### calc per_ratio and volume
	###entity_from.calc_per_ratio()
	###entity_from.calc_volume()
	#### add from to the from parent
	###entity_from.add_to_parent(from_before_parent, true, null)
	###push_error("check next line it if it's right")
	###if client:
		###var ser = Serializable.serialize([self, from_before_parent, this_before_parent, entity_from])
		###g_man.local_server_network_node.net_dp_node.target_entities_load.rpc_id(client.id_net, ser)
	###return false
#
### calculate from weight
#func calc_per_ratio():
	#per_ratio = weight / mp.get_item_object(entity_num).weight_get
#
### calculate from per_ratio
#func calc_volume():
	#volume = per_ratio * mp.get_item_object(entity_num).volume_get

## I'm parent of id entity marked for removal
func remove_my_child(id_to_remove):
	var child = get_entity(id_to_remove)
	if not child:
		push_error("child is null")
		return
	#parents_change_weight(-child.group_weight)#, -child.volume)
	#group_volume -= child.volume
	if has_container():
		if not container.has(id_to_remove):
			return
		child.parent = 0
		child.save_parent_volume_weight()
	else:
		push_error("containerTemp is null: " + entity_to_string())
#endregion end volumeWeight
#region transformVisual
## change visualises of entity on world
## in_uni: add self Entity to the new Universal box
func transform_visual(num: Enums.Esprite, in_uni: bool):
	push_error("transform visual")
	# first we destroy before visual
	#if body:
		#//body.position = Vector3(-100,-100,-100)
	
	# we make new one in temp
	var temp
	if not in_uni:
		push_error(Enums.Esprite.find_key(num))
		temp = mp.create_me(num)
		# and set it's position in destroyed zone so it's really fresh
		# temp.position = new Vector3(-100,-100,-100)
		# set entity visual so that batch entity's knows whom to load to client
		#temp.GetComponent<IEntityVisual>().serverEntity = self
	
	# config scale and weight
	#set_volume_weight(num)
	#if not in_uni and mp.get_item_object(entity_num).entity_type == Enums.entity_type.tree:
		#per_ratio = get_scale_planting()
	#weight *= per_ratio
	#push_error(weight)
	#save_parent_volume_weight()
	# save new entity
	entity_num = num
	save_entity_num()
	
	if in_uni:
		push_error("not working for now {position}")
		#//Entity uni = new Entity(Esprite.entity_visual_universal, position, rotation, true, false)
		#//transform_to_scrap(self, uni)
		#//add_to_parent(uni, true)
		
	#//save_position_rotation()
	#//wait a frame or 2 and set the transformed entity
	if not in_uni:
		push_error(pos)
		body = temp
		push_error(Enums.Esprite.find_key(num), " ", pos)
		body.position = pos
		body.rotation = rot
		#LeanTween.delayedCall(0.1f, ()=>{
			#body = temp
			#push_error($"{num}, {position}")
			#//set position so that correct batchEntities loads the entity
			#body.position = position
			#body.rotation = Quaternion.Euler(rotation)
		#})

## transform visual in to universal entity
func transform_visual_in_uni(num: Enums.Esprite):
	# first we destroy before visual
	#if body:
		#//body.position = new Vector3(-100,-100,-100)
	
	#//config scale and weight
	#set_volume_weight(num)

	#weight *= per_ratio
	# save new entity
	entity_num = num
	save_entity_num()
	var uni: Entity = g_man.savable_entity.get_set_new()
	uni.config_world_space(Enums.Esprite.entity_visual_universal, pos, rot, true, false)
	
	add_to_parent(uni, true, null)
	
	#//config child to right values
	#pos = Vector3.one
	save_position_rotation()
#endregion transformVisual
#region time
func set_time_planting():
	save_time_of_plant(Time.get_unix_time_from_system())

func get_scale_planting():
	var growing_scale = Time.get_unix_time_from_system()
	var time_of_plant = load_return_time_of_plant()
	push_error(growing_scale, " ", time_of_plant)
	growing_scale -= time_of_plant
	growing_scale *= 0.0001
	growing_scale += 0.0863
	if growing_scale > 1:
		growing_scale = 1
	#per_ratio = growing_scale
	#calc_weight(per_ratio)
	#calc_volume()
	#weight = mp.get_item_object(entity_num).weight_get
	#weight *= per_ratio
	return growing_scale

func calc_grow_scale(time_of_plant = 0):
	if not time_of_plant:
		time_of_plant = load_return_time_of_plant()
	var now = Time.get_unix_time_from_system()
	var elapsed_time = now - time_of_plant
	var entity_object = mp.get_item_object(entity_num)
	
	# calc scale to the infinity
	var ratio = elapsed_time / entity_object.grow_time
	var grow_scale = entity_object.grow_scale * ratio
	
	var grown_up
	# tree
	if not entity_object.new_entity == Enums.Esprite.undefined:
		grown_up = mp.get_item_object(entity_object.new_entity)
	# farm
	else:
		grown_up = mp.get_item_object(entity_object.harvest_type)
	var _scale = clamp(grow_scale, 0, grown_up.grow_scale)
	return _scale
#endregion end time
#region destruction
func damage_entity(entity_to_damage: Entity, client = null):
	var _damage = mp.calculate_damage(self, entity_to_damage)
	
	var k = _success(clampf((_damage / clampf(entity_to_damage.ql, 1, 1000)) * 0.001, 0, 1), 1)
	k = random_success(k)
	#damage_tool(k, client)
	if k > 0:
		_damage *= k
		entity_to_damage.damage += _damage
		entity_to_damage.save_damage()
		if entity_to_damage.damage > 1000:
			entity_to_damage.destroy_me()
			#if client:
				#g_man.local_server_network_node.net_dp_node.target_entitis_destroy.rpc_id(client.id_net, [entity_to_damage.id])
#endregion destruction
#region count
func get_dict_count():
	var dict = {}
	for e in e_container:
		var arr = dict.get_or_add(e.entity_num, [e.entity_num, 0])
		arr[1] += e.quantity
	return dict
#endregion count
#region save/Load
	#region ISavable
func fully_save():
	if not g_man.tutorial:
		#save_ql()
		#save_parent_volume_weight()
		#save_group_volume()
		save_entity_num()
		save_position_rotation()
		#save_constructed()
		save_damage()
		#save_special()
		#for mat in materials:
			#mat.save_weight()
	partly_loaded = 2

func partly_save():
	push_error("save: ", id, " ", to_string_name())
	save_entity_num()

func fully_load():
	#load_ql()
	load_parent()
	#load_parent_volume_weight()
	#load_group_volume()
	if not load_entity_num():
		destroy_me()
		return
	load_position_rotation()
	#load_constructed()
	load_damage()
	load_special()
	load_layer()
	#load_materials()
	if entity_num == Enums.Esprite.rock:
		pass
	# load marketplace
	if entity_num == Enums.Esprite.marketplace_inventory:
		#body = CreateMob.create_me_ghost(1) # TODO
		#body.inventory = self
		#body.entity_num_body_visuals = load_return_entity_num_body_visuals()
		#
		#var entity_demand = EntityDemand.new()
		#entity_demand.entity_num = entity_num
		#g_man.savable_entity_demand.set_index_data(id, entity_demand)
		#g_man.savable_entity_demand.set_index("marketplace", entity_demand.entity_num, entity_demand.id)
		return
	
	var item_object = mp.get_item_object(entity_num)
	if not item_object:
		destroy_me()
		return
	if item_object.is_improvable:
		if item_object.improvable_tools.size() == 0:
			push_error("add improvable tools for ", to_string_name())
		var rnd = randi_range(0, item_object.improvable_tools.size() -1)
		## IF ERROR invalid index -1 you need to add the improvable tool in to the mp.item_object
		#imp_tool = item_object.improvable_tools[rnd]
	reset_container()
	
	if parent:
		var entity_parent: Entity = g_man.savable_entity.get_index_data(parent)
		if entity_parent:
			var parent_obj = mp.get_item_object(entity_parent.entity_num)
			if not entity_parent._add_to_container(self) or (parent_obj.attachable and entity_parent.body):
				# if it cannot get in to container
				# if paren't is in world space and entity is attachable
				if item_object.attachable:
					pass
					#if entity_parent.body and entity_parent.body is IVisual: # TODO
						#var direction_index = load_return_direction_attach()
						#var entity_index = load_return_entity_attach()
						#if direction_index != null and entity_index != null:
							#entity_parent.body.build(self, direction_index, entity_index)
				return
			if entity_parent.entity_num == Enums.Esprite.marketplace_inventory:
				entity_parent.set_indexes(self)
				# if it is in marketplace container
				return
		else:
			# parent isn't loadable anyway
			parent = 0
	if damage > 1000:
		destroy_me()
	
	#if ql < min_ql and constructed and item_object.scrap_type != Enums.Esprite.undefined:
		#entity_num = item_object.scrap_type
		#ql = 10
		#save_ql_weight()
	#save_entity_num()
	#calc_per_ratio()
	#calc_volume()
	if not item_object:
		return
	
	if parent and pos != Vector2.ZERO:
		push_error("parent is not null and it's in world space: ", entity_to_string())
		return
	# it does not have parent and should not be in world space
	if not special and not parent and not item_object.is_top_inventory and not item_object.in_world_space and not pos:
		destroy_me()
		return
	if pos and not special:
		g_man.entity_manager.drop_entity_in_world(self, pos, layer)
	# if it has parent than it's not in world space or is it?
	#if parent:
		#pass
		#return
	#if not item_object.in_world_space:
		#return
	#if item_object.house:
		#push_error(item_object.houseFrame)
		#if(body == null){
			#body = mp.create_me(item_object.houseFrame)
		#}
		#var ihouse = body.GetComponent<IHouse>()
		#ihouse.LoadHouse(special, self)
		#return
	#elif item_object.vehicle:
		#body          = mp.create_me(entity_num)
		#body.position = position
		#body.rotation = Quaternion.Euler(rotation)
		#var iVehicle = body.GetComponent<IVehicle>()
		#iVehicle.special = special
		#Horse.NSLHorses.Set(special, iVehicle)
		#iVehicle.serverEntity = self
		#return
	#elif pos != Vector3.ZERO:
		#load_and_put_in(self, pos)
	
	#body.position = pos
	#body.rotation = rot
	#var iV = body.GetComponent<IEntityVisual>()
	#iV.serverEntity      = self
	#iV.serverEntity.body = body
	#iV.special           = special
	#if(special != 0){
		#push_error($"Special: {special}")
	#}
	#LoadTime()
	#//push_error($"{entity_num} {weight}")
#}
#
func partly_load():
	partly_loaded = 2
	fully_load()
	return
	# so that it doesn't load wrong ones
	#load_ql()
	#load_parent_volume_weight()
	load_parent()
	load_entity_num()
	load_damage()
	load_position_rotation()
	#load_ql_weight()
	#// push_error(entity_num)
	#reset_container()
	var entity_object = mp.get_item_object(entity_num)
	if damage > 1000 or entity_num == Enums.Esprite.nul:# or not id or ql < min_ql or entity_num == Enums.Esprite.dead_inventory:
		destroy_me()
		return
	if parent and not g_man.savable_entity.has(parent):
		destroy_me()
		return
	
	# if it's empty uni box
	if entity_num == Enums.Esprite.entity_visual_universal and container.size() == 0:
		push_error("empty uni box ", entity_to_string())
		destroy_me()
		return
	if parent == 0 and not(entity_object.is_top_inventory or entity_object.in_world_space):
		destroy_me()
		return
	if parent:
		var entity_parent:Entity = get_entity(parent)
		if entity_parent:
			entity_parent._add_to_container(self)
		else:
			push_error(parent, " is null why? check him out something about self happened at house")
			destroy_me()
			return
	elif entity_object.in_world_space and pos != Vector3.ZERO:
		load_and_put_in(self, pos)
		#body = mp.create_me(entity_num)
		#body.entity_type = load_return_entity_type()
		body.time_of_plant = load_return_time_of_plant()
		body.id = id
		#body.global_position = pos
	# if it's not in world and doesn't have a parent destroy it
	elif not parent and not entity_object.is_top_inventory:
		destroy_me()
	#//set it only if it's parent less and in world space
	#endregion end ISavable
	#region AllEntities
#// public void LoadAllEntities(){
#//     long last = DataBase.LastId(true, NetMan.DbMs, DataBase.path.entity, DataBase.fileName.id)
#//     for (long i = 1 i <= last i++){
#//         Entity e = NetMan.sin.SavableEntity.Get(i, false)
#//         if (e == null) continue
#//         var obj = MasterPool.Singleton.GetItemObject(e.entity_num)
#//         if(e.damage         > 1000
#//              ||(int)e.entity_num == 0
#//              ||e.entity_num      == Esprite.nul
#//              ||e.id       == 0
#//              ||e.ql             < MinQl
#//              ||e.entity_num      == Esprite.dead_inventory
#//              ||e.position.x     < -99 //||(e.parent == long.Null && e.containerTemp == null)
#//               )
#//         {
#//             //push_error($"{e.damage}, {e.entity_num}, {e.id}, {e.ql}, {e.parent}, {e.containerTemp == null}")
#//             e.destroy_me()
#//             //if(e.body != null)
#//             //  MasterPool.destroy_me(e.body) e.body = null
#//         }
#//         //if it's empty uni box
#//         else if(e.entity_num == Esprite.entity_visual_universal && e.container.Count == 0){
#//             push_error($"empty uni box {e}")
#//             //e.body.position = new Vector3(-100, -100, -100)
#//             e.destroy_me()
#//         }
#//         else if (e.idFather == 0 &&!(e.entity_num is 
#//                                          Esprite.inventory or
#//                                          Esprite.belt or
#//                                          Esprite.Trader_Inventory or
#//                                          Esprite.entity_visual_universal ||
#//                                      obj.inWorldSpace)
#//                 )
#//         {
#//             //push_error($"top Father is null should be deleted {e}")
#//             e.destroy_me()
#//         }
#//     }
#// }
#public static Entity LoadEntity(long id){
	#push_error("WE have new method have it at Load(long loadId){ }")
	#return null
	#// Entity loaded = NetMan.sin.NlServerEntity.Get1(id)
	#// //if not we make entity from scratch
	#// if(loaded == null){
	#//     loaded = new Entity(id)
	#// }
	#// else{
	#//     if(loaded.entity_num != Esprite.nul){
	#//         return loaded
	#//     }
	#//     else{
	#//         push_error($"already loaded: {loaded}")
	#//     }
	#// }
	#// loaded.LoadEntityNum()
	#// ItemObject item_object = MasterPool.singleton.GetItemObject(loaded.entity_num)
	#// loaded.load_parent_volume_weight()
	#//         
	#//
	#// loaded.load_position_rotation()
	#// loaded.load_ql_weight()
	#// loaded.load_damage()
	#// loaded.load_constructed()
	#// loaded.load_special()
	#// //push_error($"{loaded.id}, {id}")
	#// loaded.load_materials()
	#// if(item_object.is_improvable){
	#//     if(item_object.improvable_tools.Count == 0){
	#//         push_error($"add improvable tools for {loaded.entity_num}")
	#//     }
	#//     int rnd = UnityEngine.Random.Range(0, item_object.improvable_tools.Count)
	#//     loaded.imp_tool = item_object.improvable_tools[rnd]
	#// }
	#// if(loaded.ql < minQL && loaded.constructed && item_object.scrap_type != Esprite.undefined){
	#//     loaded.entity_num = item_object.scrap_type
	#//     loaded.ql = 1000
	#//     loaded.save_ql_weight()
	#//     loaded.save_entity_num(id)
	#// }
	#// if(loaded.parent != 0){
	#//     //if parent is loaded
	#//     Entity father = NetMan.sin.NlServerEntity.Get1(loaded.parent)
	#//     //if parent is not yet loaded we create one
	#//     if(father == null){
	#//         father = new Entity(loaded.parent)
	#//         father.reset_container(false)
	#//     }
	#//     //we add our self to the containerTemp
	#//     if(father.container != null){
	#//         push_error("uncomment")
	#//         //Father.containerTemp.Add(loaded.id)
	#//         NetMan.sin.NlServerEntity.set_father(id, loaded.ID, true)
	#//     }
	#//     else{//we clean up the mess
	#//         //push_error("Mess ?!?")
	#//         //push_error(loaded.ToString())
	#//         //push_error(Father.ToString())
	#//         //loaded.parent = long.Null
	#//         //loaded.save_parent_volume_weight()
	#//     }
	#// }
	#//         
	#// loaded.calc_per_ratio()
	#// loaded.calc_volume()
	#// if(item_object != null){
	#//     //if it is a containerTemp:
	#//     if(loaded.container == null){
	#//         loaded.reset_container(false)
	#//     }
	#//     //if it's in world
	#//     if(loaded.position != Vector3.one){
	#//         if(loaded.parent != 0){
	#//             push_error($"parent is not null and it's in world space: {loaded}")
	#//             return loaded
	#//         }
	#//         //if box is empty don't load it in world
	#//         /*if(loaded.entity_num == Esprite.entity_visual_universal){
	#//             if(loaded.containerTemp.Count == 0){
	#//                 loaded.damage = 10000
	#//                 continue
	#//             }
	#//         }*/
	#//                 
	#//         if(item_object.house){
	#//             push_error(item_object.houseFrame)
	#//             if(loaded.body == null){
	#//                 loaded.body = mp.create_me(item_object.houseFrame)
	#//             }
	#//             IHouse ihouse = loaded.body.GetComponent<IHouse>()
	#//             ihouse.LoadHouse(loaded.special, loaded)
	#//             return loaded
	#//         }
	#//         else if(item_object.vehicle){
	#//             loaded.body = mp.create_me(loaded.entity_num)
	#//             loaded.body.position = loaded.position
	#//             loaded.body.rotation = Quaternion.Euler(loaded.rotation)
	#//             IVehicle iVehicle = loaded.body.GetComponent<IVehicle>()
	#//             iVehicle.special = loaded.special
	#//             Horse.NSLHorses.Set(loaded.special, iVehicle)
	#//             iVehicle.serverEntity = loaded
	#//             return loaded
	#//         }
	#//         else{
	#//             loaded.body = mp.create_me(loaded.entity_num)
	#//         }
	#//                 
	#//         loaded.body.position = loaded.position
	#//         loaded.body.rotation = Quaternion.Euler(loaded.rotation)
	#//         IEntityVisual iV = loaded.body.GetComponent<IEntityVisual>()
	#//         iV.serverEntity = loaded
	#//         iV.serverEntity.body = loaded.body
	#//         iV.special = loaded.special
	#//         if(loaded.special != 0){
	#//             push_error($"Special: {loaded.special}")
	#//         }
	#//         loaded.LoadTime()
	#//         //push_error($"{loaded.entity_num} {loaded.weight}")
	#//     }
	#// }
	#// return loaded
#}
	#endregion end AllEntities
	#region position
func save_position_rotation():
	if not g_man.tutorial:
		DataBase.insert(_server, g_man.dbms, _path, "position", id, pos)
	#DataBase.insert(_server, g_man.dbms, _path, "rotation", id, rot)

func load_position_rotation():
	pos = DataBase.select(_server, g_man.dbms, _path, "position", id, Vector2.ZERO)
	#rot = DataBase.select(_server, g_man.dbms, _path, "rotation", id, Vector3.ZERO)

func save_layer():
	if not g_man.tutorial:
		DataBase.insert(_server, g_man.dbms, _path, "layer", id, layer)

func load_layer():
	layer = DataBase.select(_server, g_man.dbms, _path, "layer", id, 0)
	#endregion position
	#region parent volume weight
func save_parent():
	if not g_man.tutorial:
		DataBase.insert(_server, g_man.dbms, _path, "parent", id, parent)

#func save_parent_volume_weight():
	#save_parent()
	#save_volume_weight_and_group_volume_weight()
#
#func save_volume_weight_and_group_volume_weight():
	#save_volume()
	#save_group_volume()
	#save_weight_and_group_weight()
#
#func save_weight_and_group_weight():
	#save_weight()
	#save_group_weight()
#
#func save_volume():
	#DataBase.insert(_server, g_man.dbms, _path, "volume", id, volume)
#
#func save_weight():
	#DataBase.insert(_server, g_man.dbms, _path, "weight", id, weight)
#
#func save_group_weight():
	#DataBase.insert(_server, g_man.dbms, _path, "group_weight", id, group_weight)
#
#func save_group_volume():
	#DataBase.insert(_server, g_man.dbms, _path, "group_volume", id, group_volume)

func load_parent():
	parent = DataBase.select(_server, g_man.dbms, _path, "parent", id)

#func load_parent_volume_weight():
	#load_parent()
	#volume = DataBase.select(_server, g_man.dbms, _path, "volume", id)
	#load_weight()
#
#func load_weight():
	#weight = DataBase.select(_server, g_man.dbms, _path, "weight", id)
	#group_weight = DataBase.select(_server, g_man.dbms, _path, "group_weight", id)
#
#func load_group_volume():
	#group_volume = DataBase.select(_server, g_man.dbms, _path, "group_volume", id)
	##endregion parent volume weight
	#region Esprite
func save_entity_num():
	DataBase.insert(_server, g_man.dbms, _path, "entity_num", id, entity_num)
	## marketplace
	#if entity_num == Enums.Esprite.marketplace_inventory:
		## first remove it if it matches id
		#g_man.savable_entity.remove_index("marketplace", entity_num, id)
		## set marketplace
		#g_man.savable_entity.set_index("marketplace", entity_num, id)
func load_entity_num():
	var e_num = DataBase.select(_server, g_man.dbms, _path, "entity_num", id)
	if e_num:
		entity_num = e_num
		return true
	else:
		return false
	## marketplace
	#if entity_num == Enums.Esprite.marketplace_inventory:
		## first remove it if it matches id
		#g_man.savable_entity.remove_index("marketplace", entity_num, id)
		## set marketplace
		#g_man.savable_entity.set_index("marketplace", entity_num, id)
		#region entity_num body visuals
func save_entity_num_body_visuals(entity_num_body_visuals):
	DataBase.insert(_server, g_man.dbms, _path, "entity_num_body_visuals", id, entity_num_body_visuals)

func load_return_entity_num_body_visuals():
	return DataBase.select(_server, g_man.dbms, _path, "entity_num_body_visuals", id)
		#endregion entity_num body visuals
	#endregion Esprite
	##region ql / weight
#func save_ql_weight():
	#save_ql()
	#save_weight()
#
#func load_ql_weight():
	#load_ql()
	#load_weight()
	##endregion ql / weight
	#region time
func save_time_of_plant(time_of_plant):
	DataBase.insert(_server, g_man.dbms, _path, "time", id, time_of_plant)

func load_return_time_of_plant():
	var time_of_plant = DataBase.select(_server, g_man.dbms, _path, "time", id)
	if time_of_plant:
		return time_of_plant
	else:
		return 0

		##region entity type
#func save_entity_type(entity_type: Enums.entity_type):
	#DataBase.insert(_server, g_man.dbms, _path, "entity_type", id, entity_type)
#
#func load_return_entity_type():
	#var entity_type = DataBase.select(_server, g_man.dbms, _path, "entity_type", id)
	#if entity_type:
		#return entity_type
	#return 0
		##endregion entity type
	#endregion time
	##region construction
#func save_constructed():
	#DataBase.insert(_server, g_man.dbms, _path, "constructed", id, constructed)
#
#func load_constructed():
	#var construc = DataBase.select(_server, g_man.dbms, _path, "constructed", id) 
	#if construc != null:
		#constructed = construc
	##endregion end construction
	#region damage
func save_damage():
	DataBase.insert(_server, g_man.dbms, _path, "damage", id, damage)

func load_damage():
	damage = DataBase.select(_server, g_man.dbms, _path, "damage", id)

### add attribute sharp damage for not needed to load it again
#func save_sharpening_damage(additional_damage, sharp_damage):
	#if not sharp_damage:
		#sharp_damage = load_return_sharpening_damage()
	#sharp_damage += additional_damage
	#sharp_damage = clampf(sharp_damage, 0, 50)
	#DataBase.insert(_server, g_man.dbms, _path, "sharp_damage", id, sharp_damage)
#
#func load_return_sharpening_damage():
	#return DataBase.select(_server, g_man.dbms, _path, "sharp_damage", id, 0)
	#endregion end damage
	#region special
func save_special():
	DataBase.insert(_server, g_man.dbms, _path, "special", id, special)
func load_special():
	special = DataBase.select(_server, g_man.dbms, _path, "special", id)
	#endregion special
	##region ql
#func save_ql():
	#DataBase.insert(_server, g_man.dbms, _path, "ql", id, ql)
#
#func load_ql():
	#var _ql = DataBase.select(_server, g_man.dbms, _path, "ql", id)
	#if _ql:
		#ql = _ql
		#return ql
	#return false
	##endregion ql
	#region lock
		#region locked
func save_locked(locked: bool):
	DataBase.insert(_server, g_man.dbms, _path, "locked", id, locked)

func load_return_locked():
	return DataBase.select(_server, g_man.dbms, _path, "locked", id, false)
		#endregion locked
		#region key id
func save_key_id(key_id: int):
	DataBase.insert(_server, g_man.dbms, _path, "key_id", id, key_id)

func load_return_key_id():
	return DataBase.select(_server, g_man.dbms, _path, "key_id", id, 0)
		#endregion key id
	#endregion lock
	##region marketplace
		##region article cost
#func save_article_cost(min_amount, max_amount):
	## if min is bigger than max both are same and it's not an auction any longer
	#if min_amount > max_amount:
		#max_amount = min_amount
	#DataBase.insert(_server, g_man.dbms, _path, "min_article_cost", id, min_amount)
	#DataBase.insert(_server, g_man.dbms, _path, "article_cost", id, max_amount)
#
#func load_return_article_cost():
	#var min_cost = DataBase.select(_server, g_man.dbms, _path, "min_article_cost", id, 0)
	#return [
		#min_cost,
		#DataBase.select(_server, g_man.dbms, _path, "article_cost", id, min_cost)
		#]
		##endregion article cost
		##region bidder
#func save_bidder(_id_avatar):
	#DataBase.insert(_server, g_man.dbms, _path, "article_bidder", id, _id_avatar)
#
#func load_return_bidder():
	#return DataBase.select(_server, g_man.dbms, _path, "article_bidder", id)
		##endregion bidder
		##region bid
#func save_bid(bid):
	#DataBase.insert(_server, g_man.dbms, _path, "article_bid", id, bid)
#
#func load_return_bid():
	#return DataBase.select(_server, g_man.dbms, _path, "article_bid", id)
		##endregion bid
		##region auction time
#func save_time_auction(max_time):
	#if max_time:
		#max_time += Time.get_unix_time_from_system()
		#DataBase.insert(_server, g_man.dbms, _path, "article_time", id, float(max_time))
#
#func load_return_time_auction():
	#return DataBase.select(_server, g_man.dbms, _path, "article_time", id, 0)
		##endregion auction time
		##region article avatar
#func save_article_avatar(_id_avatar):
	#DataBase.insert(_server, g_man.dbms, _path, "article_avatar", id, _id_avatar)
#
#func load_return_article_avatar():
	#return DataBase.select(_server, g_man.dbms, _path, "article_avatar", id, 0)
		##endregion article avatar
		##region customer
#func save_customers_count(add: bool):
	#var customer_count: float = load_return_customers_count()
	#if add:
		#customer_count += 0.1
	#else:
		#customer_count -= 0.1
	#customer_count = clampi(int(customer_count), 1, 5)
	#printerr("Entity count: ", customer_count)
	#DataBase.insert(_server, g_man.dbms, _path, "customers_count", id, customer_count)
#
#func load_return_customers_count():
	#return DataBase.select(_server, g_man.dbms, _path, "customers_count", id, 1)
		##endregion customer
	##endregion marketplace
	##region attach
		##region direction
#func save_direction_attach(index_direction):
	#DataBase.insert(_server, g_man.dbms, _path, "direction_attach", id, index_direction)
#
#func load_return_direction_attach():
	#return DataBase.select(_server, g_man.dbms, _path, "direction_attach", id)
		##endregion direction
		##region entity
#func save_entity_attach(index_entity):
	#DataBase.insert(_server, g_man.dbms, _path, "entity_attach", id, index_entity)
#
#func load_return_entity_attach():
	#return DataBase.select(_server, g_man.dbms, _path, "entity_attach", id)
		##endregion entity
	##endregion attach

#endregion end save / Load
##region indexing
#enum indexing{
	#ENTITY_NUM = 1,
	#QL = 2,
	#WEIGHT = 3,
	#DAMAGE = 4
#}
#
#func set_indexes(entity: Entity):
	#set_index(indexing.ENTITY_NUM, [entity.entity_num, entity.ql, entity.weight, entity.damage, id], entity.id)
#
#func remove_indexing(entity: Entity):
	#remove_index(indexing.ENTITY_NUM, [entity.entity_num, entity.ql, entity.weight, entity.damage, id], entity.id)
#
#func set_index(index: indexing, key, _id: int):
	#var savable = g_man.savable_entity
	#remove_index(index, key, _id)
	#savable.set_index(index, key, _id)
#
#func remove_index(index, key, _id):
	#var savable = g_man.savable_entity
	#savable.remove_index(index, key, _id)
#
#func get_index_pairs(index: indexing, min_variant, max_variant, _entity_num):
	#var savable = g_man.savable_entity
	#var pairs = savable.get_index_pair_range(indexing.ENTITY_NUM, [_entity_num, min_variant, min_variant, min_variant, id], [_entity_num, max_variant, max_variant, max_variant, id], 15, index - 1)
	#return pairs
#
##endregion indexing
#region serialize
func serialize():
	var item_object = mp.get_item_object(entity_num)
	var data = []
	data.push_back(id)
	#locked
	if item_object.is_container:
		data.push_back(load_return_locked())
	else:
		data.push_back(false)
	if item_object.is_container or item_object.is_key:
		data.push_back(load_return_key_id())
	else:
		data.push_back(0)
	#data.push_back(ql)
	data.push_back(parent)
	data.push_back(damage)
	data.push_back(entity_num)
	#data.push_back(weight)
	#data.push_back(group_weight)
	#data.push_back(volume)
	#data.push_back(group_volume)
	#data.push_back(constructed)
	data.push_back(item_object.entity_type)
	#data.push_back(current_heat)
	data.push_back(null)
	for id_entity in container:
		data.push_back(id_entity)
	data.push_back(null)
	#for material in materials:
		#data.push_back(material.type_material)
		#data.push_back(material.cooked)
		#data.push_back(material.weight)
	return data
#endregion serialize
#region to_string()
func entity_to_string():
	#return str("v: ", str(volume).pad_decimals(2), " ql: ", str(ql).pad_decimals(2), " w: ", str(weight).pad_decimals(2), " ", str(Enums.Esprite.find_key(entity_num)).replace("_", " "))
	return str(Enums.Esprite.find_key(entity_num)).replace("_", " ")
#public override string ToString(){
	#push_error("WTF")
	#/*if(Get(id)?.materials.Count > 0){
		#return $"{id}, {entity_num.ToString().Replace('_', ' ')}, {weight.ToString("0.0")}"
	#}*/
	#//else{
	#//Entity e = Entity.Get(id)
		#// return $"{id}, {idFather} ql: {ql.ToString("0.0")}, w: {weight.ToString("0.00")} {entity_num.ToString().Replace('_', ' ')}"// \nheat: {e?.current_heat}"// p:{per_ratio.ToString("0.00")} ql:{ql.ToString("0.0")} v:{volume.ToString("0.0")} gW:{group_weight.ToString("0.0")} w: {weight.ToString("0.0")} "
		#return $"v: {volume:0.0} ql: {ql:0.0}, w: {weight:0.0} {entity_num.ToString().Replace('_', ' ')}"// \nheat: {e?.current_heat}"// p:{per_ratio.ToString("0.00")} ql:{ql.ToString("0.0")} v:{volume.ToString("0.0")} gW:{group_weight.ToString("0.0")} w: {weight.ToString("0.0")} "
	#//}
#}
#public string ToStringQl() => $"ql: {ql:0.0}, {entity_num.ToString().Replace('_', ' ')}"
func to_string_name():
	return str(Enums.Esprite.find_key(entity_num)).replace('_', ' ')
#endregion to_string()
