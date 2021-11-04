extends KinematicBody2D

signal collided_with_body(collision)
signal collided_with_wall
signal collided_with_floor
signal collided_with_ceiling

# Scene variables
onready var _sprite = $CreatureSprite
onready var _raycast_gravity = $CollisionGravityRayCast
onready var _invincibility_timer = $InvincibilityTimer
onready var _animation_player = $AnimationPlayer

# Game variables
var hp = 0
var action1_script = null
var action2_script = null
var input_disabled = false
var is_outside_movement = false
var _is_facing_left = false

# Physics variables
const _wall_bounce_impulse = 20
const _jump_forgiveness_time = 0.1
var _air_time = _jump_forgiveness_time
var gravity = 30 # px / sec^2
var jump_impulse = -640 # px / sec 
var move_speed = 240 # px / sec
var friction = 0.15
var acceleration = 0.2
var velocity = Vector2.ZERO
var invincible = false
var _is_on_floor = false
var _bumping = false
var _bump_impulse = Vector2.ZERO


func animate(name: String, flipped_h: bool = false, custom_blend : float = -1):
	_sprite.flip_h(flipped_h)
	_is_facing_left = flipped_h
	_animation_player.play(name, custom_blend)


func bump(impulse):
	_bumping = true
	_bump_impulse = impulse

# NOTE/BUG:
# Damage is not applied if the user is inside a hitbox after the invincibility timer has expired!
# However, the timer is so short that this is a small issue.
func take_damage(damage):
	hp -= damage
	
	invincible = true
	_invincibility_timer.start()
	
	print("Player damaged!")


func is_facing_left():
	return _is_facing_left

func is_on_floor():
	return _is_on_floor
	

func _ready():
	_animation_player.play("idle")
	_is_on_floor = _raycast_gravity.is_colliding()
	if _is_on_floor:
		_air_time = 0


# TODO:
# Handle directional input and weapon additional input at the same time
# Current solution is disabling input
func _physics_process(delta):
	
	# -------------------
	# | INPUT DETECTING |
	# -------------------
	var direction = 0
	if not input_disabled:
		# Detect action input
		if Input.is_action_just_pressed("ui_accept") and action1_script != null:
			action1_script.trigger()
		if Input.is_action_just_pressed("ui_select") and action2_script != null:
			action2_script.trigger()
		
		# Detect horizontal input
		if Input.is_action_pressed("ui_left"):
			direction += -1
		if Input.is_action_pressed("ui_right"):
			direction += 1
		
		# Detect vertical input
		if Input.is_action_just_pressed("ui_up") and _air_time < _jump_forgiveness_time:
			velocity.y = jump_impulse
			_is_on_floor = false
			
			# Animate jump
			#_sprite.animation = "jump"
	
	# -------------------
	# | CREATE MOVEMENT |
	# -------------------
	
	# Interpolate based on horizontal input
	if not is_outside_movement:
		if direction != 0:
			velocity.x = lerp(direction * move_speed, velocity.x, acceleration)
			
			if direction == 1:
				_sprite.flip_h(false)
				_is_facing_left = false
			else:
				_sprite.flip_h(true)
				_is_facing_left = true
			
			if _is_on_floor:
				_animation_player.play("run")
			
		else:
			velocity.x = lerp(velocity.x, 0, friction)
			
			if _is_on_floor:
				if _animation_player.current_animation != "run":
					_animation_player.queue("idle")
				else:
					_animation_player.play("idle")
	
	# Add gravity
	velocity.y += gravity
	
	# Animate fall
	if not _is_on_floor and velocity.y > 0:
		#_sprite.animation = "fall"
		pass
	
	# Apply bump impulse
	if _bumping:
		velocity.x = _bump_impulse.x
		velocity.y = _bump_impulse.y
		_bumping = false
		_is_on_floor = false
	
	# ------------------
	# | APPLY MOVEMENT |
	# ------------------
	
	var collision = move_and_collide(delta * velocity, true, true, true)
	
	# Check for colliding with body
	if collision != null and not collision.collider is TileMap:
		emit_signal("collided_with_body", collision)
		print("Collided with body " + str(collision.collider))
	
	# Move the player based on velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Manage in-air variables
	_is_on_floor = _raycast_gravity.is_colliding()
	if _is_on_floor:
		_air_time = 0
	else:
		_air_time += delta
	
	# Emit collision signals when applied
	if is_on_wall():
		emit_signal("collided_with_wall")
	if is_on_floor():
		emit_signal("collided_with_floor")
	if is_on_ceiling():
		emit_signal("collided_with_ceiling")


func _on_InvincibilityTimer_timeout():
	invincible = false
