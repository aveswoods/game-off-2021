extends Area2D
 
onready var _animation_player = $AnimationPlayer

var lunge_velocity = Vector2.ZERO
var is_decelerating = false
var is_lunging = false
var lunge_damage = 0.5
var lunge_impact_impulse = 800
var _can_lunge = true
var _player = null
var _player_facing_left = false
var _player_gravity = 0


func equip(player):
	_player = player
	_player.add_child(self)
	is_decelerating = false
	is_lunging = false
	_can_lunge = true
	_player_gravity = 0
func unequip():
	_player.remove_child(self)
	_player = null


func trigger():
	if _can_lunge:
		_can_lunge = false
		
		lunge_velocity = Vector2(600, 0)
		monitoring = true
		
		_animation_player.play("lunge")
		
		# Determine velocity
		if _player.is_facing_left():
			_player_facing_left = true
			scale.x = -1
		
		# Disable player input
		_player.invincible = true
		_player.input_disabled = true
		_player.is_outside_movement = true
		
		# Update player velocity
		_player.velocity.x = lunge_velocity.x * (-1 if _player_facing_left else 1)
		_player.velocity.y = lunge_velocity.y
		
		# Update player gravity
		_player_gravity = _player.gravity
		_player.gravity = 0


func _physics_process(_delta):
	if is_lunging or is_decelerating:
		_player.velocity.x = lunge_velocity.x * (-1 if _player_facing_left else 1)


func _set_lunge_velocity(velocity: Vector2):
	lunge_velocity = velocity


func _stop_lunging():
	is_lunging = false
	is_decelerating = true
	_player.gravity = _player_gravity
	_player.input_disabled = false
	_player.is_outside_movement = false


func _stop_invincibility():
	_player.invincible = false
	monitoring = false


func _stop_decelerating():
	is_decelerating = false
	_player_facing_left = false
	scale.x = 1
	_can_lunge = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		var direction = (body.global_position - global_position + Vector2(0, -0.5)).normalized()
		body.bump(lunge_impact_impulse * direction)
		body.take_damage(lunge_damage)
