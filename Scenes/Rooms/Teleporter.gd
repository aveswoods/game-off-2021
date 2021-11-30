extends Node2D

signal teleported(destination)

enum destinations { HUB, RUN, BOSS }
export(destinations) var destination
export(bool) var disabled = false

onready var _doorway_hitbox = $Area2D
onready var _animation_player = $AnimationPlayer
var _in_doorway = false
var _disabled = false

onready var _audio_entered = $AudioEntered

func enable():
	_doorway_hitbox.monitoring = true
	_disabled = false
func disable():
	_doorway_hitbox.monitoring = false
	_disabled = true

func is_disabled():
	return _disabled


func _ready():
	if disabled:
		disable()
		_disabled = true


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not _disabled and _in_doorway:
		emit_signal("teleported", destination)
		
		_audio_entered.play()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and not _disabled:
		_in_doorway = true
		_animation_player.play("show_input")

func _on_Area2D_body_exited(body):
	if body.is_in_group("player") and not _disabled:
		_in_doorway = false
		_animation_player.play("hide_input")
