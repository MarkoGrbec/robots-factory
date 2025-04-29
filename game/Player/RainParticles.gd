class_name RainParticles extends GPUParticles2D

@export var rain_audio_stream_player2d: AudioStreamPlayer2D
@export var audio_stream_storm: AudioStream
@export var audio_stream_birds: AudioStream

@export var audio_stream_in_doors: Array[AudioStream]

@export var rain_effect_shader: Sprite2D
@export_group("thunder")
@export var timer_thunder: Timer
@export var thunder_color_rect: ColorRect
@export var flash_texture_rect: TextureRect
@export var thunder_audio_stream_player2d: MasterAudioStreamPlayer2D
@export var thunder_animation_player: AnimationPlayer
@export var thunder_audio_stream: Array[AudioStream]

## restart rain when it's dry calculate it
const RESTART_RAIN: float = 60
## in how much time direction slightly changes
const CHANGE_DIRECTION: float = 15.0
## % / 2 not to double strike ## bigger number less chance to not double strike 0.97 is pretty common to strike double times or even three times
const K_NOT_DOUBLE_STRIKE: float = 0.98

var double_strike: float = 1.0
var position_strike: float = 1.0

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
	if current_sound_type != sound_type or sound_type == SoundType.WIND or not rain_audio_stream_player2d.playing:
		if sound_type == SoundType.WIND and not current_sound_type == sound_type:
			rain_audio_stream_player2d.stream = audio_stream_in_doors[randi_range(0, audio_stream_in_doors.size()-1)]
		elif sound_type == SoundType.STORM:
			rain_audio_stream_player2d.stream = audio_stream_storm
		elif sound_type == SoundType.BIRDS:
			rain_audio_stream_player2d.stream = audio_stream_birds
		if not rain_audio_stream_player2d.playing:
			rain_audio_stream_player2d.play()
		if sound_type == SoundType.NULL:
			rain_audio_stream_player2d.stream = null
			rain_audio_stream_player2d.stop()
		
		current_sound_type = sound_type

func start_out_door_sfx():
	in_door = false
	if currently_raining:
		emitting = true
		if rain_effect_shader:
			rain_effect_shader.show()
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
	if rain_effect_shader:
		rain_effect_shader.hide()

func stop_rain():
	emitting = false
	if rain_effect_shader:
		rain_effect_shader.hide()
	currently_raining = false
	if in_door == false:
		# out doors no storm and birds sound
		if not rain_audio_stream_player2d.stream == audio_stream_birds:
			set_sound_type(SoundType.BIRDS)
	else:# in doors no storm and no sound for now
		set_sound_type(SoundType.NULL)
	await get_tree().create_timer(RESTART_RAIN).timeout
	# restart rain after 20 sec if possible
	set_direction_of_rain()

func set_direction_of_rain():
	degrees = randf_range(-18, 18)
	if in_door == false:
		emitting = true
		if rain_effect_shader:
			rain_effect_shader.show()
	currently_raining = true
	#g_man.changes_manager.add_key_change("STOP", str(false))
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
	#g_man.changes_manager.add_key_change("rain", str(gravity_x, " ", degrees))
	if absf(gravity_x) < 35:
		#g_man.changes_manager.add_key_change("STOP", str(true))
		stop_rain()
		return
	elif in_door == false:
		if not rain_audio_stream_player2d.stream == audio_stream_storm:
			set_sound_type(SoundType.STORM)
	else:
		set_sound_type(SoundType.WIND)
	
	await get_tree().create_timer(CHANGE_DIRECTION).timeout
	# change direction after 15 seconds
	set_random()

func set_rain_direction() -> void:
	var angle_degrees = (gravity_x / 1000) * 45
	process_material.angle_max = angle_degrees
	process_material.angle_min = angle_degrees
	process_material.gravity.x = gravity_x
	
	amount = clamp(absf(gravity_x) * 0.2, 50, 1200)

func thunder_strike():
	# pause
	timer_thunder.wait_time = 3
	
	double_strike = randf_range(0.5, 1)
	
	var k_double_strike = abs(gravity_x) * 0.0001
	# double strike ## bigger (0.98) less % to strike double
	if not double_strike > K_NOT_DOUBLE_STRIKE - k_double_strike:
		double_strike = 1
		position_strike = randf_range(0, 1)
	
	thunder_color_rect.material.set_shader_parameter("position", position_strike)
	thunder_color_rect.material.set_shader_parameter("time", float(Time.get_ticks_msec()) / 1000)
	# play thunder
	if currently_raining and in_door == false:
		thunder_color_rect.show()
		flash_texture_rect.show()
		thunder_audio_stream_player2d.add_sound_to_play( thunder_audio_stream[randi_range(0, thunder_audio_stream.size() -1)] )
	else:
		thunder_color_rect.hide()
		flash_texture_rect.hide()
	
	thunder_animation_player.play("ThunderStrike", -1, 1.0 / double_strike)
	await get_tree().create_timer(0.2 * double_strike).timeout
	thunder_color_rect.hide()
	
	if double_strike != 1:
		# one thunder after another
		timer_thunder.start(0.02)
	else:
		# time between thnders
		# around 1 per 2 minutes on strong storm
		var max_time = (1500 - abs(gravity_x)) * 0.2
		timer_thunder.start(randf_range(15, max_time ))
		# debug thunder
		#timer_thunder.start(2)
