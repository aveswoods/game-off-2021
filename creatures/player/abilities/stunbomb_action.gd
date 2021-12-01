extends Node2D

signal recharging
signal charged

onready var _bomb = $BombArea
onready var _timer = $Timer

var recharge_time = 3
var _player = null
var _launching = false
var _recharging = false


func equip(player):
	_player = player
	_player.add_child(self)
	
	remove_child(_bomb)
	_player.get_parent().add_child(_bomb)
func unequip():
	_player.get_parent().remove_child(_bomb)
	add_child(_bomb)
	
	_player.remove_child(self)
	_player = null


func trigger():
	if not _launching and not _recharging:
		var direction = Vector2(1, 0)
		if _player.is_facing_left():
			direction.x = -1
		_bomb.position = _player.position + 20 * direction
		_bomb.launch(direction)
		
		_launching = true
		
		emit_signal("recharging")


func _on_BombArea_impacted():
	_launching = false
	_recharging = true
	_timer.wait_time = recharge_time
	_timer.start()


func _on_Timer_timeout():
	_recharging = false
	emit_signal("charged")
