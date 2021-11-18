extends Node

onready var _background_color = $BackgroundColor
onready var _run_root = $RunRoot
onready var _hub_root = $HubRoot

var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()

func _ready():
	VisualServer.set_default_clear_color(_background_color.color)
	randomize()
	SaveData.load_data()
	
	_hub_root.start()


func _on_HubRoot_run_start_entered():
	# If there is a seed...
	var seed_int = randi() % 100000
	seed(seed_int)
	print("Seed: " + str(seed_int))
	var start_direction = 1 #randi() % 4
	
	# Equip starting weapon; TODO
	# Update item pool
	Items.reset_item_pool()
	# Equip starting item to add ability paths to item pool
	Items.set_player(_run_root.player_node)
	Items.equip_item("bite")
	
	
	var start_time = OS.get_ticks_usec()
	_run_root.call_deferred("setup_run", start_direction)
	print(str((OS.get_ticks_usec() - start_time) / 1000.0) + " ms")
	_run_root.call_deferred("start")
