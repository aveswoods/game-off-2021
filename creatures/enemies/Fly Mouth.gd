extends Enemy

onready var _sprite = $CreatureSprite
onready var _animation_player = $AnimationPlayer
onready var _hitbox = $EnemyHitbox
onready var _visionbox = $AreaVision

onready var _audio_impact = $AudioImpact

const starting_hp = 3
const walk_speed = 20
const fly_speed = 180
const bump_absorbance = 0.1
var facing_direction = 1
var _damaged = false

var _walking = false
var _idle_time = 0
var _target = null


func set_target_group(group):
	_hitbox.target_group = group
	_target = null


func _ready():
	randomize()
	
	hp = starting_hp
	flying = true
	friction = 0.05
	acceleration = 0.95
	gravity = 0
	_idle_time = 2 + randi() % 3
	_animation_player.play("idle")
	
	var start_direction = randi() % 2
	if start_direction == 0:
		_change_direction(-1)


func _change_direction(direction):
	if direction == 0:
		direction = 1
	
	facing_direction = direction
	_sprite.scale.x = direction
	_hitbox.scale.x = direction


func _bump_away(direction):
	bump(fly_speed * direction)


func _physics_process(delta):
	# Mind controlled behavior
	if controlled:
		if not _damaged:
			var idle = true
			if Input.is_action_pressed("ui_left"):
				movement_velocity.x += -1 * fly_speed
				_change_direction(-1)
				idle = false
			if Input.is_action_pressed("ui_right"):
				movement_velocity.x += fly_speed
				_change_direction(1)
				idle = false
			if Input.is_action_pressed("ui_up"):
				movement_velocity.y += -1 * fly_speed
				idle = false
			if Input.is_action_pressed("ui_down"):
				movement_velocity.y += fly_speed
				idle = false
			if idle and _animation_player.current_animation != "idle":
				_animation_player.play("idle")
			elif not idle and _animation_player.current_animation != "walk":
				_animation_player.play("walk")
	# Standard behavior
	else:
		if not stunned and not _damaged:
			if _target != null:
				var target_displacement = _target.global_position - global_position
				movement_velocity = fly_speed * target_displacement.normalized()
				if target_displacement.length() < 60:
					_animation_player.play("attack")
				else:
					if _animation_player.current_animation != "walk":
						_animation_player.play("walk")
					_change_direction(sign(target_displacement.x))
			else:
				_idle_time -= delta * Global.time_multiplier
				if _idle_time < 0:
					if _animation_player.current_animation == "walk":
						_animation_player.play("idle")
						_idle_time = 3 + randi() % 2
						_walking = false
					else:
						_animation_player.play("walk")
						_idle_time = 1 + randi() % 2
						var change_direction = randi() % 2
						if change_direction == 1:
							_change_direction(-1 * facing_direction)
						_walking = true
				else:
					if _walking:
						movement_velocity = Vector2(facing_direction * walk_speed, 0)


func _on_AreaVision_body_entered(body):
	if body.is_in_group(_hitbox.target_group) and _target == null:
		_target = body

func _on_AreaVision_body_exited(body):
	if body == _target:
		_target = null
	var overlapping_bodies = _visionbox.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		var shortest_distance = 10000000
		for i in range(1, overlapping_bodies.size()):
			var distance = (global_position - overlapping_bodies[i].global_position).length()
			if distance < shortest_distance and overlapping_bodies[i] != self and overlapping_bodies[i].is_in_group(_hitbox.target_group):
				_target = overlapping_bodies[i]
				print(_target)
				shortest_distance = distance


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			if _target != null:
				_animation_player.play("walk")
			else:
				_animation_player.play("idle")
		"damaged":
			if not stunned:
				if _target != null:
					_animation_player.play("walk")
				else:
					_animation_player.play("idle")
			_damaged = false


func _on_Fly_Mouth_collided_with_body(collision):
	_bump_away((global_position - collision.collider.global_position).normalized())
	_audio_impact.play()


func _on_Fly_Mouth_collided_with_ceiling():
	_bump_away(Vector2.DOWN)
	_audio_impact.play()
func _on_Fly_Mouth_collided_with_floor():
	_bump_away(Vector2.UP)
	_audio_impact.play()


func _on_Fly_Mouth_damaged():
	_animation_player.play("damaged")
	_damaged = true


func _on_Fly_Mouth_stunned():
	_hitbox.monitoring = false
	_sprite.animate_stun()
	stunned = true
	_walking = false
	_animation_player.play("damaged")


func _on_Fly_Mouth_unstunned():
	_hitbox.monitoring = true
	_sprite.animate_unstun()
	if _target != null:
		_animation_player.play("walk")
	else:
		_animation_player.play("idle")
	stunned = false


func _on_Fly_Mouth_killed(source):
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
