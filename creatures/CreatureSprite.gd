extends Sprite

class_name CreatureSprite

signal finished_death_animation

# Death animation
var _death_animation_timer = Timer.new()
var _tween = Tween.new()

# Particles
var _explosion_particles = load("res://particle effects/explosion.tscn").instance()
var _big_explosion_particles = load("res://particle effects/big_explosion.tscn").instance()

# Other variables
var _dimensions = Vector2.ZERO
var _shader_material = null


func flip_h(flipped):
	if flipped:
		scale.x = -1
	else:
		scale.x = 1


func animate_take_damage():
	pass

func animate_stun():
	_shader_material.set_shader_param("stunned", true)

func animate_unstun():
	_shader_material.set_shader_param("stunned", false)

func animate_explode():
	_explosion_particles.emitting = true
	_death_animation_timer.wait_time = 1.25
	_death_animation_timer.start()
	_tween.interpolate_method(
		self,
		"_set_shader_overlay",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_EXPO,Tween.EASE_OUT
	)
	_tween.interpolate_property(
		self,
		"scale",
		Vector2(1, 1),
		Vector2(0.25, 4),
		0.25,
		Tween.TRANS_BACK,Tween.EASE_IN,
		0.25
	)
	_tween.interpolate_method(
		self,
		"_set_shader_transparency",
		1.0,
		0.0,
		0.25,
		Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,
		0.25
	)
	_tween.start()

func animate_big_explode():
	_big_explosion_particles.emitting = true
	_death_animation_timer.wait_time = 1
	_death_animation_timer.start()
	_tween.interpolate_method(
		self,
		"_set_shader_overlay",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_EXPO,Tween.EASE_OUT
	)
	_tween.interpolate_property(
		self,
		"scale",
		Vector2(1, 1),
		Vector2(2, 2),
		0.5,
		Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	_tween.interpolate_method(
		self,
		"_set_shader_transparency",
		1.0,
		0.0,
		0.5,
		Tween.TRANS_LINEAR,Tween.EASE_IN_OUT
	)
	_tween.start()

func animate_fade_away():
	emit_signal("finished_death_animation")

func animate_disintegrate():
	emit_signal("finished_death_animation")


func _set_shader_overlay(color : Color):
	_shader_material.set_shader_param("overlay", color)

func _set_shader_transparency(transparency : float):
	_shader_material.set_shader_param("transparency", transparency)


func _ready():
	# Setup dimensions
	_dimensions = texture.get_size()
	
	# Add death animation timer
	_death_animation_timer.one_shot = true
	_death_animation_timer.connect("timeout", self, "_on_death_timer_animation_timeout")
	add_child(_death_animation_timer)
	# Add tween
	add_child(_tween)
	
	# Make particles to sprite's properties
	var num_particles = int(sqrt(_dimensions.x * _dimensions.y))
	# Explosion
	_explosion_particles.amount = num_particles
	_explosion_particles.emission_rect_extents = _dimensions / 2.0
	add_child(_explosion_particles)
	# Big explosion
	_big_explosion_particles.amount = num_particles
	_big_explosion_particles.initial_velocity = 6 * num_particles
	_big_explosion_particles.linear_accel = -5 * num_particles
	add_child(_big_explosion_particles)
	
	_shader_material = material

func _on_death_timer_animation_timeout():
	emit_signal("finished_death_animation")
