extends Area2D

class_name EnemyHitbox

signal hitbox_entered

# Constact damage constants
const contact_damage = 1
const contact_impulse = 500


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		var impulse = body.global_position - self.global_position
		if impulse.x < 0:
			impulse = contact_impulse * Vector2(-1, -1)
		else:
			impulse = contact_impulse * Vector2(1, -1)
		print("Damage!")
		body.take_damage(contact_damage, impulse)
		
		emit_signal("hitbox_entered")
