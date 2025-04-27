class_name BindingKey extends Node

func _ready() -> void:
	label.text = Bindings.keys.find_key(index).replace("_", " ")

@warning_ignore("enum_variable_without_default")
@export var index: Bindings.keys
@export var label: Label
@export var buttons: Array[Button]
# after app reset it has default value
@export var default: bool = false

var array_events: Array = [null, null, null]

func _change_binding_pri():
	if not default:
		g_man.bindings.change_binding(index, self)

func _change_binding_sec():
	if not default:
		g_man.bindings.change_binding(index, self, 1)

func _change_binding_ter():
	if not default:
		g_man.bindings.change_binding(index, self, 2)

func set_binding(i, event, text):
	for index_e in array_events.size():
		if array_events[index_e] and event and (array_events[index_e].as_text() == event.as_text() or array_events[index_e].as_text().replace(" (Physical)", "") == event.as_text()):
			buttons[index_e].text = "N/A"
	array_events[i] = event
	buttons[i].text = text

func _on_ui_pressed() -> void:
	g_man.main_menu._on_ui_pressed()


func _on_mouse_entered() -> void:
	g_man.main_menu._on_mouse_entered()
