extends Area2D

onready var _impact_particles = $ImpactParticles

var stomp_damage = 0
var stomp_enemy_impulse = Vector2(0, 30)
var stun_time = 4
var _player = null


func equip(player):
	_player = player
	_player.add_child(self)


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy") and _player.velocity.y > 0:
		_player.velocity.y *= -1
		body.bump(stomp_enemy_impulse)
		body.take_damage(stomp_damage)
		body.stun(stun_time)
		_impact_particles.restart()
