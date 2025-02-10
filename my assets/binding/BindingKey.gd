class_name BindingKey extends Node

func _ready() -> void:
	label.text = Bindings.keys.find_key(index).replace("_", " ")

@warning_ignore("enum_variable_without_default")
@export var index: Bindings.keys
@export var label: Label
@export var button: Button
@export var default: bool = false

func _change_binding():
	g_man.bindings.change_binding(index, self)

func set_binding_label(text):
	button.text = text
