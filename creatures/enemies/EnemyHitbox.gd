extends Area2D

class_name EnemyHitbox

signal hitbox_entered

# Constact damage constants
var contact_damage = 1
var contact_impulse = 500
var target_group = "player"


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node):
	if body.is_in_group(target_group) and not body.invincible:
		var impulse = body.global_position - self.global_position
		if impulse.x < 0:
			impulse = contact_impulse * Vector2(-1, -1)
		else:
			impulse = contact_impulse * Vector2(1, -1)
		
		body.bump(impulse)
		body.take_damage(contact_damage, 0)
		
		emit_signal("hitbox_entered")
