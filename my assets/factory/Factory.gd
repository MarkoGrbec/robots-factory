class_name Factory extends Node

enum State{
	NONE = -1,
	GROUND = 0,
	MIDDLE_BUILD = 1,
	MIDDLE_UP = 2,
	TOP = 3,
	TOP_UP = 4,
	SMOKE = 5
}

@export var factory_texture: Sprite2D
@export var textures: Array[Texture2D]
@export var collisions: Array[CollisionShape2D]

@export var state: State

func _ready() -> void:
	g_man.factory = self

func upgrade():
	if state < State.SMOKE:
		@warning_ignore("int_as_enum_without_cast")
		state += 1
		# change texture
		factory_texture.texture = textures[state]
		# activate collision
		collisions[state].disabled = false
		
		if state == State.SMOKE:
			# finished game
			g_man.mold_window.set_instructions_only(["thanks for playing"])

func get_hit(_damage):
	state = State.NONE
	factory_texture.texture = null
	for col in collisions:
		col.disabled = true
