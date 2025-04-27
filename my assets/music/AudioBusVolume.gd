class_name AudioBusVolume extends Node

@export var audio_stream_sample: AudioStream
@export var audio_player: AudioStreamPlayer
@export var stop_sound_timer: Timer

@export var h_scroll_bar: HScrollBar

@export var volume_name: String = "music"
@export var volume_name_node: Label

@export var db_name: String
@export var bus_name: String
var loading_audio_time: float
func _ready() -> void:
	volume_name_node.text = volume_name
	audio_player.stream = audio_stream_sample
	load_audio()

func _volume_changed(value: float) -> void:
	change_save_bus_level(value)
	stop_sound_timer.start(2.5)
	# if it's later than 1 sec after loading and not playing
	if Time.get_ticks_msec() - loading_audio_time > 1500 and not audio_player.playing:
		audio_player.play()
		await stop_sound_timer.timeout
		audio_player.stop()

func load_audio():
	loading_audio_time = Time.get_ticks_msec()
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	var volume = AudioServer.get_bus_volume_db(audio_bus_index)
	volume = DataBase.select(false, g_man.dbms, "audio", db_name, 1, volume)
	AudioServer.set_bus_volume_db(audio_bus_index, volume)
	h_scroll_bar.value = volume

func change_save_bus_level(value):
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(audio_bus_index, value)
	DataBase.insert(false, g_man.dbms, "audio", db_name, 1, float(value))


func _on_ui_pressed() -> void:
	g_man.main_menu._on_ui_pressed()


func _on_mouse_entered() -> void:
	g_man.main_menu._on_mouse_entered()
