extends Enemy

signal erased

onready var _sprite = $Sprite
onready var _animation_player = $AnimationPlayer
onready var _animation_player_damaged = $AnimationPlayerDamaged
onready var _idle_shape = $CollisionShapeIdle
onready var _attack_shape = $CollisionShapeAttack
onready var _hitbox = $EnemyHitbox

enum states {
	IDLE,
	WALK,
	CHARGE,
	UP_ATTACK
	FAST_ATTACK,
	LUNGE_ATTACK,
	CONTROLLED,
	DEAD
}

const starting_hp = 20
const walk_speed = 100
const lunge_speed = 1000

var facing_direction = 1
var _state = states.IDLE
var _player = null
var _state_time = 0


func set_player(player):
	_player = player

func stun(_time : float):
	take_damage(1)
	if not stunned and not dead:
		.stun(0.5)


func _ready():
	randomize()
	
	hp = starting_hp
	friction = 0.25
	acceleration = 0.1
	_state = states.IDLE
	_state_time = 3
	_animation_player.play("idle")


func _change_direction(direction):
	if direction == 0:
		direction = 1
	
	_sprite.scale.x = direction
	_idle_shape.scale.x = direction
	_attack_shape.scale.x = direction
	_hitbox.scale.x = direction
	facing_direction = direction



func _physics_process(delta):
	if controlled:
		if _state != states.CONTROLLED:
			_state = states.CONTROLLED
			_state_time = 0.5
			_animation_player.play("damaged")
		else:
			_state_time -= delta
			if _state_time < 0:
				_player.take_damage(0)
				_player.bump(Vector2(0, -300))
				_state = states.UP_ATTACK
				_animation_player.play("attack up")
				take_damage(2)
		
	else:
		# Calculate direction of player relative to boss
		var player_direction = Vector2(1, 0)
		if _player != null:
			player_direction = (_player.global_position - global_position).normalized()
		
		# State logic
		match _state:
			states.IDLE:
				# Attack up if player is above
				if player_direction.y < -0.7:
					_state = states.UP_ATTACK
					_change_direction(sign(player_direction.x))
					_animation_player.play("attack up")
				
				_state_time -= delta * Global.time_multiplier
				# Pick next state if IDLE is over
				if _state_time < 0:
					var choice = randi() % 3
					if choice == 0:
						_state = states.WALK
						_state_time = 0.5 + 0.25 * (randi() % 3)
						_change_direction(sign(player_direction.x))
						_animation_player.play("walk")
					elif choice == 1:
						bump(Vector2(lunge_speed * facing_direction / 2.0, 0))
						_state_time = 0.75
						_state = states.FAST_ATTACK
						_animation_player.play("attack")
					else:
						_state = states.LUNGE_ATTACK
						_change_direction(sign(player_direction.x))
						_animation_player.play("charge")
			states.WALK:
				# Go back to idle after state finishes
				_state_time -= delta
				if _state_time < 0:
					_state = states.IDLE
					_state_time = 0.25 + 0.25 * (randi() % 3)
					_animation_player.play("idle")
				else:
					movement_velocity = walk_speed * Vector2(facing_direction, 0)
			states.FAST_ATTACK:
				# Go back to idle after state finishes
				_state_time -= delta
				if _state_time < 0:
					_state = states.IDLE
					_state_time = 0.25 + 0.25 * (randi() % 2)
					_change_direction(sign(player_direction.x))
					_animation_player.play("idle")
			states.LUNGE_ATTACK:
				if _animation_player.current_animation == "attack":
					movement_velocity = Vector2(lunge_speed * facing_direction, 0)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack up":
			_state = states.IDLE
			_state_time = 0.5
			_animation_player.play("idle")
		"charge":
			_animation_player.play("attack")
		"damaged":
			if not stunned and not controlled:
				_state = states.WALK
				_state_time = 0.5 + 0.25 * (randi() % 3)
				_animation_player.play("walk")


func _on_Gladiator_Boss_collided_with_wall():
	_change_direction(-1 * facing_direction)
	bump(Vector2(facing_direction * 400, 0))
	if _state == states.LUNGE_ATTACK:
		_animation_player.play("damaged")


func _on_Gladiator_Boss_stunned():
	stunned = true
	_animation_player.play("damaged")
	_hitbox.monitoring = false


func _on_Gladiator_Boss_unstunned():
	stunned = false
	_hitbox.monitoring = true
	_state = states.UP_ATTACK
	_animation_player.play("attack up")


func _on_Gladiator_Boss_damaged():
	_animation_player_damaged.play("damaged")


func _on_Gladiator_Boss_killed(_source):
	dead = true
	_state = states.DEAD
	bump(Vector2(0, -350))
	_hitbox.monitoring = false
	_animation_player.play("death")
	_animation_player_damaged.play("dead")


func _on_AnimationPlayerDamaged_animation_finished(anim_name):
	if anim_name == "dead":
		queue_free()
		emit_signal("erased")
