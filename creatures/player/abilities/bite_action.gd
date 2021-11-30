extends Area2D
 
onready var _timer = $Timer
onready var _animation_player = $AnimationPlayer
onready var _damage_particles = $DamageParticles

onready var _audio_swing = $AudioSwing
onready var _audio_impact = $AudioImpact

var bite_damage = 1
var bite_impact_impulse = 500
var _can_bite = true
var _is_dead_time = false
var _player = null


func equip(player):
	_player = player
	_player.add_child(self)
	_can_bite = true
	_is_dead_time = false
func unequip():
	_player.remove_child(self)
	_player = null


func trigger():
	if _can_bite:
		if _player.is_facing_left():
			scale.x = -1
		_animation_player.play("swing")
		_player.animation_tree.set("parameters/OneShot/active", true)
		monitoring = true
		_timer.start()
		_can_bite = false
		
		_audio_swing.play()


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		var direction_x = 1
		if _player.is_facing_left():
			direction_x = -1
			_damage_particles.direction.x = -1 * abs(_damage_particles.direction.x)
		else:
			_damage_particles.direction.x = abs(_damage_particles.direction.x)
		body.bump(bite_impact_impulse * Vector2(direction_x, -1))
		body.take_damage(bite_damage * Global.damage_multiplier, 0)
		_damage_particles.global_position = body.global_position
		_damage_particles.restart()
		
		_audio_impact.global_position = _damage_particles.global_position
		_audio_impact.play()


func _on_Timer_timeout():
	monitoring = false
	if _is_dead_time:
		_can_bite = true
		_is_dead_time = false
	else:
		scale.x = 1
		_is_dead_time = true
		_timer.start()
