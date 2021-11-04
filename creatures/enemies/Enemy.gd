extends KinematicBody2D

class_name Enemy

signal collided_with_body(collision)
signal collided_with_wall
signal collided_with_floor
signal collided_with_ceiling

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
var gravity = 30
var movement_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var friction = 0.15
var acceleration = 0.8
var moving = false
var _bumping = false
var _bump_impulse = Vector2.ZERO


func bump(impulse):
	_bumping = true
	_bump_impulse = impulse


func take_damage(amount : int, impulse : Vector2 = Vector2.ZERO, source = death_source.ERASE):
	hp -= amount
	print("Enemy damage")


func _physics_process(delta):
	# Add gravity
	velocity.y += gravity
	# Add friction/acceleration
	if movement_velocity.is_equal_approx(Vector2(0, 0)):
		velocity.x = lerp(velocity.x, 0, friction)
	else:
		velocity.x = lerp(movement_velocity.x, velocity.x, acceleration)
	
	if _bumping:
		velocity += _bump_impulse
		_bumping = false
	
	# Checks for body collisions
	var collision = move_and_collide(delta * velocity, true, true, true)
	if collision != null and not collision.collider is TileMap:
		emit_signal("collided_with_body", collision)
	
	 # Move based on velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Emit collision signals when applies
	if is_on_wall():
		emit_signal("collided_with_wall")
	if is_on_floor():
		emit_signal("collided_with_floor")
	if is_on_ceiling():
		emit_signal("collided_with_ceiling")
