extends Node2D

onready var _raycast_top = $RayCastTop
onready var _raycast_center = $RayCastCenter
onready var _raycast_bottom = $RayCastBottom
onready var _timer = $Timer

var shoot_damage = 1
var shoot_impact_impulse = 300
var _player = null
var _can_shoot = true
var _is_shooting = false
var _is_deadtime = false


func equip(player):
	_player = player
	_player.add_child(self)
	
	_raycast_top.add_exception(_player)
	_raycast_center.add_exception(_player)
	_raycast_bottom.add_exception(_player)
	_player.connect("damaged", self, "_on_player_damaged")


func trigger():
	if _can_shoot and _player.is_on_floor():
		_player.input_disabled = true
		_player.animation_tree.set("parameters/OneShot 2/active", 1)
		
		_is_shooting = true
		_can_shoot = false
		_timer.start()


func _on_player_damaged():
	if _is_shooting:
		_player.input_disabled = false
		_player.animation_tree.set("parameters/OneShot 2/active", 0)
		
		_is_shooting = false
		_is_deadtime = false
		_can_shoot = true


func _on_Timer_timeout():
	# Shoot at right time in animation
	if _is_shooting:
		if _player.is_facing_left():
			_raycast_top.cast_to.x = -1 * abs(_raycast_top.cast_to.x)
			_raycast_center.cast_to.x = -1 * abs(_raycast_center.cast_to.x)
			_raycast_bottom.cast_to.x = -1 * abs(_raycast_bottom.cast_to.x)
			_raycast_top.force_raycast_update()
			_raycast_center.force_raycast_update()
			_raycast_bottom.force_raycast_update()
		var collider_top = _raycast_top.get_collider()
		var collider_center = _raycast_center.get_collider()
		var collider_bottom = _raycast_bottom.get_collider()
		
		# Pick better collider
		var better_collider = null
		# If the top collider is an enemy, set better collider to the top collider
		if collider_top != null and not collider_top is TileMap and collider_top.is_in_group("enemy"):
			better_collider = collider_top
		# If center collider is correct type, compare is to current value of better collider
		if collider_center != null and not collider_center is TileMap and collider_center.is_in_group("enemy"):
			# Center collider is better if...
			# 1. Better collider is currently null, or
			# 2. Center collider is closer to point of origin than better collider
			if better_collider == null or (
				better_collider != null and (
					abs(better_collider.global_position.x - global_position.x)
					> abs(collider_center.global_position.x - global_position.x)
					)
				):
				better_collider = collider_center
		# If bottom collider is the correct type, compare it to the current value of better collider
		if collider_bottom != null and not collider_bottom is TileMap and collider_bottom.is_in_group("enemy"):
			# Same criteria as above
			if better_collider == null or (
				better_collider != null and (
					abs(better_collider.global_position.x - global_position.x)
					> abs(collider_bottom.global_position.x - global_position.x)
					)
				):
				better_collider = collider_bottom
		
		# Hit collider!
		if better_collider != null:
			print("hit enemy")
			var direction_x = -1 if _player.is_facing_left() else 1
			
			# Allow for Area2D hitbox detection
			if better_collider is Area2D:
				var parent = better_collider.get_parent()
				if parent is KinematicBody2D:
					parent.bump(shoot_impact_impulse * Vector2(direction_x, -1))
					parent.take_damage(shoot_damage, 0)
			# ...or simply collision with the physics body itself
			elif better_collider is KinematicBody2D:
				better_collider.bump(shoot_impact_impulse * Vector2(direction_x, -1))
				better_collider.take_damage(shoot_damage, 0)
		
		# Reset direction
		_raycast_top.cast_to.x = abs(_raycast_top.cast_to.x)
		_raycast_center.cast_to.x = abs(_raycast_center.cast_to.x)
		_raycast_bottom.cast_to.x = abs(_raycast_bottom.cast_to.x)
		
		# Give control back to the player
		_player.input_disabled = false
		
		# Start dead time
		_is_deadtime = true
		_is_shooting = false
		_timer.start()
	# Stop dead time
	elif _is_deadtime:
		_player.animation_tree.set("parameters/OneShot 2/active", 0)
		
		_is_deadtime = false
		_can_shoot = true
