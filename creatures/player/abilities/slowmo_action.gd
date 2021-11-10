extends Node2D

onready var _timer = $Timer

var _player = null
var slow_mo_time = 5
var time_multiplier = 0.25
var recharge_time = 5
var _can_slow_mo = true
var _is_recharging = false


func equip(player):
	_player = player
	_player.add_child(self)


func trigger():
	if _can_slow_mo:
		Global.time_multiplier = time_multiplier
		_timer.wait_time = slow_mo_time
		_timer.start()
		_can_slow_mo = false


func _on_Timer_timeout():
	if _is_recharging:
		_can_slow_mo = true
		_is_recharging = false
	else:
		Global.time_multiplier = 1.0
		_timer.wait_time = recharge_time
		_timer.start()
		_is_recharging = true
