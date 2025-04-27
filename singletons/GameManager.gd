extends Node

var tutorial: bool = false

var user: User
var player: CPPlayer
var camera: Camera
var map: MapGroundLayer
var changes_manager: ChangesManager
var main_menu: MainMenu
var tile_map_layers: TileMapLayers
var quests_manager: QuestsManager
var change_name_manager: ChangeNameManager
var inventory_system: InventorySystem
var entity_manager: EntityManager
var mold_window: MoldWindow
var bindings: Bindings
var sliders_manager: SlidersManager
var in_game_menu: InGameMenu
var trader_manager: TraderManager
var misc: Misc
var music_manager: MusicManager
var stats_labels: StatsLabels

var friendly_robots_spawn_reality: FriendlyRobotsSpawnReality
var friendly_robots_spawn_godish: FriendlyRobotsSpawnGodish
var friendly_robots_spawn_fight: FriendlyRobotsSpawnFight

var factory: Factory
var enemy_factory: Factory
var factory_fight: Factory

var dbms = "DBMS"

var savable_user: Savable
var savable_terrain_ground: Savable
var savable_terrain_underground1: Savable
var savable_terrain_underground2: Savable
var savable_terrain_underground3: Savable

var savable_multi_tarrain_user__layer: SavableMulti
var savable_multi_terrain_layer__quadrant: SavableMulti
var savable_multi_terrain_quadrant__cell: SavableMulti
#var savable_terrain_cell: Savable

var savable_multi_avatar__quest_data: SavableMulti

#var savable_multi___quest__qq: SavableMulti
var savable_multi____quest___qq__qq: SavableMulti

### between quest giver and which qq have flags
#var multi_table___quest__qq: DataBase.MultiTable
### between quest question and which flags it has
#var multi_table____quest___qq__qq: DataBase.MultiTable
var savable_entity: Savable
var savable_multi_entity__material: SavableMulti
var savable_holding_hand: Savable
var savable_inventory_slot: Savable
var savable_trader: Savable
var savable_mob: Savable

var holding_hand: HoldingHand
var trader: Trader

var asking_toggled: bool = false
var dragging_node
func _ready() -> void:
	randomize()
	create_database()
	savable_user = Savable.new(false, dbms, "user", User.new())
	savable_terrain_ground = Savable.new(false, dbms, "terrain_ground", Terrain.new())
	savable_terrain_underground1 = Savable.new(false, dbms, "terrain_underground1", Terrain.new())
	savable_terrain_underground2 = Savable.new(false, dbms, "terrain_underground2", Terrain.new())
	savable_terrain_underground3 = Savable.new(false, dbms, "terrain_underground3", Terrain.new())
	
	savable_multi_tarrain_user__layer = SavableMulti.new(false, dbms, "terrain_user_layer", TerrainUser_Layer.new())
	savable_multi_terrain_layer__quadrant = SavableMulti.new(false, dbms, "terrain_layer_quadrant", TerrainLayer_Quadrant.new())
	savable_multi_terrain_quadrant__cell = SavableMulti.new(false, dbms, "terrain_quadrant_cell", TerrainQuadrant_Cell.new())
	#savable_terrain_cell = Savable.new(false, dbms, "terrain_cell", TerrainCell.new())
	
	savable_multi_avatar__quest_data = SavableMulti.new(false, dbms, "savable_multi_avatar__quest_data", ServerQuest.new())
	savable_multi____quest___qq__qq = SavableMulti.new(false, dbms, "qq_deep", QQDeep.new())
	savable_entity = Savable.new(false, dbms, "entity", Entity.new())
	savable_inventory_slot = Savable.new(false, dbms, "inventory_slot", InventorySlot.new())
	savable_multi_entity__material = SavableMulti.new(false, dbms, "entity_material", EntityMaterial.new())
	savable_holding_hand = Savable.new(false, dbms, "holding_hand", HoldingHand.new())
	savable_trader = Savable.new(false, dbms, "trader", Trader.new())
	savable_mob = Savable.new(false, dbms, "mob", Mob.new())
	
	savable_multi____quest___qq__qq.remove_all()

func delete_database_if_needed():
	var last_id_file_name = DataBase.directory_exists(false, dbms, "user", "id")
	var meta_data = DataBase.get_header(last_id_file_name)
	if meta_data and meta_data[4] == 0:
		var file_name = str(OS.get_user_data_dir(), "/", dbms)
		OS.move_to_trash(file_name)
		await get_tree().process_frame
		mold_window.set_instructions_only(["I'm sorry but I needed to delete your DBMS", "btw there's save directory on your PC at:", str("\n", OS.get_user_data_dir(), "/", dbms)])

func create_database():
	delete_database_if_needed()
	var _table: DataBase.Table
	#_table = DataBase.Table.new("windows")
	#_table.create_column(false, dbms, DataBase.DataType.RECT, 1, "rect")
	_table = DataBase.Table.new("user")
	_table.create_column(false, dbms, DataBase.DataType.STRING, 16, "username")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "time_changed_name")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "type")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "gold_coins")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "weapon")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "battery_constumption")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weapon_range")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weapon_reflexes")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weapon_strength")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "armor_strength")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "believe_in_god")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "layer")
	_table.create_column(false, dbms, DataBase.DataType.VECTOR2, 1, "position")
	
	
	
	_table = DataBase.Table.new("audio")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "Master_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "music_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "ui_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "sfx_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "rain_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "foot_steps_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "thunder_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "robot_p3")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weapon_p3")
	
	
	
	_table = DataBase.Table.new("misc")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "quest_move")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "slow_writing")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "speak_names")
	
	
	_table = DataBase.Table.new("trader")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "activated")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "gold_coins")
	
	_table = DataBase.Table.new("holding_hand")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "movement")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "movement_completed")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "dig")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "drop")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "underground")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "npc")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "trader")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "quadrant1")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "believe")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "inventory")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "changes")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "npc_give_item")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "to_surface")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "trader_buy")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "enemy")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "enemy_finished")
	
	#_table = DataBase.Table.new("terrain_ground")
	#create_columns_terrain(_table)
	#_table = DataBase.Table.new("terrain_underground1")
	#create_columns_terrain(_table)
	#_table = DataBase.Table.new("terrain_underground2")
	#create_columns_terrain(_table)
	#_table = DataBase.Table.new("terrain_underground3")
	#create_columns_terrain(_table)
	_table = DataBase.Table.new("terrain_quadrant_cell")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "layer")
	_table.create_column(false, dbms, DataBase.DataType.VECTOR2I, 1, "position")
	_table.create_column(false, dbms, DataBase.DataType.ARRAY, 48, "array_data_array")
	
	_table = DataBase.Table.new("savable_multi_avatar__quest_data")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "inventory")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "basis")
	_table.create_column(false, dbms, DataBase.DataType.INT, 16, "basis_flags")
	_table.create_column(false, dbms, DataBase.DataType.ARRAY, 64, "mission_keys")
	_table.create_column(false, dbms, DataBase.DataType.INT, 16, "mission_values")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "mission_quantity")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "activated")
	_table.create_column(false, dbms, DataBase.DataType.VECTOR2, 1, "position")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "initialized")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 2, "believe")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "layer")
	
	_table = DataBase.Table.new("qq_deep")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "index")
	
	_table = DataBase.Table.new("inventory_slot")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "id_entity")
	
	_table = DataBase.Table.new("entity")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "ql")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "parent")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "volume")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weight")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "group_weight")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "group_volume")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "entity_num")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "quantity")
	_table.create_column(false, dbms, DataBase.DataType.VECTOR2, 1, "position")
	#_table.create_column(false, dbms, DataBase.DataType.VECTOR2, 1, "rotation")
	_table.create_column(false, dbms, DataBase.DataType.BOOL, 1, "constructed")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "damage")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "special")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "layer")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "locked")
	
	_table = DataBase.Table.new("entity_material")
	_table.create_column(false, dbms, DataBase.DataType.FLOAT, 1, "weight")
	
	_table = DataBase.Table.new("mob")
	_table.create_column(false, dbms, DataBase.DataType.VECTOR2, 1, "position")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "entity_num")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "layer")

#func create_columns_terrain(_table):
	#create_columns_terrain_layer(_table, "_c")
	#create_columns_terrain_layer(_table, "_br")
	#create_columns_terrain_layer(_table, "_bl")
	#create_columns_terrain_layer(_table, "_tr")
	#create_columns_terrain_layer(_table, "_tl")
#
#func create_columns_terrain_layer(_table, str_quadrant):
	#_table.create_column(false, dbms, DataBase.DataType.VECTOR2I, 1, str("position", str_quadrant))
	#_table.create_column(false, dbms, DataBase.DataType.ARRAY, 48, str("array_data", str_quadrant))

func speech_activated():
	if quests_manager.is_visible_in_tree() or mold_window.is_visible_in_tree():
		return true
	if Input.is_action_just_pressed("mouse wheel down") or Input.is_action_just_pressed("mouse wheel up") or Input.is_action_just_pressed("left mouse button") or Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("move up") or Input.is_action_just_pressed("move down") or Input.is_action_just_pressed("move left") or Input.is_action_just_pressed("move right"):
		return true
	return false
