extends Node

var _player = null
var _double_jumped = false


func equip(player):
	_player = player
	_player.add_child(self)


func _ready():
	_player.connect("collided_with_floor", self, "_on_player_hits_floor")


func _physics_process(_delta):
	if not _double_jumped and Input.is_action_just_pressed("ui_up") and not _player.is_on_floor():
		_player.velocity.y = _player.jump_impulse
		_double_jumped = true


func _on_player_hits_floor():
	_double_jumped = false
