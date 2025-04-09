class_name CPOrganicRobot extends CPQuest

var convinced: bool = false
var philosopher: bool = false

@export var believe: TextureRect
var gradient_tex: GradientTexture1D

func _ready() -> void:
	believe.texture = believe.texture.duplicate(true)
	gradient_tex = believe.texture

func set_gradient_believe(array_believe):
	gradient_tex.gradient.offsets[0] = array_believe[0]
	gradient_tex.gradient.offsets[1] = array_believe[1]

func quest_believe(array_believe):
	set_gradient_believe(array_believe)
	
	if g_man.user.believe_in_god:
		convince(array_believe[0] > 0.95)
	else:
		convince(array_believe[1] < 0.05)

func convince(value):
	# johnny
	var server_quest: ServerQuest = QuestsManager.get_server_quest(11)
	if g_man.user.believe_in_god == false:
		# sophie
		server_quest = QuestsManager.get_server_quest(12)
	
	if value:
		if g_man.user.believe_in_god and convinced == false:
			server_quest.mission_completing({"convince" = Enums.Esprite.mob_organic_robot})
			convinced = true
		if g_man.user.believe_in_god == false and philosopher == false:
			server_quest.mission_completing({"convince" = Enums.Esprite.mob_organic_robot})
			philosopher = true
	else:
		if g_man.user.believe_in_god and convinced:
			server_quest.mission_failing_quest({"convince" = Enums.Esprite.mob_organic_robot})
			convinced = false
		if g_man.user.believe_in_god == false and philosopher:
			server_quest.mission_failing_quest({"convince" = Enums.Esprite.mob_organic_robot})
			philosopher = false
	var self_server_quest: ServerQuest = QuestsManager.get_server_quest(quest_index)
	self_server_quest.save_believe()

func succeed_old_basis(_success_old_basis__qq_index):
	pass
