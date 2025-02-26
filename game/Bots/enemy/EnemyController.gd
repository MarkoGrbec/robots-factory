class_name EnemyController extends Node2D

enum State{
	CHASE,
	RUN,
	RUN_AWAY,
	RETRIVE,
	RETRIVE_AWAY,
	BROKEN,
	BRING_MATS
}

@export var movement: Movement
@export var agent: NavigationAgent2D
@export var timer: Timer

var state: State = State.CHASE
var target
var direction: Vector2 = Vector2.ZERO
var starting_point: Vector2
## [Vector2i, [position, id_tile]]
var coords
## [[bots], coords]
var enemy_tunnel

var next_position: Vector2
var avoid_direction: Vector2

var target_position


var nav_time = 0
var nav_angle: float = 90
var nav_int: int = 0
var nav_count: int = 0

func set_timer(time = -1) -> void:
	timer.timeout.connect(run_away)
	timer.start(time)

func run_away():
	if target and target is CPEnemy:
		if enemy_tunnel:
			enemy_tunnel[0].erase(target)
		target.controller.enemy_tunnel = null
		# my target is enemy bot so always run away as it's broken
		state = State.RUN_AWAY
	
	# if helpless bot doen'nav_time have me as target and I'm not broken
	if (GameControl._helpless_bot and GameControl._helpless_bot.controller.target != self) and state != State.BROKEN and state == State.CHASE:
		state = State.RUN_AWAY

func _physics_process(_delta: float) -> void:
	# set target
	if is_instance_valid(target) and target is CPMob:
		target_position = target.global_position
		agent.target_position = target_position
	elif is_instance_valid(target) and target is Vector2:
		target_position = target
		agent.target_position = target_position
		#if agent.is_navigation_finished():
			#return
	else:# if 1 tunnel is closed go back as there's no target
		if state == State.CHASE or state == State.RUN_AWAY:
			state = State.RUN_AWAY
			target_position = starting_point
		elif state == State.RETRIVE or state == State.RETRIVE_AWAY:
			state = State.RETRIVE_AWAY
			target_position = starting_point
		else:
			return
	
	if state == State.BRING_MATS:
		for i in movement.body.get_slide_collision_count():
			var collide = movement.body.get_slide_collision(i)
			if collide:
				collide = collide.get_collider()
				if collide.is_in_group("material"):
					collide.set_collision_layer_value(1, false)
					
					collide = collide.get_parent()
					collide.entity.destroy_me()
					collide.reparent(movement.body)
					collide.top_level = false
					collide.position = Vector2.ZERO
					state = State.RUN_AWAY
					target_position = starting_point
	
	
	agent_next_path_position()
	
	# change target's target
	if state == State.CHASE or state == State.RETRIVE or state == State.BRING_MATS:
		if target is CPMob and global_position.distance_to(target.global_position) < 72:
			if state == State.CHASE or state == State.BRING_MATS:
				if state == State.BRING_MATS:
					agent.avoidance_enabled = true
				state = State.RUN
			else:
				state = State.RETRIVE_AWAY
			target.controller.target = movement.body
	# move towards target
	elif state == State.RUN or state == State.RUN_AWAY or state == State.RETRIVE_AWAY or state == State.BROKEN:
		# get and return to it if it's too far
		if state == State.RUN and target is CPMob and global_position.distance_to(target.global_position) > 80:
			if State.RETRIVE_AWAY:
				state = State.RETRIVE
			else:
				state = State.CHASE
		# go back to starting point
		if not target_position == starting_point:
			target_position = starting_point
			agent_next_path_position()
		
		if global_position.distance_to(coords[1][0]/2) < 24:
			GameControl.turn_fake_tunnel_back(enemy_tunnel, state)
	# override
	movement.direction = direction
	movement.body.move_and_slide()

func agent_next_path_position():
	agent.target_position = target_position
	next_position = agent.get_next_path_position()
	if not nav_dir:
		direction = global_position.direction_to(next_position)
	else:
		direction = nav_dir
	#avoidance()

func avoidance():
	if agent.avoidance_enabled:
		agent.set_velocity(direction)
	else:
		movement.direction = direction

var nav_dir

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if nav_time + 0.75 < Time.get_unix_time_from_system():
		nav_dir = safe_velocity
		if nav_dir:
			agent.target_position = global_position + safe_velocity
			next_position = agent.get_next_path_position()
			direction = global_position.direction_to(next_position)
			nav_count = 0
		if not nav_dir:
			if nav_count > 1:
				#g_man.changes_manager.add_change("dir reset")
				nav_count = 0
				nav_int = 0
			nav_count += 1
			
			agent.target_position = target_position
			next_position = agent.get_next_path_position()
			direction = global_position.direction_to(next_position)
			nav_dir = direction
			nav_time = Time.get_unix_time_from_system()
			return
		var angle = rad_to_deg(movement.direction.angle_to(safe_velocity))
		if nav_int < 15:
			#g_man.changes_manager.add_key_change("nav: ", str("nav int: ", nav_int, " angle: ", angle))
			rotate_angle(nav_angle, 1)
		elif angle > 0.01:
			rotate_angle(-100)
		elif angle < -0.01:
			rotate_angle(+100)

func rotate_angle(ang, i = 0):
	if i:
		nav_int += i
	else:
		nav_int = i
	nav_angle = ang
	nav_dir = direction.rotated(deg_to_rad(nav_angle))
	nav_time = Time.get_unix_time_from_system()
