class_name OrganicRobot extends CPQuest

@export var believe: TextureRect
@onready var gradient_tex: GradientTexture1D = believe.texture

func quest_believe(array_believe):
	gradient_tex.gradient.offsets[0] = array_believe[0]
	gradient_tex.gradient.offsets[1] = array_believe[1]

func succeed_old_basis(success_old_basis__qq_index):
	pass
