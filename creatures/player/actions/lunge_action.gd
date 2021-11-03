extends Timer

const lunge_velocity = Vector2(600, -300)
var _is_lunging = false
var _can_lunge = true
var _player = null


func setup(player):
	_player = player
	_player.connect("collided_y", self, "_on_landing")


func trigger():
	if _can_lunge:
		var directed_velocity = lunge_velocity
		if _player.is_facing_left():
			directed_velocity.x *= -1
		_player.velocity.x += directed_velocity.x
		_player.velocity.y = directed_velocity.y
		_is_lunging = true
		_can_lunge = false
		_player.invincible = true
		_player.input_disabled = true
		start()


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

func _on_lunge_action_timeout():
	_player.invincible = false
	_is_lunging = false
	_player.input_disabled = false
	if _player.is_on_floor():
		_can_lunge = true
