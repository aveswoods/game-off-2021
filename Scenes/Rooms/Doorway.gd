extends Area2D

onready var _barrier = $StaticBody2D/CollisionShape2D
onready var _sprite = $StaticBody2D/Sprite

var permanently_closed = false

func open():
	if not permanently_closed:
		_barrier.set_deferred("disabled", true)
		_sprite.set_deferred("visible", false)

func close():
	_barrier.set_deferred("disabled", false)
	_sprite.set_deferred("visible", true)
