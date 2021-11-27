extends Node

onready var _run_root = $RunRoot
onready var _run_active_item_hud = $RunRoot/CanvasLayer/ActiveItemsHUD
onready var _hub_root = $HubRoot
onready var _timer = $Timer

const game_over_timer = 4

var _starting_item_selected = ""

func _ready():
	VisualServer.set_default_clear_color(Color("#27232a"))
	randomize()
	SaveData.load_data()
	
	_hub_root.start()


func _on_HubRoot_item_selected(item_id):
	_starting_item_selected = item_id
	print("equipped " + str(item_id))


func _on_HubRoot_run_start_entered():
	# If there is a seed...
	var seed_int = randi() % 100000
	seed(seed_int)
	print("Seed: " + str(seed_int))
	
	# Update item pool
	Items.reset_item_pool()
	# Equip starting item to add ability paths to item pool
	Items.set_player(_run_root.player_node)
	Items.equip_item(_starting_item_selected, 1) # Set it to first active item if applicable
	# Add it to HUD box 1, if applicable
	if Items.is_active(_starting_item_selected):
		_run_active_item_hud.set_item(1, _starting_item_selected)
	
	var start_time = OS.get_ticks_usec()
	_run_root.call_deferred("setup_run")
	print(str((OS.get_ticks_usec() - start_time) / 1000.0) + " ms")
	_run_root.call_deferred("start")


func _on_RunRoot_player_killed():
	_run_root.stop()
	_timer.wait_time = game_over_timer
	_timer.start()


func _on_Timer_timeout():
	Items.unequip_all()
	_hub_root.start()
