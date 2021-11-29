extends Node2D

signal started
signal stopped
signal player_killed
signal player_wins

onready var _camera = $Camera2D
onready var _tween = $Tween
onready var _heart_hud = $CanvasLayer/HeartHUD
onready var _active_items_hud = $CanvasLayer/ActiveItemsHUD

var player_node = null
var _visible = false
var _current_room = null
var _boss = null
var _win_teleporter


func setup(player):
	_current_room = RoomInfo.get_random_boss_room().instance()
	
	player_node = _current_room.get_node("Player")
	player_node.disabled = true
	player_node.hp = player.hp
	
	_boss = _current_room.get_node("Boss")
	_boss.set_player(player_node)
	_boss.disabled = true
	
	_win_teleporter = _current_room.get_node("WinTeleporter")
	
	add_child(_current_room)
	
	player_node.connect("killed", self, "_on_player_killed")
	player_node.connect("damaged", self, "_on_player_damaged")
	_boss.connect("erased", self, "_on_boss_erased")
	_win_teleporter.connect("player_wins", self, "_on_player_wins")


func start():
	_heart_hud.open(player_node.base_hp + Global.bonus_hp, player_node.hp)
	_active_items_hud.open()
	_current_room.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_camera.current = true
	_current_room.show_circuitboard()
	player_node.show()
	_visible = true
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		0.25
	)
	_tween.start()


func stop():
	player_node.disconnect("killed", self, "_on_player_killed")
	player_node.disconnect("damaged", self, "_on_player_damaged")
	if _boss != null:
		_boss.disconnect("erased", self, "_on_boss_erased")
	_win_teleporter.disconnect("player_wins", self, "_on_player_wins")
	_current_room.hide_circuitboard()
	_visible = false
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		2.0,
		Tween.TRANS_LINEAR,Tween.EASE_IN,
		2.0
	)
	_tween.start()


func fast_stop():
	player_node.disconnect("killed", self, "_on_player_killed")
	player_node.disconnect("damaged", self, "_on_player_damaged")
	if _boss != null:
		_boss.disconnect("erased", self, "_on_boss_erased")
	_win_teleporter.disconnect("player_wins", self, "_on_player_wins")
	player_node.hide()
	_current_room.hide_circuitboard()
	_visible = false
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,Tween.EASE_IN,
		0.5
	)
	_tween.start()


func _ready():
	_visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)


func _physics_process(_delta):
	if _visible:
		_set_limited_camera_position(player_node.position)


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


func _on_Tween_tween_all_completed():
	if _visible:
		player_node.disabled = false
		_boss.disabled = false
		
		emit_signal("started")
	else:
		_heart_hud.close()
		_active_items_hud.close()
		_active_items_hud.remove_items()
		
		remove_child(_current_room)
		player_node = null
		_boss = null
		_current_room = null
		
		emit_signal("stopped")


func _on_player_damaged():
	_heart_hud.damage()

func _on_player_killed():
	_heart_hud.damage()
	emit_signal("player_killed")

func _on_boss_erased():
	_win_teleporter.enable()
	_boss = null

func _on_player_wins():
	emit_signal("player_wins")
