extends RayCast2D

onready var _timer = $Timer

var recharge_time = 4
var _player = null
var _player_gravity = 0
var _can_control = true
var _is_controlling = false
var _controlled_node = null


func equip(player):
	_player = player
	_player.add_child(self)
	
	_player.connect("damaged", self, "_on_player_damaged")
func unequip():
	if _player.is_connected("damaged", self, "_on_player_damaged"):
		_player.disconnect("damaged", self, "_on_player_damaged")
	_player.remove_child(self)
	_player = null


func trigger():
	# Take control of closest enemy directly below! Disable Player input and gravity
	var collider = get_collider()
	print(collider)
	if _can_control and collider != null and not collider is TileMap and collider.is_in_group("enemy"):
		# Take control
		_controlled_node = collider
		_controlled_node.controlled = true
		_controlled_node.set_target_group("enemy")
		# Adjust player
		_player.input_disabled = true
		_player_gravity = _player.gravity
		_player.velocity = Vector2.ZERO
		_player.gravity = 0
		
		_can_control = false
		_is_controlling = true


func _stop_controlling():
	# Remove control
	_controlled_node.controlled = false
	_controlled_node.set_target_group("player")
	_controlled_node = null
	# Adjust player
	_player.input_disabled = false
	_player.gravity = _player_gravity
	# Start recharge timer
	_timer.wait_time = recharge_time
	_timer.start()
	
	_is_controlling = false


func _physics_process(_delta):
	# Stop controlling if either action button is pressed
	if _is_controlling and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")):
		_stop_controlling()


func _on_player_damaged():
	if _is_controlling:
		_stop_controlling()


func _on_Timer_timeout():
	_can_control = true
