class_name EnemyController extends Node2D

enum State{
	CHASE = 0, # chase the target
	RUN = 1, # run back in to the hole
	DRAG = 7, # dragging helpless bot
	RUN_AWAY = 2, ## run back in to the hole for 100% without helpless bot
	RETRIVE = 3, # retrieve bot in to the hole
	RETRIVE_DRAG = 8, # dragging bot away
	RETRIVE_AWAY = 4, ## run away without the bot
	BROKEN = 5, # don't do anything I'm broken
	BRING_MATS = 6 # bring mats
}

@export var cp_mob: CPMob
@export var movement: Movement
@export var agent: NavigationAgent2D
@export var timer: Timer

@export var robot_sfx_player: AudioStreamPlayer2D
@export var chase_sound: AudioStream
@export var run_away_sound: AudioStream

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
	if not movement.state == Movement.State.BROKEN and target and target is CPEnemy:
		if enemy_tunnel:
			enemy_tunnel[0].erase(target)
		target.controller.enemy_tunnel = null
		# my target is enemy bot so always run away as it's broken
		change_state(State.RUN_AWAY)
		target_set_null_target()
	# if helpless bot doesn't have nav_time have me as target and I'm not broken
	if (GameControl._helpless_bot and GameControl._helpless_bot.controller.target != self) and state != State.BROKEN and state == State.CHASE:
		change_state(State.RUN_AWAY)
		target_set_null_target()
	# if I'm currently retrieveing the bot and my time is up go away
	if not movement.state == Movement.State.BROKEN and (state == State.RETRIVE or state == State.BRING_MATS or state == State.DRAG or state == State.RETRIVE_DRAG):
		change_state(State.RUN_AWAY)
		target_set_null_target()

func _physics_process(_delta: float) -> void:
	# reset target always
	if is_instance_valid(target) and target is CPMob:
		target_position = target.global_position
	elif is_instance_valid(target) and target is Vector2:
		target_position = target
	else:# if 1 tunnel is closed go back as there's no target
		if state == State.CHASE or state == State.RUN_AWAY or state == State.DRAG:
			change_state(State.RUN_AWAY)
			target_position = starting_point
			target_set_null_target()
		elif state == State.RETRIVE or state == State.RETRIVE_AWAY or state == State.RETRIVE_DRAG:
			change_state(State.RETRIVE_AWAY)
			target_position = starting_point
			target_set_null_target()
		elif not state == State.BRING_MATS:
			return
	
	# wait till the enemy bot tries to retrieve the helpless bot
	if is_instance_valid(target) and target is CPHelplessBot:
		# target is cp_mob and not me
		if target.controller.target is CPEnemy and not target.controller.target == movement.body:
			return
	
	if state == State.BRING_MATS:
		for i in movement.body.get_slide_collision_count():
			var collide = movement.body.get_slide_collision(i)
			if collide:
				collide = collide.get_collider()
				if collide and collide.is_in_group("material"):
					collide.set_collision_layer_value(1, false)
					
					collide = collide.get_parent()
					collide.entity.destroy_me()
					collide.reparent(movement.body)
					collide.top_level = false
					collide.position = Vector2.ZERO
					change_state(State.RUN_AWAY)
					target_set_null_target()
					target_position = starting_point
	
	if target_position:
		agent.target_position = target_position
	else:
		return
	
	if agent.is_navigation_finished():
		return
	
	if target_position:
		agent_next_path_position()
	
	# change target's target
	if state == State.CHASE or state == State.RETRIVE or state == State.BRING_MATS:
		if is_instance_valid(target) and target is CPMob and global_position.distance_to(target.global_position) < 72:
			# get the bot back in to the hole
			if state == State.CHASE or state == State.BRING_MATS:
				if state == State.BRING_MATS:
					agent.avoidance_enabled = true
				change_state(State.DRAG)
			else:
				change_state(State.RETRIVE_DRAG)
			# modify target from current bot
			# first remove on other bot
			if is_instance_valid(target) and target is CPHelplessBot:
				if is_instance_valid(target.controller.target):
					if target.controller.target is CPEnemy:
						if not target.controller.target == movement.body:
							target.controller.target.controller.change_state(State.CHASE)
							target.controller.target.controller.target_set_null_target()
			target_set_null_target()
			# add me as current bot to retrive
			target.controller.target = movement.body
	
	# change target
	elif state == State.RUN or state == State.RUN_AWAY or state == State.RETRIVE_AWAY or state == State.BROKEN or state == State.DRAG or state == State.RETRIVE_DRAG:
		# get and return to it if it's too far
		if (state == State.DRAG or state == State.RETRIVE_DRAG) and target is CPMob and global_position.distance_to(target.global_position) > 80:
			if State.DRAG: # back to chase the helpless bot
				change_state(State.CHASE)
				target_set_null_target()
			else: # back to retrieve enemy bot
				change_state(State.RETRIVE)
				target_set_null_target()
		
		# go back to starting point DRAG = 7 || RETRIEVE_DRAG = 8
		elif not target_position == starting_point:
			target_position = starting_point
			agent_next_path_position()
		if global_position.distance_to(coords[1][0]/2) < 24:
			GameControl.turn_fake_tunnel_back(enemy_tunnel, state, target)
	# override
	movement.body.move_and_slide()

func agent_next_path_position():
	agent.target_position = target_position
	next_position = agent.get_next_path_position()
	direction = global_position.direction_to(next_position)
	
	avoidance()

func avoidance():
	if agent.avoidance_enabled:
		agent.set_velocity(direction)
	else:
		movement.direction = direction

var nav_dir

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	movement.direction = safe_velocity

func change_state(_state: State):
	state = _state
	
	# set audio for state
	if state == State.RUN or state == State.RUN_AWAY or state == State.RETRIVE_AWAY or state == State.DRAG or state == State.RETRIVE_DRAG:
		robot_sfx_player.stream = run_away_sound
		robot_sfx_player.play()
	elif state == State.CHASE or state == State.RETRIVE:
		robot_sfx_player.stream = chase_sound
		robot_sfx_player.play()
	# debugging state
	cp_mob.name_label.text = str(state)

func target_set_null_target():
	if is_instance_valid(target):
		if is_instance_valid(target.controller.target):
			if target.controller.target == movement.body:
				target.controller.set_null_target()

func set_null_target():
	target_position = target.global_position
