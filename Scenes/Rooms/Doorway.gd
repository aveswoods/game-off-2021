extends Area2D

onready var _barrier = $StaticBody2D/CollisionShape2D
onready var _sprite = $StaticBody2D/Sprite


func open():
	_barrier.disabled = true
	_sprite.visible = false

func close():
	_barrier.disabled = false
	_sprite.visible = true
