extends Enemy


const jump_impulse = -400
const walk_speed = 100

func _ready():
	randomize()
	velocity.x = walk_speed


func _on_Timer_timeout():
	# Jump!
	if is_on_floor():
		velocity.y = jump_impulse


func _on_TestEnemy_collided_x():
	velocity.x = sign(velocity.x) * walk_speed


func _on_EnemyHitbox_hitbox_entered():
	velocity.x = sign(velocity.x) * walk_speed
