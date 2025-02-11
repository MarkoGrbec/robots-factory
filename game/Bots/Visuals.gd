class_name Visuals extends Node

@export var right_arm: Polygon2D
@export var right_leg: Polygon2D
@export var body: Polygon2D
@export var left_leg: Polygon2D
@export var head: Polygon2D
@export var chin: Polygon2D
@export var left_arm: Polygon2D

var array_poligons: Array[Polygon2D]

func _ready() -> void:
	array_poligons.push_back(right_arm)
	array_poligons.push_back(right_leg)
	array_poligons.push_back(body)
	array_poligons.push_back(left_leg)
	array_poligons.push_back(head)
	array_poligons.push_back(chin)
	array_poligons.push_back(left_arm)

func color_poligons(color: Color):
	color.r = color_me(color.r)
	color.g = color_me(color.g)
	color.b = color_me(color.b)
	for polygon in array_poligons:
		polygon.color = color

func color_me(color_rgb):
	return clampf(((color_rgb + (1/255)) / 128) * 256, 0, 1)
