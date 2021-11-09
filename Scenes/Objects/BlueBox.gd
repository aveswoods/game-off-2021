extends Enemy

var bump_velocity = 720
var damage = 1
var _charged = false
var _activated = false

#charged.
func charge():
	#$AudioStreamPlayer.play()
	#$AnimationTree.set("parameters/action_state/current", 0)
	#$AnimationTree.set("parameters/energy_state/current", 1)
	$AnimationPlayer.play("charged")
	$AreaDamage/CollisionPolygon2D.disabled = true
	_charged = true
	_activated = false

func is_charged():
	return _charged


func activate():
	#$AnimationTree.set("parameters/action_state/current", 1)
	#$AnimationTree.set("parameters/energy_state/current", 1)
	$AnimationPlayer.play("activated")
	$AreaDamage/CollisionPolygon2D.disabled = false
	_charged = false
	_activated = true

func is_activated():
	return _activated


func idle():
	#$AnimationTree.set("parameters/energy_state/current", 0)
	$AnimationPlayer.play("idle")
	$AreaDamage/CollisionPolygon2D.disabled = true
	_charged = false
	_activated = false


func _on_AreaDamage_body_entered(body):
	print("body entered")
	if body.has_method("bump"):
		var velocity = bump_velocity * ((body.global_position - global_position).normalized())
		velocity.y = min (velocity.y, -0.2)
		body.bump(velocity)
	if body.has_method("take_damage"):
		if body.is_in_group("player"):
			body.take_damage(damage)
		else:
			body.take_damage(damage, 0)
