extends Node

onready var _run_root = $RunRoot
onready var _run_active_item_hud = $RunRoot/CanvasLayer/ActiveItemsHUD
onready var _item_display_hud = $CanvasLayer/ItemDisplayHUD
onready var _hub_root = $HubRoot
onready var _boss_active_item_hud = $BossRoot/CanvasLayer/ActiveItemsHUD
onready var _boss_root = $BossRoot
onready var _controls_text = $CanvasLayer/RichTextLabel
onready var _controls_timer = $ControlsTimer
onready var _tween = $Tween

var _starting_item_selected = ""
var _current_root = ""
var _player_idle = false


func _ready():
	VisualServer.set_default_clear_color(Color("#27232a"))
	randomize()
	SaveData.load_data()
	
	# Connect Item signals with active item HUD
	Items.connect("recharging", self, "_on_active_item_recharging")
	Items.connect("charged", self, "_on_active_item_charged")
	Items.connect("equipped", self, "_on_item_equipped")
	
	# Set up color overlay for effects
	Global.color_overlay = $CanvasLayer/ColorRect
	
	# Hide controls text
	_controls_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	_current_root = "hub"
	_hub_root.start()
	_player_idle = true


func _input(event):
	if _current_root == "hub" and _player_idle:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			_player_idle = false
			
			_tween.interpolate_property(
			_controls_text,
			"modulate",
			_controls_text.modulate,
			Color(1.0, 1.0, 1.0, 0.0),
			1.0,
			Tween.TRANS_QUAD,Tween.EASE_OUT
			)
			_tween.start()


func _on_item_equipped(item_id):
	var is_active = Items.is_active(item_id)
	_item_display_hud.open(item_id, is_active)
	if not is_active:
		Items.equip_item(item_id)


func _on_active_item_recharging(action_num):
	if action_num != 1 and action_num != 2:
		return
	if _current_root == "run":
		_run_active_item_hud.inactive(action_num)
	elif _current_root == "boss":
		_boss_active_item_hud.inactive(action_num)


func _on_active_item_charged(action_num):
	if action_num != 1 and action_num != 2:
		return
	if _current_root == "run":
		_run_active_item_hud.active(action_num)
	elif _current_root == "boss":
		_boss_active_item_hud.active(action_num)


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


func _on_HubRoot_item_selected(item_id):
	_starting_item_selected = item_id
	_item_display_hud.open(item_id)
	print("equipped " + str(item_id))


func _on_HubRoot_run_start_entered():
	_hub_root.stop()
	
	_current_root = "run"


func _on_RunRoot_player_killed():
	_run_root.stop()
	_current_root = "hub"


func _on_RunRoot_boss_room_entered():
	_boss_root.setup(_run_root.player_node) # Instantiates room and player
	_boss_active_item_hud.set_item(1, _run_active_item_hud.get_item_id(1))
	_boss_active_item_hud.set_item(2, _run_active_item_hud.get_item_id(2))
	_run_root.fast_stop()
	_current_root = "boss"
	
	Items.set_player(_boss_root.player_node)


func _on_BossRoot_player_killed():
	_boss_root.stop()
	_current_root = "hub"


func _on_BossRoot_player_wins():
	_boss_root.fast_stop()
	_current_root = "hub"


func _on_HubRoot_started():
	_controls_timer.start()

func _on_HubRoot_stopped():
	if _current_root == "run":
		# If there is a seed...
		var seed_int = randi() % 1000000
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


func _on_RunRoot_started():
	pass # Replace with function body.

func _on_RunRoot_stopped():
	if _current_root == "hub":
		Items.unequip_all()
		_hub_root.start()
		_player_idle = true
	elif _current_root == "boss":
		_boss_root.start()


func _on_BossRoot_started():
	pass # Replace with function body.

func _on_BossRoot_stopped():
	if _current_root == "hub":
		Items.unequip_all()
		_hub_root.start()
		_player_idle = true


func _on_ControlsTimer_timeout():
	if _player_idle:
		_tween.interpolate_property(
			_controls_text,
			"modulate",
			Color(1.0, 1.0, 1.0, 0.0),
			Color(1.0, 1.0, 1.0, 1.0),
			1.0,
			Tween.TRANS_QUAD,Tween.EASE_OUT
		)
		_tween.start()
