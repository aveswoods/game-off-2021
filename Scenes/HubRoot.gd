extends Node2D

signal started
signal stopped
signal run_start_entered
signal item_selected(item_id)

onready var _room_hub = $RoomHub
onready var _room_run_portal = $RoomRunPortal
onready var _red_pedestal = $RoomRunPortal/StartingPedestalRed
onready var _green_pedestal = $RoomRunPortal/StartingPedestalGreen
onready var _blue_pedestal = $RoomRunPortal/StartingPedestalBlue
onready var _run_teleporter = $RoomRunPortal/Teleporter
onready var _tween = $Tween
export(NodePath) var player = null
onready var player_node = get_node(player)
onready var _player_start_location = player_node.position 
onready var _camera = $Camera2D

var _current_room = null
var _visible = false

func start():
	_run_teleporter.disable()
	_room_hub.enable_collisions()
	_room_hub.set_player(player_node)
	_room_hub.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_current_room = _room_hub
	_room_run_portal.enable_collisions()
	player_node.set_collision_layer_bit(0, true)
	player_node.set_collision_mask_bit(0, true)
	player_node.set_collision_mask_bit(1, true)
	player_node.position = _player_start_location
	_camera.current = true
	_visible = true
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		2.0,
		Tween.TRANS_LINEAR,
		0.5
	)
	_tween.start()

func stop():
	_room_hub.disable_collisions()
	_room_hub.remove_player()
	_room_run_portal.disable_collisions()
	_room_run_portal.remove_player()
	
	player_node.hide()
	player_node.disabled = true
	
	_visible = false
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		1.0,
		Tween.TRANS_LINEAR,Tween.EASE_IN,
		0.5
	)
	_tween.start()


func _ready():
	# Connect rooms
	_room_hub.north_adjacent_room_instance = _room_run_portal
	_room_hub.open_doorways()
	_room_run_portal.south_adjacent_room_instance = _room_hub
	_room_run_portal.open_doorways()
	
	# Listen for signals of items selected
	_red_pedestal.connect("selected", self, "_on_item_selected")
	_green_pedestal.connect("selected", self, "_on_item_selected")
	_blue_pedestal.connect("selected", self, "_on_item_selected")
	
	_room_hub.disable_collisions()
	_room_hub.remove_player()
	_room_run_portal.disable_collisions()
	_room_run_portal.remove_player()
	player_node.set_collision_layer_bit(0, false)
	player_node.set_collision_mask_bit(0, false)
	player_node.set_collision_mask_bit(1, false)
	player_node.visible = false
	player_node.disabled = true
	_visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)


func _set_limited_camera_position(cam_pos):
	var room_extents = _current_room.get_room_extents()
	var room_position = _current_room.position
	var viewport_extents = get_viewport().get_size()
	
	var target_location = Vector2.ZERO
	
	if viewport_extents.x > room_extents.x:
		target_location.x = room_position.x + room_extents.x / 2.0
	else:
		target_location.x = clamp(cam_pos.x, room_position.x + viewport_extents.x / 2.0, room_position.x + room_extents.x - viewport_extents.x / 2.0)
	
	if viewport_extents.y > room_extents.y:
		target_location.y = room_position.y + room_extents.y / 2.0
	else:
		target_location.y = clamp(cam_pos.y, room_position.y + viewport_extents.y / 2.0,  room_position.y + room_extents.y - viewport_extents.y / 2.0)
	
	_camera.position = target_location


func _on_RoomRunPortal_teleported(_destination):
	emit_signal("run_start_entered")


func _on_room_changed(new_room):
	_current_room = new_room


func _on_item_selected(item_id):
	_run_teleporter.enable()
	emit_signal("item_selected", item_id)


func _physics_process(_delta):
	if _visible and not _current_room.changing_rooms:
		_set_limited_camera_position(player_node.position)


func _on_Tween_tween_all_completed():
	if _visible:
		player_node.visible = true
		player_node.show()
		player_node.disabled = false
		_current_room.show_circuitboard()
		
		emit_signal("started")
	else:
		player_node.set_collision_layer_bit(0, false)
		player_node.set_collision_mask_bit(0, false)
		player_node.set_collision_mask_bit(1, false)
		player_node.visible = false
		
		emit_signal("stopped")
