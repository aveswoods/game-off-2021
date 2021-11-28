extends Node

onready var _run_root = $RunRoot
onready var _run_active_item_hud = $RunRoot/CanvasLayer/ActiveItemsHUD
onready var _item_display_hud = $CanvasLayer/ItemDisplayHUD
onready var _hub_root = $HubRoot
onready var _timer = $Timer

const game_over_timer = 4

var _starting_item_selected = ""
var _current_root = ""

func _ready():
	VisualServer.set_default_clear_color(Color("#27232a"))
	randomize()
	SaveData.load_data()
	
	# Connect Item signals with active item HUD
	Items.connect("recharging", self, "_on_active_item_recharging")
	Items.connect("charged", self, "_on_active_item_charged")
	Items.connect("equipped", self, "_on_item_equipped")
	
	_current_root = "hub"
	_hub_root.start()


func _on_item_equipped(item_id):
	var is_active = Items.is_active(item_id)
	_item_display_hud.open(item_id, is_active)
	if not is_active:
		Items.equip_item(item_id)


func _on_active_item_recharging(action_num):
	if action_num == 1:
		_run_active_item_hud.inactive(action_num)
	elif action_num == 2:
		_run_active_item_hud.inactive(action_num)

func _on_active_item_charged(action_num):
	if action_num == 1:
		_run_active_item_hud.active(action_num)
	elif action_num == 2:
		_run_active_item_hud.active(action_num)


func _on_HubRoot_item_selected(item_id):
	_starting_item_selected = item_id
	_item_display_hud.open(item_id)
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
	_current_root = "run"
	_run_root.call_deferred("start")


func _on_RunRoot_player_killed():
	_run_root.stop()
	_timer.wait_time = game_over_timer
	_timer.start()


func _on_Timer_timeout():
	Items.unequip_all()
	_current_root = "hub"
	_hub_root.start()


func _on_ItemDisplayHUD_opened():
	match _current_root:
		"hub":
			_hub_root.player_node.input_disabled = true
		"run":
			_run_root.player_node.input_disabled = true


func _on_ItemDisplayHUD_closed():
	match _current_root:
		"hub":
			_hub_root.player_node.input_disabled = false
		"run":
			_run_root.player_node.input_disabled = false


func _on_ItemDisplayHUD_active_slot_picked(item_id, slot_num):
	if _current_root == "run":
		Items.equip_item(item_id, slot_num)
		_run_active_item_hud.set_item(slot_num, item_id)
