extends Node2D

signal recharging
signal charged

onready var _particles = $CPUParticles2D
onready var _timer = $Timer

onready var _audio = $Audio

var _player = null
var slow_mo_time = 5
var time_multiplier = 0.25
var recharge_time = 5
var _can_slow_mo = true
var _is_recharging = false


func equip(player):
	_player = player
	_player.add_child(self)
func unequip():
	_player.remove_child(self)
	_player = null
	
	Global.time_multiplier = 1.0


func trigger():
	if _can_slow_mo:
		Global.time_multiplier = time_multiplier
		_timer.wait_time = slow_mo_time
		_timer.start()
		_can_slow_mo = false
		
		# Animate
		_particles.emitting = true
		Global.flash_color_overlay(Color("#78f2ff66"))
		
		# Play audio
		_audio.play()


func _on_Timer_timeout():
	if _is_recharging:
		_can_slow_mo = true
		_is_recharging = false
		emit_signal("charged")
	else:
		Global.time_multiplier = 1.0
		_timer.wait_time = recharge_time
		_timer.start()
		_is_recharging = true
		emit_signal("recharging")
