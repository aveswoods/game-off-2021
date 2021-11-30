extends StaticBody2D

var _charged = false
var _activated = false


func charge():
	$AnimationPlayer.play("charged")
	$CollisionShape2D.disabled = false
	_charged = true
	_activated = false

func is_charged():
	return _charged


func activate():
	$AnimationPlayer.play("active")
	$CollisionShape2D.disabled = true
	_charged = false
	_activated = true

func is_activated():
	return _activated


func idle():
	$AnimationPlayer.play("idle")
	$CollisionShape2D.set_deferred("disabled", false)
	_charged = false
	_activated = false
