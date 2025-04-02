class_name RainParticles extends GPUParticles2D

@export var audio_stream_player2d: AudioStreamPlayer2D
@export var audio_stream_storm: AudioStream
@export var audio_stream_birds: AudioStream

@export var audio_stream_in_doors: Array[AudioStream]

var gravity_x: float = -1000
var degrees: float = 0
var currently_raining: bool = true
var in_door: bool = false
var current_sound_type: SoundType
enum SoundType{
	WIND,
	STORM,
	BIRDS,
	NULL,
}

func _ready() -> void:
	set_direction_of_rain()

func set_sound_type(sound_type: SoundType):
	if current_sound_type != sound_type:
		current_sound_type = sound_type
		if sound_type == SoundType.WIND:
			audio_stream_player2d.stream = audio_stream_in_doors[randi_range(0, audio_stream_in_doors.size()-1)]
		elif sound_type == SoundType.STORM:
			audio_stream_player2d.stream = audio_stream_storm
		elif sound_type == SoundType.BIRDS:
			audio_stream_player2d.stream = audio_stream_birds
		audio_stream_player2d.play()
		if sound_type == SoundType.NULL:
			audio_stream_player2d.stream = null
			audio_stream_player2d.stop()

func start_out_door_sfx():
	in_door = false
	if currently_raining:
		emitting = true
		set_sound_type(SoundType.STORM)
	else:
		set_sound_type(SoundType.BIRDS)

func random_indoor_sound():
	if in_door == true and currently_raining == true:
		set_sound_type(SoundType.WIND)
	elif in_door == true:
		set_sound_type(SoundType.NULL)

func start_in_door_sfx():
	in_door = true
	random_indoor_sound()
	emitting = false

func stop_rain():
	emitting = false
	currently_raining = false
	if in_door == false:
		# out doors no storm and birds sound
		if not audio_stream_player2d.stream == audio_stream_birds:
			set_sound_type(SoundType.BIRDS)
	else:# in doors no storm and no sound for now
		set_sound_type(SoundType.NULL)
	await get_tree().create_timer(20).timeout
	# restart rain after 20 sec if possible
	set_direction_of_rain()

func set_direction_of_rain():
	degrees = randf_range(-18, 18)
	if in_door == false:
		emitting = true
	currently_raining = true
	g_man.changes_manager.add_key_change("STOP", str(false))
	set_random()

func set_random():
	var calc_sinus = sin(deg_to_rad(degrees))
	if degrees < 0:
		degrees -= 5
	else:
		degrees += 5
	
	gravity_x += randf_range(0, 225) * calc_sinus
	gravity_x = clampf(gravity_x, -1500, 1500)
	
	set_rain_direction()
	g_man.changes_manager.add_key_change("rain", str(gravity_x, " ", degrees))
	if absf(gravity_x) < 35:
		g_man.changes_manager.add_key_change("STOP", str(true))
		stop_rain()
		return
	elif in_door == false:
		if not audio_stream_player2d.stream == audio_stream_storm:
			set_sound_type(SoundType.STORM)
	else:
		set_sound_type(SoundType.WIND)
	
	await get_tree().create_timer(15).timeout
	# change direction after 15 seconds
	set_random()

func set_rain_direction() -> void:
	var angle_degrees = (gravity_x / 1000) * 45
	process_material.angle_max = angle_degrees
	process_material.angle_min = angle_degrees
	process_material.gravity.x = gravity_x
	
	amount = clamp(absf(gravity_x) * 0.2, 50, 1200)
