class_name AudioBusVolume extends Node

@export var h_scroll_bar: HScrollBar

@export var volume_name: String = "music"
@export var volume_name_node: Label

@export var db_name: String
@export var bus_name: String

func _ready() -> void:
	volume_name_node.text = volume_name
	load_audio()

func _volume_changed(value: float) -> void:
	change_save_bus_level(value)

func load_audio():
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	var volume = AudioServer.get_bus_volume_db(audio_bus_index)
	volume = DataBase.select(false, g_man.dbms, "audio", db_name, 1, volume)
	AudioServer.set_bus_volume_db(audio_bus_index, volume)
	h_scroll_bar.value = volume

func change_save_bus_level(value):
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(audio_bus_index, value)
	DataBase.insert(false, g_man.dbms, "audio", db_name, 1, float(value))
