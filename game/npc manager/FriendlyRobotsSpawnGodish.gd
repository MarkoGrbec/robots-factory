class_name FriendlyRobotsSpawnGodish extends Node2D

@export var friendly_robot: PackedScene
@export var build_factory_point: Node2D
@export var timer_spawn_friendly: Timer

func _ready() -> void:
	g_man.friendly_robots_spawn_godish = self

func spawn_friendly() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.target = build_factory_point
	friendly.controller.close_to_target = 100
	friendly.controller.internal_state = FriendlyController.InternalState.ATTACK
	friendly.armor = randf_range(8.0, 11.0)
	friendly.health = randf_range(20.0, 50.0)

func spawn_friendly_armored() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.target = build_factory_point
	friendly.controller.close_to_target = 100
	friendly.controller.internal_state = FriendlyController.InternalState.ATTACK
	friendly.armor = randf_range(15.0, 30.0)
	friendly.health = randf_range(50.0, 100.0)
