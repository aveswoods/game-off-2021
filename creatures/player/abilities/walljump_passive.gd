extends RayCast2D

var _player = null


func equip(player):
	_player = player
	_player.add_child(self)
func unequip():
	_player.remove_child(self)
	_player = null


func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_up") and not _player.is_on_floor():
		if _player.is_facing_left():
			cast_to.x *= -1
			force_raycast_update()
			if is_colliding():
				_player.bump(Vector2(-1 * _player.jump_impulse, _player.jump_impulse))
				_player.jump_gravity = 0
				_player.is_jumping = true
			cast_to.x *= -1
		else:
			if is_colliding():
				_player.bump(Vector2(_player.jump_impulse, _player.jump_impulse))
