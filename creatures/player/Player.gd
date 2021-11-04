extends KinematicBody2D

signal collided_x
signal collided_y

# Scene variables
onready var _sprite = $CreatureSprite
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
var gravity = 30 # px / sec^2
var jump_impulse = -640 # px / sec 
var move_speed = 240 # px / sec
var friction = 0.15
var acceleration = 0.2
var velocity = Vector2.ZERO
var invincible = false
var _is_on_floor = false
var _taking_damage = false
var _damage_impulse = Vector2.ZERO


func animate(name: String, flipped_h: bool = false, custom_blend : float = -1):
	_sprite.flip_h(flipped_h)
	_is_facing_left = flipped_h
	_animation_player.play(name, custom_blend)


# NOTE/BUG:
# Damage is not applied if the user is inside a hitbox after the invincibility timer has expired!
# However, the timer is so short that this is a small issue.
func take_damage(damage, impulse):
	if not invincible:
		hp -= damage
		_taking_damage = true
		_damage_impulse = impulse
		
		invincible = true
		_invincibility_timer.start()
		
		print("Player damaged!")


func is_facing_left():
	return _is_facing_left

func is_on_floor():
	return _is_on_floor


func _ready():
	_animation_player.play("idle")


# TODO:
# Handle directional input and weapon additional input at the same time
# Current solution is disabling input
func _physics_process(delta):
	# -------------------
	# | INPUT DETECTING |
	# -------------------
	
	# Detect action input
	if Input.is_action_just_pressed("ui_accept") and action1_script != null and not input_disabled:
		action1_script.trigger()
	if Input.is_action_just_pressed("ui_select") and action2_script != null and not input_disabled:
		action2_script.trigger()
	
	# Detect horizontal input
	var direction = 0
	if Input.is_action_pressed("ui_left") and not _taking_damage and not input_disabled:
		direction += -1
	if Input.is_action_pressed("ui_right") and not _taking_damage and not input_disabled:
		direction += 1
	
	# Detect vertical input
	if Input.is_action_just_pressed("ui_up") and _is_on_floor and is_equal_approx(velocity.y, 0) and not input_disabled:
		velocity.y = jump_impulse
		_is_on_floor = false
		
		# Animate jump
		#_sprite.animation = "jump"
	
	# -------------------
	# | CREATE MOVEMENT |
	# -------------------
	
	# Interpolate based on horizontal input
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
		
	elif not is_outside_movement:
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
	
	# Apply damage impulse
	if _taking_damage:
		velocity.x += _damage_impulse.x
		velocity.y = _damage_impulse.y
		_taking_damage = false
		_is_on_floor = false
	
	# ------------------
	# | APPLY MOVEMENT |
	# ------------------
	
	# Checks for x collisions
	var collision_x = move_and_collide(delta * Vector2(velocity.x, -0.1), true, true, true)
	
	# Move the player based on velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Emit collision signals if applies
	if collision_x != null:
		var sign_x = sign(collision_x.normal.x)
		if sign_x == 0:
			sign_x = 1
		velocity += _wall_bounce_impulse * Vector2(sign_x, -0.1)
		emit_signal("collided_x")
	
	# Sets _is_on_floor to true if on floor in the NEXT frame
	# Allows for handling of jump input the same frame that the player lands
	if not _is_on_floor and test_move(transform, delta * (velocity + Vector2(0, gravity))):
		_is_on_floor = true
		emit_signal("collided_y")
	
	


func _on_InvincibilityTimer_timeout():
	invincible = false
