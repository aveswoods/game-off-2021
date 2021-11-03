extends Node2D

var lunge_action = load("res://creatures/player/actions/lunge_action.tscn").instance()
var bite_action = load("res://creatures/player/actions/bite_action.tscn").instance()

func _ready():
	lunge_action.equip($Player)
	bite_action.equip($Player)
	$Player.action1_script = lunge_action
	$Player.action2_script = bite_action
