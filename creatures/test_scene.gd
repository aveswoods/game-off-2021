extends Node2D

# Actions
var lunge_action = load("res://creatures/player/abilities/lunge_action.tscn").instance()
var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()
var blue_action = load("res://creatures/player/abilities/blue_action.tscn").instance()
var charm_action = load("res://creatures/player/abilities/charm_action.tscn").instance()
var mindcontrol_action = load("res://creatures/player/abilities/mindcontrol_action.tscn").instance()
var slowmo_action = load("res://creatures/player/abilities/slowmo_action.tscn").instance()
var shoot_action = load("res://creatures/player/abilities/shoot_action.tscn").instance()
# Passives
var stun_passive = load("res://creatures/player/abilities/stomp_passive.tscn").instance()
var doublejump_passive = load("res://creatures/player/abilities/doublejump_passive.gd").new()
var walljump_passive = load("res://creatures/player/abilities/walljump_passive.tscn").instance()
var glide_passive = load("res://creatures/player/abilities/glide_passive.gd").new()

func _ready():
	#lunge_action.equip($Player)
	#bite_action.equip($Player)
	#blue_action.equip($Player)
	#charm_action.equip($Player)
	mindcontrol_action.equip($Player)
	#slowmo_action.equip($Player)
	shoot_action.equip($Player)
	stun_passive.equip($Player)
	#doublejump_passive.equip($Player)
	#walljump_passive.equip($Player)
	glide_passive.equip($Player)
	#$Player.action1_script = lunge_action
	#$Player.action1_script = bite_action
	#$Player.action2_script = blue_action
	#$Player.action2_script = charm_action
	$Player.action2_script = mindcontrol_action
	#$Player.action2_script = slowmo_action
	$Player.action1_script = shoot_action
	
