class_name QQOtherNPC extends Resource

## which npc will be activated - use index + 1
@export var npc_activate: int
## how will it be activated or deactivated
@export var npc_activated: bool
## will the npc be alive or dead after this completed quest
@export var npc_alive: bool
## his npc basis
@export var npc_basis: int
## his npc layer -100 is default for non changable
@export var npc_layer: int = -100
