extends Area2D
 
onready var _timer = $Timer

const lunge_velocity = Vector2(600, -300)
var lunge_damage = 0
var lunge_impact_impulse = 100
var _is_lunging = false
var _can_lunge = true
var _player = null


func equip(player):
	_player = player
	_player.add_child(self)
	_player.connect("collided_y", self, "_on_landing")


func trigger():
	if _can_lunge:
		# Determine velocity
		var directed_velocity = lunge_velocity
		if _player.is_facing_left():
			directed_velocity.x *= -1
			scale.x = -1
		# Update player velocity
		_player.velocity.x += directed_velocity.x
		_player.velocity.y = directed_velocity.y
		# Set local variables
		_is_lunging = true
		_can_lunge = false
		monitoring = true
		# Set player variables
		_player.invincible = true
		_player.input_disabled = true
		
		_timer.start()


func _physics_process(_delta):
	if _is_lunging:
		var x_velocity = lunge_velocity.x
		if _player.is_facing_left():
			x_velocity *= -1
		_player.velocity.x = x_velocity


func _on_landing():
	if not _can_lunge:
		_is_lunging = false
		_can_lunge = true


func _on_Timer_timeout():
	_is_lunging = false
	monitoring = false
	scale.x = 1
	_player.invincible = false
	_player.input_disabled = false
	if _player.is_on_floor():
		_can_lunge = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(
			lunge_damage,
			lunge_impact_impulse * (body.global_position - global_position + Vector2(0, -0.1)).normalized(),
			0.15
		)
