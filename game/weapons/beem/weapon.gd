class_name Weapon extends Node2D

@export var entity_num: Enums.Esprite

signal hit_body

@export var activated: bool = true

@export var line_2d: Line2D
@export var ray_cast: RayCast2D
@export var casting_particles: GPUParticles2D
@export var beem_particles: GPUParticles2D
@export var collision_particles: GPUParticles2D

var is_casting := false

@export var distance: float = 75
@export var battery_constumption: float = 5
var tween

var target

func _ready() -> void:
	set_physics_process(false)
	line_2d.points[1] = to_local(line_2d.global_position)

func update_ray():
	var target_position
	if not target:
		target_position = get_global_mouse_position()
	else:
		target_position = target.global_position
	look_at(target_position)
	
	line_2d.points[0] = to_local(line_2d.global_position)
	var cast_point = to_local(line_2d.global_position + line_2d.global_position.direction_to(ray_cast.global_position) * distance)
	ray_cast.target_position.x = distance
	
	ray_cast.force_raycast_update()
	return cast_point

func _physics_process(_delta: float) -> void:
	var cast_point = update_ray()
	
	collision_particles.emitting = ray_cast.is_colliding()
	
	if ray_cast.is_colliding():
		cast_point = to_local(ray_cast.get_collision_point())
		collision_particles.global_rotation = ray_cast.get_collision_normal().angle()
		collision_particles.position = cast_point
	
	line_2d.points[1] = cast_point
	
	beem_particles.position = cast_point * 0.5
	var a: ParticleProcessMaterial = beem_particles.process_material
	a.emission_box_extents.x = cast_point.length() * 0.5
	beem_particles.amount = int (cast_point.length() * 0.075)

func fire_weapon(fire: bool = true) -> void:
	if activated:
		#if event.is_action_pressed("fire"):
		if fire:
			set_is_casting(true)
			await get_tree().create_timer(0.15).timeout
		#else:
		#elif event.is_action_released("fire"):
			set_is_casting(false)

func set_is_casting(cast):
	is_casting = cast
	set_physics_process(is_casting)
	
	beem_particles.emitting = is_casting
	casting_particles.emitting = is_casting
	if is_casting:
		appear()
	else:
		disappear()

func appear():
	update_ray()
	
	if ray_cast.is_colliding():
		hit_body.emit(ray_cast.get_collider())
	tween = create_tween()
	tween.tween_property(line_2d, "width", 6, 0.15)

func disappear():
	tween.stop()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0, 0.1)
	collision_particles.emitting = false
