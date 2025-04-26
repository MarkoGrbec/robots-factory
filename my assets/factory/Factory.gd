class_name Factory extends Node

enum Type{
	FRIENDLY,
	ENEMY,
	FIGHT
}

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
@export var type: Type
@export var initial_health: float = 100

@export_multiline var end_game_text: String

var health = 100

func _ready() -> void:
	if type == Type.FRIENDLY:
		g_man.factory = self
	if type == Type.ENEMY:
		g_man.enemy_factory = self
	if type == Type.FIGHT:
		g_man.factory_fight = self

func upgrade():
	if state < State.SMOKE:
		health = initial_health
		@warning_ignore("int_as_enum_without_cast")
		state += 1
		# change texture
		factory_texture.texture = textures[state]
		# activate collision
		collisions[state].disabled = false
		
		if (type == Type.FRIENDLY or type == Type.FIGHT) and state == State.SMOKE:
			# finished game
			g_man.mold_window.set_instructions_only([end_game_text])

func downgrade():
	if state > State.NONE:
		health = initial_health
		@warning_ignore("int_as_enum_without_cast")
		state -= 1
		# change texture
		factory_texture.texture = textures[state]
		# activate collision
		collisions[state].disabled = true
		
		if type == Type.ENEMY and state == State.NONE:
			# finished game
			g_man.mold_window.set_instructions_only([end_game_text])

func get_hit(_damage):
	health -= _damage
	if health <= 0:
		downgrade()
	#
	#state = State.NONE
	#factory_texture.texture = null
	#for col in collisions:
		#col.disabled = true
