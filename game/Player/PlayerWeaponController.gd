class_name PlayerWeaponController extends Node

@export var weapon: Weapon

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		TTCWeapon.new(weapon)

func _on_beam_weapon_hit_body(object) -> void:
	if object.is_in_group("enemy"):
		object.get_hit(1)
