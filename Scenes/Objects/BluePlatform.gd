extends StaticBody2D

var _charged = false
var _activated = false


func charge():
	#$AudioStreamPlayer.play()
	$AnimationTree.set("parameters/active_state/current", 0)
	$AnimationTree.set("parameters/energy_state/current", 1)
	_charged = true
	_activated = false

func is_charged():
	return _charged


func activate():
	$AnimationTree.set("parameters/active_state/current", 1)
	$AnimationTree.set("parameters/energy_state/current", 1)
	_charged = false
	_activated = true

func is_activated():
	return _activated


func idle():
	$AnimationTree.set("parameters/energy_state/current", 0)
	_charged = false
	_activated = false


func _ready() -> void:
	$AnimationTree.active = true
