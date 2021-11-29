extends Enemy

onready var _sprite = $CreatureSprite
onready var _animation_player = $AnimationPlayer
onready var _hitbox = $EnemyHitbox

const starting_hp = 2
const jump_impulse = 240
const jump_gravity_acceleration = 0.05
const bump_absorbance = 0.1
var facing_direction = 1
var _damaged = false

var _jumping = false
var _in_air = false
var _gravity = 0
var _idle_time = 0


func set_target_group(group):
	_hitbox.target_group = group


func _ready():
	randomize()
	
	hp = starting_hp
	acceleration = 0.25
	_idle_time = 0.5 * (1 + randi() % 4)
	_animation_player.play("idle")
	
	var start_direction = randi() % 2
	if start_direction == 0:
		_change_direction(-1)


func _change_direction(direction):
	if direction == 0:
		direction = 1
	
	facing_direction = direction
	_sprite.scale.x = direction


func _jump():
	bump(jump_impulse * Vector2(facing_direction * 0.5, -1))
	_gravity = 0
	gravity = _gravity
	friction = 0
	_in_air = true


func _physics_process(delta):
	# Mind controlled behavior
	if controlled:
		if Input.is_action_just_pressed("ui_left") and not _jumping:
			_change_direction(-1)
		elif Input.is_action_just_pressed("ui_right") and not _jumping:
			_change_direction(1)
		if Input.is_action_just_pressed("ui_up"):
			_animation_player.play("jump")
			_jumping = true
		elif Input.is_action_just_released("ui_up") and not _in_air:
			_animation_player.play("idle")
			_jumping = false
		if _jumping:
			if _in_air:
				_gravity = lerp(_gravity, 30, jump_gravity_acceleration)
				gravity = _gravity
	# Standard behavior
	else:
		if not stunned and not _damaged:
			_idle_time -= delta * Global.time_multiplier
			if _jumping:
				if _in_air:
					_gravity = lerp(_gravity, 30, jump_gravity_acceleration)
					gravity = _gravity
			elif _idle_time < 0:
				_animation_player.play("jump")
				_jumping = true


func _on_Grasshopper_collided_with_floor():
	if _in_air:
		_in_air = false
		friction = 0.25
		_idle_time = 0.5 * (1 + randi() % 3)
		if _jumping:
			_animation_player.play("land")
			_jumping = false

func _on_Grasshopper_collided_with_wall():
	_change_direction(-1 * facing_direction)
	bump(100 * Vector2(facing_direction, 0))
	velocity.x *= -1

func _on_Grasshopper_collided_with_body(collision):
	var direction = (global_position - collision.collider.global_position).normalized()
	bump(200 * direction)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"land":
			_animation_player.play("idle")
		"damaged":
			if not stunned:
				_animation_player.play("idle")
			_damaged = false


func _on_Grasshopper_damaged():
	_animation_player.play("damaged")
	_damaged = true
	gravity = 30


func _on_Grasshopper_stunned():
	_hitbox.monitoring = false
	_sprite.animate_stun()
	stunned = true
	_jumping = false
	_animation_player.play("damaged")


func _on_Grasshopper_unstunned():
	_hitbox.monitoring = true
	_sprite.animate_unstun()
	stunned = false
	_animation_player.play("idle")
	_idle_time = 0.5 * (1 + randi() % 2)


func _on_Grasshopper_killed(source):
	if not dead:
		dead = true
		_hitbox.set_deferred("monitoring", false)
		_animation_player.play("death")
	
		match source:
			death_source.IMPACT:
				_sprite.animate_explode()
			death_source.EXPLOSION:
				_sprite.animate_big_explode()
			death_source.ERASE:
				_sprite.animate_fade_away()
			death_source.WATER:
				_sprite.animate_disintegrate()


func _on_CreatureSprite_finished_death_animation():
	queue_free()
