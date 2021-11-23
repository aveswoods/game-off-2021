extends Enemy

onready var _sprite = $CreatureSprite
onready var _animation_player = $AnimationPlayer
onready var _hitbox = $EnemyHitbox
onready var _raycast = $RayCast2D

const starting_hp = 5
const walk_speed = 50
const charge_speed = 600
const bump_absorbance = 1
const slow_acceleration = 0.95
var facing_direction = 1
var _stunned = false
var _dead = false

var _charging = false
var _walking = false
var _idle_time = 0


func set_target_group(group):
	_hitbox.target_group = group


func _ready():
	hp = starting_hp
	friction = 0.25
	acceleration = slow_acceleration
	_idle_time = 2 + randi() % 3


func _change_direction():
	facing_direction *= -1
	_sprite.scale.x *= -1
	_raycast.cast_to.x *= -1


func _stop_charging():
	acceleration = slow_acceleration
	_charging = false
	gravity = 30
	_animation_player.play("RESET")


func _physics_process(delta):
	# Mind controlled behavior
	if controlled:
		if _charging:
			movement_velocity = Vector2(facing_direction * charge_speed, 0)
		else:
			var idle = true
			if Input.is_action_pressed("ui_left"):
				movement_velocity.x += -1 * walk_speed
				facing_direction = -1
				_sprite.scale.x = -1
				_raycast.cast_to.x = -1 * abs(_raycast.cast_to.x)
				if _animation_player.current_animation != "walk":
					_animation_player.play("walk")
				idle = false
			if Input.is_action_pressed("ui_right"):
				movement_velocity.x += walk_speed
				facing_direction = 1
				_sprite.scale.x = 1
				_raycast.cast_to.x = abs(_raycast.cast_to.x)
				if _animation_player.current_animation != "walk":
					_animation_player.play("walk")
				idle = false
			if Input.is_action_just_pressed("ui_up"):
				acceleration = 0
				_animation_player.play("charge")
			if idle and _animation_player.current_animation == "walk":
				_animation_player.play("RESET")
			
	# Standard behavior
	else:
		if not _stunned:
			if _charging:
				movement_velocity = Vector2(facing_direction * charge_speed, 0)
			else:
				if _raycast.is_colliding() and _raycast.get_collider() is KinematicBody2D and _raycast.get_collider().is_in_group(_hitbox.target_group):
					acceleration = 0.5
					_animation_player.play("charge")
					_idle_time = 3 + randi() % 2
					_walking = false
				else:
					_idle_time -= delta
					if _idle_time < 0:
						if _animation_player.current_animation == "walk":
							_animation_player.play("RESET")
							_idle_time = 3 + randi() % 2
							_walking = false
						else:
							_animation_player.play("walk")
							_idle_time = 1 + randi() % 2
							var change_direction = randi() % 2
							if change_direction == 1:
								_change_direction()
							_walking = true
					else:
						if _walking:
							movement_velocity = Vector2(facing_direction * walk_speed, 0)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"charge":
			_animation_player.play("attack")
			gravity = 0
			_charging = true
			bump(Vector2(facing_direction * charge_speed / 4.0, 0))


func _on_Beetle_Bug_collided_with_wall():
	if _walking or _charging:
		_change_direction()
	if _charging:
		_stop_charging()
		bump(Vector2(facing_direction * charge_speed, -1 * charge_speed / 2.0))


func _on_Beetle_Bug_collided_with_body(collision):
	if _charging:
		_stop_charging()
		bump(Vector2(facing_direction * charge_speed, -1 * charge_speed / 2.0))
		# Bump other object
		if collision.collider.has_method("bump") and not collision.collider.is_in_group("player"):
			collision.collider.bump(Vector2(-1 * facing_direction * charge_speed, -1 * charge_speed / 2.0))
		return
	
	var collision_velocity = collision.collider_velocity
	var collision_length = collision_velocity.length()
	print(collision_length)
	var collision_direction = collision_velocity.normalized()
	
	# Bump self
	if collision_length > bump_absorbance:
		bump((collision_length - bump_absorbance) * (collision_direction + Vector2(0, -0.5)))
	
	# Bump other object
	if collision.collider.has_method("bump") and not collision.collider.is_in_group("player"):
		if collision.collider.has_meta("bump_absorbance"):
			collision_length -= collision.collider.bump_absorbance
		if collision_length > 0:
			collision.collider.bump(-1 * collision_length * (collision_direction + Vector2(0, -0.5)))


func _on_Beetle_Bug_stunned():
	_hitbox.monitoring = false
	#_sprite.animate_stun()
	_stunned = true
	_stop_charging()
	_animation_player.play("damaged")


func _on_Beetle_Bug_unstunned():
	_hitbox.monitoring = true
	#_sprite.animate_stun()
	_animation_player.play("RESET")
	_stunned = false


func _on_Beetle_Bug_killed(_source):
	queue_free()


func _on_EnemyHitbox_hitbox_entered():
	_stop_charging()
