class_name OrganicRobot extends CPQuest

var convinced: bool = false
var philosopher: bool = false

@export var believe: TextureRect
var gradient_tex: GradientTexture1D

func _ready() -> void:
	believe.texture = believe.texture.duplicate(true)
	gradient_tex = believe.texture

func quest_believe(array_believe):
	gradient_tex.gradient.offsets[0] = array_believe[0]
	gradient_tex.gradient.offsets[1] = array_believe[1]
	if g_man.user.believe_in_god:
		convince(array_believe[0] > 0.95)
	else:
		convince(array_believe[1] < 0.05)

func convince(value):
	var server_quest: ServerQuest = QuestsManager.get_server_quest(11)
	if value:
		if g_man.user.believe_in_god and not convinced:
			server_quest.mission_completing({"convince" = Enums.Esprite.mob_organic_robot})
			convinced = true
		elif not philosopher:
			server_quest.mission_completing({"convince" = Enums.Esprite.mob_organic_robot})
			philosopher = true
	else:
		if g_man.user.believe_in_god and convinced:
			server_quest.mission_failing_quest({"convince" = Enums.Esprite.mob_organic_robot})
			convinced = false
		elif philosopher:
			server_quest.mission_failing_quest({"convince" = Enums.Esprite.mob_organic_robot})
			philosopher = false
		

func succeed_old_basis(success_old_basis__qq_index):
	pass
