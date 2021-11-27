extends Node

const fall_speed = 30
const acceleration = 0.95
var _player = null
var _player_acceleration = 0
var _gliding = false


func equip(player):
	_player = player
	_player.add_child(self)
	_gliding = false
	
	_player.connect("collided_with_floor", self, "_on_player_hits_floor")
func unequip():
	if _player.is_connected("collided_with_floor", self, "_on_player_hits_floor"):
		_player.disconnect("collided_with_floor", self, "_on_player_hits_floor")
	
	_player.remove_child(self)
	_player = null


func _physics_process(_delta):
	if Input.is_action_pressed("ui_up") and not _player.is_on_floor() and _player.velocity.y > 0:
		_player.velocity.y = fall_speed
		if not _gliding:
			_player_acceleration = _player.acceleration
			_player.acceleration = acceleration
			_gliding = true
	elif Input.is_action_just_released("ui_up") and _gliding:
		_player.acceleration = _player_acceleration
		_gliding = false

func _on_player_hits_floor():
	_player.acceleration = _player_acceleration
	_gliding = false
