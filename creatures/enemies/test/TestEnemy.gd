extends Enemy


const jump_impulse = -400
const walk_speed = 100
const bump_absorbance = 0
var walk_direction = 1

func _ready():
	randomize()
	velocity.x = walk_direction * walk_speed


func _physics_process(delta):
	movement_velocity = Vector2(walk_direction * walk_speed, 0)


func _on_Timer_timeout():
	# Jump!
	if is_on_floor():
		velocity.y += jump_impulse


func _on_EnemyHitbox_hitbox_entered():
	velocity.x = sign(velocity.x) * walk_speed


func _on_TestEnemy_collided_with_wall():
	walk_direction *= -1


func _on_TestEnemy_collided_with_body(collision):
	var collision_velocity = collision.collider_velocity
	if collision_velocity.length() > bump_absorbance:
		collision_velocity = (collision_velocity.length() - bump_absorbance) * collision_velocity.normalized()
		bump(collision_velocity)
