extends Enemy

onready var _audio_damaged = $AudioCreatureDamaged

var bump_velocity = 720
var damage = 1
var _charged = false
var _activated = false

#charged.
func charge():
	$AnimationPlayer.play("charged")
	$AreaDamage/CollisionPolygon2D.disabled = true
	_charged = true
	_activated = false

func is_charged():
	return _charged


func activate():
	$AnimationPlayer.play("activated")
	$AreaDamage/CollisionPolygon2D.disabled = false
	_charged = false
	_activated = true

func is_activated():
	return _activated


func idle():
	$AnimationPlayer.play("idle")
	$AreaDamage/CollisionPolygon2D.set_deferred("disabled", true)
	_charged = false
	_activated = false


func _ready():
	disabled = true


func _on_AreaDamage_body_entered(body):
	if body.has_method("bump"):
		var velocity = bump_velocity * ((body.global_position - global_position).normalized())
		velocity.y = min (velocity.y, -0.2)
		body.bump(velocity)
	if body.has_method("take_damage"):
		if body.is_in_group("player"):
			body.take_damage(1)
		else:
			body.take_damage(damage * Global.damage_multiplier, 0)
	
	_audio_damaged.play()
