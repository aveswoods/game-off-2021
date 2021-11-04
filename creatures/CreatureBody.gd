extends KinematicBody2D

class_name CreatureBody

signal collided_x
signal collided_y

var _physics_sources = []
# Is a list of dictionaries, containing the following key-value pairs
# - "velocity" : Vector2
# - "acceleration" : Vector2
# - "min_velocity" : Vector2
# - "max_velocity" : Vector2
# - "remove_on_zero" : bool
# - "remove_on_impact" : bool
# - "flip_on_impact" : bool


func add_physics_source(velocity: Vector2,
	acceleration: Vector2 = Vector2(0, 0),
	min_velocity: Vector2 = Vector2(-10000, -10000),
	max_velocity: Vector2 = Vector2(10000, 10000),
	remove_on_zero: bool = true,
	remove_on_impact: bool = true,
	flip_on_impact: bool = false
	):
	_physics_sources.append({
		"velocity": velocity,
		"acceleration": acceleration,
		"min_velocity": min_velocity,
		"max_velocity": max_velocity,
		"remove_on_zero": remove_on_zero,
		"remove_on_impact": remove_on_impact,
		"flip_on_impact": flip_on_impact
	})


func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	for i in range(_physics_sources.size()-1, -1, -1):
		var source = _physics_sources[i]
		
		# Add velocity source
		velocity += source["velocity"]
		
		# Update physics source
		source["velocity"] = clamp(
			source["velocity"] + source["acceleration"],
			source["min_velocity"],
			source["max_velocity"]
			)
		# Remove if appropriate
		if source["remove_on_zero"] and source["velocity"].is_equal_approx(Vector2(0, 0)):
			_physics_sources.remove(i)
		else:
			_physics_sources[i] = source
	
	# Checks for x collisions
	var collision_x = move_and_collide(delta * Vector2(velocity.x, 0), true, true, true)
	# Checks for y collisions
	var collision_y = move_and_collide(delta * Vector2(0, velocity.y), true, true, true)
	
	# Move based on velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if collision_x != null:
		for i in range(_physics_sources.size()-1, -1, -1):
			var source = _physics_sources[i]
			if source["remove_on_impact"]:
				_physics_sources.remove(i)
			elif source["flip_on_impact"]:
				source["velocity"].x *= -1
				_physics_sources[i] = source
		
		emit_signal("collided_x", collision_x)
	
	if collision_y != null:
		for i in range(_physics_sources.size()-1, -1, -1):
			var source = _physics_sources[i]
			if source["remove_on_impact"]:
				_physics_sources.remove(i)
			elif source["flip_on_impact"]:
				source["velocity"].y *= -1
				_physics_sources[i] = source
		
		emit_signal("collided_y", collision_y)
