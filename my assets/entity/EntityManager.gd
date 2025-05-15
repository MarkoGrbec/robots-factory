class_name EntityManager extends Node2D

@export var array_layers: Array[Node2D]
@export var navigation_region_2d: NavigationRegion2D

enum Convert{
	CLAY = 13,
	DIRT = 11,
	GRASS = 11,
	ROCK = 10,
	SOFT_ROCK = 10,
	SOFT_ROCK_UNDERGROUND = 10,
}

func _ready() -> void:
	g_man.entity_manager = self

var bakers_queue: int = 0

func bake():
	#await get_tree().process_frame
	if navigation_region_2d.is_baking():
		bakers_queue += 1
		if bakers_queue > 1:
			return
		await navigation_region_2d.bake_finished
		bakers_queue = 0
	navigation_region_2d.bake_navigation_polygon()

func create_entity_from_scratch(entity_num: Enums.Esprite, _global_position: Vector2):
	# create world sprite and position it
	var sprite_node: EntitySpriteWorld = mp.create_me(Enums.Esprite.sprite_2d_world)
	reparent_to_layer(sprite_node, g_man.tile_map_layers.active_layer)
	sprite_node.global_position = _global_position
	# change texture and add entity
	var entity_object = mp.get_item_object(entity_num)
	sprite_node.sprite.texture = entity_object.texture
	sprite_node.entity = Entity.create_from_scratch(entity_num, true, false, true)
	save_config(sprite_node.entity, _global_position, g_man.tile_map_layers.active_layer)

func create_entity_in_world(id: int, mouse_global_position: Vector2):
	# convert
	if id == TileMapLayers.Tile.DIRT or id == TileMapLayers.Tile.GRASS:
		id = Convert.DIRT
	elif id == TileMapLayers.Tile.CLAY:
		id = Convert.CLAY
	elif id == TileMapLayers.Tile.ROCK or id == TileMapLayers.Tile.SOFT_ROCK or id == TileMapLayers.Tile.SOFT_ROCK_UNDERGROUND:
		id = Convert.ROCK
	else:
		printerr(TileMapLayers.Tile.find_key(id), " doesn't exist")
		return
	create_entity_from_scratch(id, mouse_global_position)


func drop_entity_in_world(entity: Entity, mouse_global_position: Vector2, layer):
	var sprite_node: EntitySpriteWorld = mp.create_me(Enums.Esprite.sprite_2d_world)
	reparent_to_layer(sprite_node, layer)
	sprite_node.global_position = mouse_global_position
	# change texture and add entity
	var entity_object = mp.get_item_object(entity.entity_num)
	sprite_node.sprite.texture = entity_object.texture
	sprite_node.entity = entity
	save_config(entity, mouse_global_position, layer)

func save_config(entity, mouse_global_position, layer):
	entity.pos = mouse_global_position
	entity.save_position_rotation()
	entity.special = 0
	entity.save_special()
	entity.layer = layer
	entity.save_layer()

func add_child_to_layer(child, layer):
	add_child(child)
	reparent_to_layer(child, layer)

func reparent_to_layer(child, layer = g_man.tile_map_layers.active_layer):
	child.reparent(array_layers[layer])
	if layer == 0:
		bake()

func activate_layer(active_layer):
	for i in array_layers.size():
		if i != active_layer:
			activate(array_layers[i], false)
		else:
			activate(array_layers[i], true)

func add_child_to_dragging(child):
	g_man.dragging_node.add_child(child)

func reparent_dragging(child: Node2D):
	child.reparent(g_man.dragging_node)

# activate deactivate layers and sprites within
static func activate(layer, active: bool):
	if active:
		layer.show()
	else:
		if not layer.is_visible_in_tree():
			return
		layer.hide()
	var children = layer.get_children()
	for child in children:
		child.static_body_2d.set_collision_layer_value(1, active)

func destroy_all_entities():
	for layer in array_layers:
		var children = layer.get_children()
		for child in children:
			if is_instance_valid(child):
				if child.has_meta("entity"):
					if is_instance_valid(child.entity):
						var entity: Entity = child.entity
						entity.partly_loaded = 0
				child.queue_free()
	for node in g_man.dragging_node.get_children():
		var entity: Entity = node.entity
		entity.partly_loaded = 0
		node.queue_free()
