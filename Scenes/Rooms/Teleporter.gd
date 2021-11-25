extends Node2D

signal teleported(destination)

enum destinations { HUB, RUN, BOSS }
export(destinations) var destination
export(bool) var disabled = false

onready var _doorway_hitbox = $Area2D
var _in_doorway = false


func enable():
	_doorway_hitbox.monitoring = true
func disable():
	_doorway_hitbox.monitoring = false


func _ready():
	if disabled:
		disable()


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and _in_doorway:
		emit_signal("teleported", destination)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		_in_doorway = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		_in_doorway = false
