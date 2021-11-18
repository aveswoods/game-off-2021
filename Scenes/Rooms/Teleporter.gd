extends Node2D

signal teleported(destination)

enum destinations { HUB, RUN, BOSS }
export(destinations) var destination

onready var _teleport_hitbox = $Area2D/CollisionShape2D


func enable():
	_teleport_hitbox.disabled = false
func disable():
	_teleport_hitbox.disabled = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("teleported", destination)
