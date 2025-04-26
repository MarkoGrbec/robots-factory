extends Node2D

@export var sprite: Sprite2D
@export var audio_stream_2d: AudioStreamPlayer2D
@export var explosion: Node2D
var _enemy_turret: EnemyTurret

func set_bullet_texture(texture, enemy_turret: EnemyTurret):
	sprite.texture = texture
	_enemy_turret = enemy_turret

func _process(delta: float) -> void:
	global_position = global_transform * Vector2(delta * 800, 0)

func _on_projectile_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("friendly"):
		_enemy_turret.upgrade_experience()
	if body != _enemy_turret:
		if body.is_in_group("friendly") or body.is_in_group("enemy"):
			var damage = _enemy_turret.station_damage[_enemy_turret.station_type]
			if _enemy_turret.station_type == EnemyTurret.StationType.CANNON and _enemy_turret.station == EnemyTurret.Station.THIRD:
				damage *= 2.5
			body.get_hit(damage)
			if body is CPFriendly:
				if body.controller.state == FriendlyController.State.BROKEN:
					_enemy_turret.stop_attack(body)
		# destroy the entity_sprite2d_in_world and it's entity
		if body.is_in_group("material"):
			body.get_parent().destroy_me()
		if body.is_in_group("factory"):
			var damage = _enemy_turret.station_damage[_enemy_turret.station_type]
			if _enemy_turret.station_type == EnemyTurret.StationType.CANNON and _enemy_turret.station == EnemyTurret.Station.THIRD:
				damage *= 2.5
			body.get_hit(damage)
		destroy_me()

func destroy_me():
	audio_stream_2d.stream = _enemy_turret.bullet_impact_sound[_enemy_turret.station_type]
	audio_stream_2d.volume_db = 4.0
	audio_stream_2d.play()
	set_process(false)
	if _enemy_turret.station_type == EnemyTurret.StationType.ROCKET_LAUNCHER:
		explosion.start_explosion()
	sprite.hide()
	await audio_stream_2d.finished
	queue_free()
