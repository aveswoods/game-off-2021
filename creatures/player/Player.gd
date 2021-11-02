extends KinematicBody2D


onready var _sprite = $CreatureSprite

# Physics variables
const _gravity = 30 # px / sec^2
const _jump_impulse = -720 # px / sec 
const _move_speed = 240 # px / sec
const _friction = 0.15
const _acceleration = 0.2
var _velocity = Vector2.ZERO
var _is_on_floor = false

func _physics_process(delta):
	# Detect horizontal input
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction += -1
	if Input.is_action_pressed("ui_right"):
		direction += 1
	
	# Interpolate based on horizontal input
	if direction != 0:
		_velocity.x = lerp(direction * _move_speed, _velocity.x, _acceleration)
		
		if _is_on_floor:
			_sprite.animation = "run"
			if direction == -1:
				_sprite.flip_h(false)
			else:
				_sprite.flip_h(true)
	else:
		_velocity.x = lerp(_velocity.x, 0, _friction)
		
		if _is_on_floor:
			_sprite.animation = "default"
	
	# Add gravity
	_velocity.y += _gravity
	
	# Animate fall
	if not _is_on_floor and _velocity.y > 0:
		_sprite.animation = "fall"
	
	# Move the player based on velocity
	_velocity = move_and_slide(_velocity, Vector2(0, -1))
	
	# Sets _is_on_floor to true if on floor in the NEXT frame
	# Allows for handling of jump input the same frame that the player lands
	if not _is_on_floor and test_move(transform, delta * (_velocity + Vector2(0, _gravity))):
		_is_on_floor = true
	
	# Detect vertical input
	if _is_on_floor and Input.is_action_just_pressed("ui_up"):
		_velocity.y = _jump_impulse
		_is_on_floor = false
		
		# Animate jump
		_sprite.animation = "jump"
