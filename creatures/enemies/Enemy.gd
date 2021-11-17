extends KinematicBody2D

class_name Enemy

signal collided_with_body(collision)
signal collided_with_wall
signal collided_with_floor
signal collided_with_ceiling
signal stunned
signal unstunned
signal killed(source)

# Game variables
var _stun_timer = Timer.new()
var hp = 0
var invincible = false
var controlled = false
var disabled = false
enum death_source {
	IMPACT, # 0
	EXPLOSION, # 1
	ERASE, # 2
	WATER # 3
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


func bump(impulse: Vector2):
	_bumping = true
	_bump_impulse = impulse


func stun(time: float):
	emit_signal("stunned")
	_stun_timer.wait_time = time
	_stun_timer.start()


func take_damage(amount : int, source = death_source.ERASE):
	if not invincible:
		hp -= amount
		if hp <= 0:
			emit_signal("killed", source)

# Must be implemented to be able to be charmed!
func set_target_group(_group):
	pass


func _ready():
	_stun_timer.one_shot = true
	_stun_timer.connect("timeout", self, "_on_stun_timer_timeout")
	add_child(_stun_timer)


func _physics_process(delta):
	if disabled:
		return
	
	# Add gravity
	velocity.y += gravity * pow(Global.time_multiplier, 2)
	# Add friction/acceleration
	if movement_velocity.is_equal_approx(Vector2(0, 0)):
		velocity.x = lerp(velocity.x, 0, friction * Global.time_multiplier) * Global.time_multiplier
	else:
		velocity.x = lerp(movement_velocity.x, velocity.x, acceleration * Global.time_multiplier) * Global.time_multiplier
	
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
	
	# Reset movement
	movement_velocity = Vector2.ZERO

func _on_stun_timer_timeout():
	emit_signal("unstunned")
