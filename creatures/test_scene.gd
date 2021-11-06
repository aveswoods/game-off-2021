extends Node2D

var lunge_action = load("res://creatures/player/abilities/lunge_action.tscn").instance()
var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()
var stun_passive = load("res://creatures/player/abilities/stomp_passive.tscn").instance()
var doublejump_passive = load("res://creatures/player/abilities/doublejump_passive.gd").new()

func _ready():
	lunge_action.equip($Player)
	bite_action.equip($Player)
	stun_passive.equip($Player)
	doublejump_passive.equip($Player)
	$Player.action1_script = lunge_action
	$Player.action2_script = bite_action
