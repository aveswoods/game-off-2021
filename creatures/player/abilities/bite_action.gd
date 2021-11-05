extends Area2D
 
onready var _timer = $Timer

var bite_damage = 1
var bite_impact_impulse = 500
var _can_bite = true
var _is_dead_time = false
var _player = null


func equip(player):
	_player = player
	_player.add_child(self)


func trigger():
	if _can_bite:
		var flipped = _player.is_facing_left()
		if flipped:
			scale.x = -1
		_player.animate("bite", flipped)
		_player.input_disabled = true
		monitoring = true
		_timer.start()


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		var direction_x = -1 if _player.is_facing_left() else 1
		body.bump(bite_impact_impulse * Vector2(direction_x, -1))
		body.take_damage(bite_damage, 0)


func _on_Timer_timeout():
	monitoring = false
	if _is_dead_time:
		_can_bite = true
		_is_dead_time = false
		scale.x = 1
		_player.input_disabled = false
	else:
		_is_dead_time = true
		_timer.start()
