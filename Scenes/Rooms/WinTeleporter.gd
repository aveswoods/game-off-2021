extends Node2D

signal player_wins

export(bool) var disabled = false

onready var _doorway_hitbox = $Area2D
onready var _sprite = $Sprite
onready var _animation_player = $AnimationPlayer
var _in_doorway = false


func enable():
	_doorway_hitbox.monitoring = true
	disabled = false
	_animation_player.play("open")
func disable():
	_doorway_hitbox.monitoring = false
	disabled = true
	_animation_player.play("close")


func _ready():
	if disabled:
		_sprite.material.set_shader_param("transparency", 0)


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not disabled and _in_doorway:
		emit_signal("player_wins")


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		_in_doorway = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		_in_doorway = false
