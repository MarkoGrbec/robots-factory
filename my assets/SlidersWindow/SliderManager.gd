class_name SlidersManager extends Node
@export var time_slider: TextureProgressBar
@export var health_slider: TextureProgressBar
@export var stamina_slider: TextureProgressBar
@export var mana_slider: TextureProgressBar
@export var food_slider: TextureProgressBar

@export var audio_stream_player: AudioStreamPlayer
@export var timer: Timer
@export var timer_digesting: Timer

var dict_enum_slider__progress_bar: Dictionary[Enums.slider, TextureProgressBar]
var used_ttc
var is_playing: bool

const FRESH_GAIN_K: float = 7
const FOOD_DRAIN_WORKING: float = 0.001
const FOOD_DRAIN_RESTING: float = 0.05

func _ready() -> void:
	g_man.sliders_manager = self
	#get_parent().set_id_window(14, "sliders manager")
	dict_enum_slider__progress_bar[Enums.slider.time] = time_slider
	dict_enum_slider__progress_bar[Enums.slider.health] = health_slider
	dict_enum_slider__progress_bar[Enums.slider.stamina] = stamina_slider
	dict_enum_slider__progress_bar[Enums.slider.mana] = mana_slider
	dict_enum_slider__progress_bar[Enums.slider.food] = food_slider
	audio_stream_player.finished.connect(finished_playback)
	timer_digesting.timeout.connect(digesting)

func open_window():
	get_parent().show()

func close_window():
	get_parent().hide()

func slider_add_value(type: Enums.slider, value):
	var slider:TextureProgressBar = dict_enum_slider__progress_bar.get(type)
	if slider:
		slider.value += value
		return slider.value

func slider_change_value(type: Enums.slider, value):
	var slider:TextureProgressBar = dict_enum_slider__progress_bar.get(type)
	if slider:
		slider.value = value

func finished_playback():
	if waiting_work and not waiting_work[0].one_shot:
		if waiting_work[0].time_start + waiting_work[0].time_to_complete > Time.get_unix_time_from_system() + waiting_work[0].delay_sound:
			# delay between sounds
			await get_tree().create_timer(waiting_work[0].delay_sound).timeout
			# while we work if we work
			if waiting_work:
				#is_playing = false
				if waiting_work[0].working_sound and time_slider.value < 100 or waiting_work[0].is_sound_on_end:
					audio_stream_player.stream = waiting_work[0].working_sound
					if not audio_stream_player.playing:
						audio_stream_player.play()
					#is_playing = true
				#else:
					#finished_playback()

var waiting_work = []

#region food
func food_drain(food):
	food_slider.value -= food

func start_digesting():
	if timer_digesting.is_stopped():
		timer_digesting.start()

## call to server to digest some food
func digesting():
	if g_man.local_network_node and g_man.local_network_node.net_dp_node:
		g_man.local_network_node.net_dp_node.cmd_digest.rpc_id(1, food_slider.value)
## call back from server
func digested_energy(energy):
	food_slider.value += energy
	#if energy == 0:
		#stop_digesting()
#endregion food
#region sliders
func start_working():
	if waiting_work:
		used_ttc = waiting_work[0].start_of_ttc()
		# almost finished work we stop sound before the end 5%
		timer.start(waiting_work[0].time_to_complete - waiting_work[0].time_to_complete * 0.05)
		await timer.timeout
		audio_stream_player.stop()

func resting(delta):
	# we add stamina depending how fresh you are
	var freshness = (stamina_slider.value * 0.01)
	stamina_slider.value += freshness * FRESH_GAIN_K * delta
	stamina_slider.value = clampf(stamina_slider.value, 20, 100)
	food_drain((1 - freshness + FOOD_DRAIN_RESTING) * delta)
#endregion sliders

func working(delta):
	# we reduce the value of stamina constantly depending on hard work and how exausted you are
	var hard_work: float = (waiting_work[0].time_to_complete + (1 - stamina_slider.value * 0.01)) * delta
	stamina_slider.value -= hard_work * waiting_work[0].hard
	stamina_slider.value = clampf(stamina_slider.value, 20, 100)
	food_drain(hard_work * FOOD_DRAIN_WORKING)
	# we set working slider value to 100
	time_slider.value = ((Time.get_unix_time_from_system() - waiting_work[0].time_start) / waiting_work[0].time_to_complete) * 100
	# if we have been working on it enough time
	if waiting_work[0].time_start + waiting_work[0].time_to_complete < Time.get_unix_time_from_system():
		# work is finished
		complete()
		# check for work integrity
		while true:
			if waiting_work.size() > 0:
				# work on this one
				if waiting_work[0].check():
					break
				# remove this one it's integrity failed
				waiting_work.pop_front().stop()
			# no work any longer
			else:
				break
		# new work is being set
		if waiting_work.size() > 0:
			waiting_work[0].time_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	# we check if anything is working on
	if waiting_work:
		working(delta)
	else:
		resting(delta)
	if Input.is_action_pressed("stop work"):
		remove_work()

func add_work(i_time_complete):
	waiting_work.push_back(i_time_complete)
	# if it starts first
	i_time_complete.time_start = Time.get_unix_time_from_system()
	i_time_complete.set_complete_time()
	if waiting_work.size() == 1:
		_stamina(i_time_complete)
		if i_time_complete.working_sound:
			audio_stream_player.stream = i_time_complete.working_sound
			if not audio_stream_player.playing:
				play_sound()
		else:
			audio_stream_player.stream = null
			printerr("no working sound on: ", i_time_complete.to_string_name())
		start_working()

## we calculate time to complete depending on stamina
func _stamina(i_time_complete):
	i_time_complete.time_to_complete /= stamina_slider.value * 0.03
	# 0.01 sec is minumum 30 sec is maximum
	i_time_complete.time_to_complete = clampf(i_time_complete.time_to_complete, 0.01, 30)


func complete():
	waiting_work[0].complete()
	if waiting_work[0].is_sound_on_end:
		if waiting_work[0].working_sound:
			var before_sound = audio_stream_player.stream
			audio_stream_player.stream = waiting_work[0].working_sound
			if not audio_stream_player.playing or (not audio_stream_player.stream == before_sound):
				play_sound()
	# remove current waiting work
	waiting_work.pop_front().stop()
	if waiting_work:
		_stamina(waiting_work[0])
		start_working()
		if not audio_stream_player.playing:
			play_sound()

func play_sound():
	audio_stream_player.stop()
	if waiting_work and waiting_work[0].working_sound:
		await get_tree().create_timer(waiting_work[0].start_delay_sound).timeout
		if waiting_work and waiting_work[0].working_sound:
			audio_stream_player.stream = waiting_work[0].working_sound
			audio_stream_player.play()

func remove_work():
	if not used_ttc:
		if waiting_work:
			audio_stream_player.stream = null
			audio_stream_player.stop()
			waiting_work.pop_front().stop()
			if waiting_work:
				start_working()
		if not waiting_work:
			time_slider.value = 100
