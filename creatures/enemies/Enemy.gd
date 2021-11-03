extends KinematicBody2D

class_name Enemy

signal collided_x
signal collided_y

# Game variables
const wall_bounce_impulse = 300
var hp = 0
enum death_source {
	EXPLOSION,
	ERASE,
	WATER,
	BULLET
}

# Physics variables
const _gravity = 30
var velocity = Vector2.ZERO
var _is_on_floor = false


func take_damage(amount : int, impulse : Vector2, source = death_source.ERASE):
	hp -= amount
	print("Enemy damage")


func _physics_process(delta):
	# Add gravity
	velocity.y += _gravity
	
	# Checks for x collisions
	var collision_x = move_and_collide(delta * Vector2(velocity.x, -0.1), true, true, true)

	 # Move based on velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Emit collision signals if applies
	if collision_x != null:
		var sign_x = sign(collision_x.normal.x)
		if sign_x == 0:
			sign_x = 1
		velocity = wall_bounce_impulse * Vector2(sign_x, -0.1)
		emit_signal("collided_x")
	
	# Sets _is_on_floor to true if on floor in the NEXT frame
	if not _is_on_floor and test_move(transform, delta * (velocity + Vector2(0, _gravity))):
		_is_on_floor = true
		emit_signal("collided_y")
