class_name FriendlyRobotsSpawn extends Node2D

@export var friendly_robot: PackedScene
@export var build_factory_point: Node2D
@export var timer_spawn_friendly: Timer

func _ready() -> void:
	timer_spawn_friendly.start()

func _on_spawn_friendly_timeout() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.target = build_factory_point
	friendly.armor = randf_range(8.0, 11.0)
	friendly.health = randf_range(20.0, 50.0)
