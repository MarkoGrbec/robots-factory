class_name MasterPool extends Node

@export var global_timer: Timer

func _ready() -> void:
	for entity_object in container:
		if entity_object:
			if(dict_container.has(entity_object.entity_num)):
				var key = entity_object.entity_num
				push_error(str(dict_container[key].entity_num, ", ", entity_object.entity_num, ", ", "share same entity_num: [", key, "] string:[", Enums.Esprite.find_key(key), "]"))
				for i in container.size():
					if container[i]:
						if container[i].entity_num == entity_object.entity_num:
							printerr("same entity index: ", i)
			dict_container[entity_object.entity_num] = entity_object
	# add weight to constructed entities others leave alone
	for entity_object in container:
		if entity_object:
			if entity_object.construct_materials:
				entity_object.weight_get = 0
				for entity_num_material in entity_object.construct_materials:
					var entity = dict_container.get(entity_num_material)
					entity.calc_ratio()
					entity_object.weight_get += entity.weight_get
				
	#for exp_obj in experience_container:
		#dict_exp[exp_obj.index] = exp_obj
	#for plan in entity_plan_container:
		#dict_entity_num__plan[plan.entity_num] = plan
	
	# add http send recieve open ai debugging
	#var request = HTTPRequest.new()
	#add_child(request)
	#var quest_object = QuestObject.new()
	#quest_object.set_request(request)
	
	# house ground
	for house in array_house_ground:
		dict_ground_to_house_container[house.house_tile_position] = house.house_internal_tile_position
		dict_house_to_ground_container[house.house_internal_tile_position] = house.house_tile_position

var dict_container: Dictionary[Enums.Esprite, EntityObject]
var dict_exp = {}
var dict_entity_num__plan = {}

@export var container: Array[EntityObject]
#@export var material_container: Array[MaterialObject]
#@export var experience_container: Array[ExperienceObject]
#@export var entity_plan_container: Array[EntityPlanObject]
@export var quest_container: Array[QuestObject]
#@export var dungeon_levels: Array[DungeonObject]
#@export var customer_container: Array[CustomerObject]
@export var array_house_ground: Array[HouseGround]
var dict_house_to_ground_container: Dictionary[Vector2i, Vector2i]
var dict_ground_to_house_container: Dictionary[Vector2i, Vector2i]

func create_me(index):
	if(dict_container.has(index)):
		if index == Enums.Esprite.nul:
			push_error("the sprite is nul try setting it to something")
			return _create_null()
		var res:EntityObject = dict_container[index]
		if res:
			if res.scene:
				return res.pop()
			else:
				push_error("add scene to the ", str(Enums.Esprite.find_key(index)))
				return _create_null()
		else:
			return _create_null()
	else:
		push_error(String("wrong index: [{i}] selected Entity name: [{name}] does not exist\ntry adding index to MPtscn").format({i = index, name = Enums.Esprite.find_key(index)}))
		print("creating nul entity with index")
		return _create_null()

func _create_null():
	var res: EntityObject = dict_container[Enums.Esprite.undefined]
	return res.pop()

## i = to destroy plan entity
func destroy_me(node: Node, i = 0):
	if node == null:
		push_error("you are trying to destroy node that doesn't exist")
	elif node is Node or node.is_visible_in_tree():
		if node.has_method("get_entity_num"):
			#first father
			#if i == 0:
				#i += 1
				## destroy plan entity
				#var parent = node.get_parent()
				#if parent is EntityBase:
					#destroy_me(parent, i)
			
			var e_num = node.entity_num
			if dict_container.has(e_num):
				dict_container[e_num].push(node)
			else:
				node.queue_free()
		else:
			push_error("node: ", node.name, " doesn't not have method name get_entity_num")
			node.queue_free()
	else:
		push_error("WARNING you are trying to hide entity ", Enums.Esprite.find_key(node.entity_num), " that's already hidden")
	
func get_item_object(index) -> EntityObject:
	if dict_container.has(index):
		return dict_container[index]
	else:
		printerr("container doesn't exist", Enums.Esprite.find_key(index), " : ", index)
		push_error(String("container [{index}] [{name_index}] does not exist you need to add it to the MP.tscn").format({index = index, name_index = Enums.Esprite.find_key(index)}))
		return container[0]

## get results that are made from workpiece with tool
func get_work_pieces(tool, workpiece):
	var entityObj = get_item_object(workpiece)
	if entityObj:
		return entityObj.get_workpieces(tool)
	return []

# Check if the result comes from the workpiece
func get_come_from(tool, workpiece, result):
	var tool_object = get_item_object(tool)
	var workpiece_object = get_item_object(workpiece)
	var result_object = get_item_object(result)
	
	push_error("workpiece: ", workpiece_object.to_string_name())
	if workpiece_object.get_workpieces(tool):
		push_error(String("{results} is made with {tool}").format({results = result_object.to_string_name(), tool = tool_object.to_string_name()}))
		if workpiece_object.can_be_created_result(tool_object.entity_num, result):
			push_error(String("and makes result {result}").format({result = result_object.to_string_name()}))
			return true
	push_error(String("{result}, cannot be made with {tool} and workpiece: {workpiece}").format({result = result_object.to_string_name(), tool = tool_object.to_string_name(), workpiece = workpiece_object.to_string_name()}))
	push_error(String("maybe {tool} needs in create results").format({tool = tool_object.to_string_name()}))
	return false

#func get_exp_obj(index: Enums.exp) -> ExperienceObject:
	#return dict_exp[index]
	

#func config_exp(experience: Experience):
	#var exp_obj = dict_exp[experience.index]
	#experience.position = exp_obj.position
	#experience.enum_parent = exp_obj.enum_parent

func make_new_exp(id_avatar, index):
	var exp_obj = dict_exp.get(index)
	if exp_obj:
		var experience = g_man.savable_multi_avatar__experience.new_data(id_avatar, 0)
		experience.index = index
		experience.enum_parent = exp_obj.enum_parent
		experience.position = exp_obj.position
		experience.fully_save()
		return experience

func get_plan(entity_num: Enums.Esprite):
	return dict_entity_num__plan.get(entity_num)

func get_plan_attached(entity_num: Enums.Esprite):
	var data = dict_entity_num__plan.get(entity_num)
	if data:
		data = data.attach
	return data

func set_quests_npcs():
	for quest_index in len(quest_container):
		quest_container[quest_index].generate_npc(quest_index + 1)

func get_quest_object(quest_index) -> QuestObject:
	return quest_container[quest_index - 1]

func get_quest_objects(id_avatar) -> Array[ServerQuest]:
	var server_quests: Array[ServerQuest]
	for quest_object in quest_container:
		var server_quest = quest_object.create_npc_with_avatar(id_avatar)
		if server_quest:
			server_quests.push_back(server_quest)
	return server_quests

#func calculate_damage(entity_attacking: Entity, entity_defending: Entity):
	#var att_obj = get_item_object(entity_attacking.entity_num)
	#var def_obj = get_item_object(entity_defending.entity_num)
	#var attack
	#if att_obj.is_top_inventory:
		#attack = att_obj.attack
	#else:
		#attack = att_obj.attack * entity_attacking.ql
	#
	#var defense
	#if def_obj.is_top_inventory:
		#defense = def_obj.attack
	#else:
		#defense = def_obj.attack * entity_defending.ql
	#return clampf(attack / defense, 0, 1000)

#public class MasterPool : MonoBehaviour
#{
	#public ItemDatabaseObject database
	#public CustomerObject GetCustomerObject(int nameIndex){
		#return database.customers[nameIndex]
	#}
	#public void RelocateNpc(short index, Vector3 position){
		#database.quests[index].RelocateNpc(index, position)
	#}
	#
	#private CustomerObject[] _customerPool
	#///needs to be big enough items that needs to be added by script
	#//private Pool[] Pools
	#public ItemObject GetItemObject(Esprite entity_num)
	#{
		#return ! database.Check(entity_num) ? null : database.get_item_object(entity_num).itemObject
	#}
#
	#public List<Material> ground = new List<Material>()
#}
#/*
## Manual
## mp is singleton
## 
## EntityObject is Resource
## 
## mp has array of EntityObjects
## click on element empty and select new EntityObject
## now populate it with values
## 
## simple CreateMe makes an entity which has the number of entity you desire
#################################

# roboti so jezni na direktorja fabrke
# direktor grdo ravna z njimi
# težko delo jim da
# brez plače
# na mrzlem
# neprimerne razmere
# okvara strojev ker jih ne vzdržuje
# neprilagojen delovni čas
# 
# direktor nima denarja za plače
# stroji so predragi da bi jih vzdrževal kupil
# veliko komandira
# veliko dela jim naloži
# daleč se morajo vozit
# ne plača potnih stroškev
# je neurejen
# delavci se mu zdijo manj vredni ker je on nekaj več
# 
# delavci so prizadeti zaradi tega
# direktor je vzvišen
# direktor je poln ponosa
# imel bi kup denarja a nima za plače
# 
# ponjklivo orodje uniforme
# pomanjkljivo usposobljeni
# 
# 
# 
# ROBOT

# kako si
# utrujen

# če rabi pomoč
# neve če se mu sploh še da pomagat

# če je žalosten
# ja ker sem utrujen in nemorem ne naprej ne nazaj

# 
# 
################################
# malta
# železne palce
# opeka - glina ali kamna
# strešna kritina
# steklo - okna
# 
# 1. malta
# 2. kovina - železne palce malta
# 3. okna - opeka - železo
# 4. železne štange
# 5. strešna kritina
# 6. opeka
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
