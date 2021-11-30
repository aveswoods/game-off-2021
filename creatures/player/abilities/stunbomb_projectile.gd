extends Area2D

signal impacted

onready var _sprite = $Sprite
onready var _explosion_area = $ExplosionArea
onready var _particles = $CPUParticles2D
onready var _timer = $Timer

onready var _audio_launch = $AudioLaunch
onready var _audio_impact = $AudioImpact

const launch_speed = 720
var stun_time = 6
var stun_damage = 0.5

var _launching = false
var _direction = Vector2.ZERO

func launch(direction):
	_direction = direction
	_launching = true
	_sprite.visible = true
	monitoring = true
	_particles.emitting = false
	
	_audio_launch.play()
	
	_timer.start()


func _physics_process(delta):
	if _launching:
		position += delta * launch_speed * _direction


func _on_BombArea_body_entered(body):
	if not body.is_in_group("player"):
		_launching = false
		_sprite.visible = false
		set_deferred("monitoring", false)
		_particles.emitting = true
		
		_audio_impact.play()
		
		emit_signal("impacted")
		
	for body in _explosion_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(stun_damage)
			body.stun(stun_time)


func _on_Timer_timeout():
	_launching = false
	_sprite.visible = false
	set_deferred("monitoring", false)
	
	emit_signal("impacted")
