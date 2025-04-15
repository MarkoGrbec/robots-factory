class_name EnemyTurret extends StaticBody2D

enum State{
	IDLE,
	ATTACKING
}
enum StationType{
	MACHINE_GUN = 0,
	CANNON = 1,
	ROCKET_LAUNCHER = 2
}
enum Station{
	NONE = -1,
	FIRST = 0,
	SECOND = 1,
	THIRD = 2
}

@export var weapon_sprite_2d: Sprite2D
@export var weapon_sprites: Array[Texture2D]
@export var bullet: Array[Texture2D]
@export var bullet_sound: Array[AudioStream]
@export var bullet_impact_sound: Array[AudioStream]
@export var master_audio_stream_player: MasterAudioStreamPlayer2D
@export var attack_timer: Timer

@export var bullet_scene: PackedScene

@export var fire_speed: Array[PackedFloat32Array]
@export var station_damage: Array[float]
@export var station_type = StationType.MACHINE_GUN
@export var station: Station = Station.NONE

@export var armor: Array[float]
@export var health: float = 10
var array_bodys_to_attack: Array[Node2D]

var state: State = State.IDLE


var experience: int = 0

var reset_timer: float = 0

func _ready() -> void:
	reset_station()
	upgrade_fire_station()

func attack(body) -> void:
	array_bodys_to_attack.push_back(body)

func stop_attack(body) -> void:
	array_bodys_to_attack.erase(body)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("friendly") and not body.controller.state == FriendlyController.State.BROKEN:
		attack(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("friendly"):
		stop_attack(body)

func _process(_delta: float) -> void:
	if state == State.IDLE and array_bodys_to_attack:
		state = State.ATTACKING
		if station == Station.NONE:
			await get_tree().create_timer(5).timeout
			upgrade_fire_station()
			return
		attack_at()
	elif not array_bodys_to_attack:
		state = State.IDLE
		attack_timer.stop()
	var target = first_target()
	if target:
		look_at_target(target)

func first_target():
	for body in array_bodys_to_attack:
		if body is CPFriendly or body is CPPlayer:
			if not body.controller.state == FriendlyController.State.BROKEN:
				return body

func look_at_target(body: Node2D):
	weapon_sprite_2d.look_at(body.global_position)
	weapon_sprite_2d.rotate(deg_to_rad(90))

func attack_at() -> void:
	attack_timer.start(fire_speed[station_type][station])

func shoot():
	var target = first_target()
	if target:
		var _bullet: Node2D = bullet_scene.instantiate()
		if station == Station.FIRST:
			master_audio_stream_player.sample_audio_player_to_duplicate.pitch_scale = 1
		if station == Station.SECOND:
			master_audio_stream_player.sample_audio_player_to_duplicate.pitch_scale = 1.5
		if station == Station.THIRD:
			if station_type == StationType.CANNON:
				master_audio_stream_player.sample_audio_player_to_duplicate.pitch_scale = 0.5
			else:
				master_audio_stream_player.sample_audio_player_to_duplicate.pitch_scale = 2
		master_audio_stream_player.add_sound_to_play(bullet_sound[station_type])
		
		add_child(_bullet)
		_bullet.set_bullet_texture(bullet[station_type], self)
		_bullet.look_at(target.global_position)

func upgrade_experience():
	experience += 1
	if experience > 3 * (station_type + 1):
		experience = 0
		upgrade_fire_station()

func upgrade_fire_station():
	if station < Station.THIRD and reset_timer + 2000 < Time.get_ticks_msec():
		@warning_ignore("int_as_enum_without_cast")
		station += 1
		weapon_sprite_2d.texture = weapon_sprites[3 * station_type + station]
		attack_at()

func reset_station():
	station = Station.NONE
	state = State.IDLE
	weapon_sprite_2d.texture = null
	health = 100
	attack_timer.stop()
	reset_timer = Time.get_ticks_msec()

func get_hit(damage):
	damage -= armor[station_type]
	health -= clampf(damage, 0, INF)
	if health < 0:
		reset_station()
