class_name StatsLabels extends Control

enum TypeLabel{
	ARMOR_STRENGTH = 0,
	WEAPON_STRENGTH = 1,
	WEAPON_DISTANCE = 2,
	BATTERY_CONSTUMPTION = 3,
}

@export var labels: Array[Label]

func _ready() -> void:
	g_man.stats_labels = self

func set_label(type_label: TypeLabel, value):
	labels[type_label].text = str(int(value))

func open_close_window():
	if is_visible_in_tree():
		hide()
		g_man.sliders_manager.close_window()
	else:
		show()
		g_man.sliders_manager.open_window()
