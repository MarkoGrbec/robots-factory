class_name CPHelplessBot extends CPMob

enum State{
	CHIPS = 0,
	
}

var state: State
@export var controller: HelplessBotController
@export var visuals: Visuals

func _ready() -> void:
	GameControl.set_helpless_bot(self)
	var quest_object = mp.get_quest_object(7)
	if quest_object:
		visuals.color_poligons(quest_object.color)

func _on_mouse_entered() -> void:
	if not g_man.wheel():
		g_man.camera.input_active = -3


func _on_mouse_exited() -> void:
	g_man.camera.input_active = 0

func _unhandled_input(event: InputEvent) -> void:
	if g_man.camera.input_active is int and g_man.camera.input_active == -3:
		if event is InputEventMouseButton:
			if event.is_action_pressed("select"):
				pass
