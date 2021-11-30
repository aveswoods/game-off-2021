extends Node

var _player = null
var _double_jumped = false


func equip(player):
	_player = player
	_player.add_child(self)
	_double_jumped = false
	_player.connect("collided_with_floor", self, "_on_player_hits_floor")
func unequip():
	if _player.is_connected("collided_with_floor", self, "_on_player_hits_floor"):
		_player.disconnect("collided_with_floor", self, "_on_player_hits_floor")
	_player.remove_child(self)
	_player = null


func _physics_process(_delta):
	if not _double_jumped and Input.is_action_just_pressed("ui_up") and not _player.is_on_floor() and not _player.input_disabled:
		_player.velocity.y = _player.jump_impulse
		_player.jump_gravity = 0
		_player.is_jumping = true
		_double_jumped = true
		
		var audio_jump = _player.get_node("AudioJump")
		audio_jump.pitch_scale = 1.1
		audio_jump.play()


func _on_player_hits_floor():
	_double_jumped = false
