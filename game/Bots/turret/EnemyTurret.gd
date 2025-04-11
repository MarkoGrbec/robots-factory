class_name EnemyTurret extends Node

enum State{
	IDLE,
	ATTACKING
}

@export var weapon_sprite_2d: Sprite2D
@export var weapon_sprites: Array[Texture2D]
@export var bullet: Texture2D
@export var attack_timer: Timer

@export var bullet_scene: PackedScene

var array_bodys_to_attack: Array[Node2D]

var state: State = State.IDLE

func attack(body) -> void:
	array_bodys_to_attack.push_back(body)

func stop_attack(body) -> void:
	array_bodys_to_attack.erase(body)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("friendly"):
		attack(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("friendly"):
		stop_attack(body)

func _process(_delta: float) -> void:
	if state == State.IDLE and array_bodys_to_attack:
		state = State.ATTACKING
		attack_at(array_bodys_to_attack[0])
	elif not array_bodys_to_attack:
		state = State.IDLE
		attack_timer.stop()

func attack_at(body: Node2D) -> void:
	weapon_sprite_2d.look_at(body.global_position)
	weapon_sprite_2d.rotate(deg_to_rad(90))
	attack_timer.start(1)

func shoot():
	if array_bodys_to_attack:
		var _bullet: Sprite2D = bullet_scene.instantiate()
		add_child(_bullet)
		_bullet.texture = bullet
		_bullet.look_at(array_bodys_to_attack[0].global_position)
