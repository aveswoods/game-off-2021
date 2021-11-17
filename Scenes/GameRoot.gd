extends Node

onready var _background_color = $BackgroundColor
onready var _run_root = $RunRoot

var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()


func _ready():
	VisualServer.set_default_clear_color(_background_color.color)
	bite_action.equip(_run_root.player_node)
	_run_root.player_node.action1_script = bite_action
