extends Sprite

class_name CreatureSprite

signal finished_death_animation

# Death animation timer
var _death_animation_timer = Timer.new()

# Particles
var _explosion_particles = load("res://creatures/death_animations/explosion.tscn").instance()

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
	_death_animation_timer.start()

func animate_big_explode():
	emit_signal("finished_death_animation")

func animate_fade_away():
	emit_signal("finished_death_animation")

func animate_disintegrate():
	emit_signal("finished_death_animation")

func _ready():
	# Add death animation timer
	_death_animation_timer.one_shot = true
	_death_animation_timer.connect("timeout", self, "_on_death_timer_animation_timeout")
	add_child(_death_animation_timer)
	
	# Make particles to sprite's properties
	# TODO
	add_child(_explosion_particles)
	
	_shader_material = material

func _on_death_timer_animation_timeout():
	emit_signal("finished_death_animation")
