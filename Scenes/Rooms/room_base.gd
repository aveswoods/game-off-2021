extends Node2D

signal room_changed(room)

onready var camera = $Camera2D
onready var _tile_map_floor = $TileMapFloor
onready var _tween = $Tween

# Camera variables
var _cam_acceleration = 0.07
var changing_rooms = false

export(Vector2) var player_start_location = Vector2.ZERO
# Adjacent rooms are Scenes, Doorways are Area2Ds, where if the player enters them, the camera is
# moved to the next room
export(PackedScene) var north_adjacent_room = null
var north_adjacent_room_instance = null
export(NodePath) var north_doorway = null
var _north_doorway_node = null
export(PackedScene) var east_adjacent_room = null
var east_adjacent_room_instance = null
export(NodePath) var east_doorway = null
var _east_doorway_node = null
export(PackedScene) var south_adjacent_room = null
var south_adjacent_room_instance = null
export(NodePath) var south_doorway = null
var _south_doorway_node = null
export(PackedScene) var west_adjacent_room = null
var west_adjacent_room_instance = null
export(NodePath) var west_doorway = null
var _west_doorway_node = null

# Internal variables
var _room_extents = Vector2.ZERO
var _player = null
var _next_room = null


func add_player(player):
	_player = player
	player.position = player_start_location
	add_child(_player)


func remove_player():
	if _player != null:
		remove_child(_player)


func get_room_extents():
	return Vector2(_room_extents.x, _room_extents.y)


func set_camera_limits():
	var used_rect = _tile_map_floor.get_used_rect()
	var tile_size = _tile_map_floor.cell_size
	camera.limit_top = position.y + used_rect.position.y * tile_size.y + tile_size.y / 2
	camera.limit_left = position.x + used_rect.position.x * tile_size.x + tile_size.x / 2
	camera.limit_bottom = position.y + used_rect.end.y * tile_size.y - tile_size.y / 2
	camera.limit_right = position.x + used_rect.end.x * tile_size.x - tile_size.x / 2


func remove_camera_limits():
	camera.limit_top = -10000000
	camera.limit_left = -10000000
	camera.limit_bottom = 10000000
	camera.limit_right = 10000000


func instance_adjacent_rooms():
	# Load adjacent room scenes
	if north_adjacent_room != null:
		north_adjacent_room_instance = north_adjacent_room.instance()
	if east_adjacent_room != null:
		print("instancing east adj rooms")
		east_adjacent_room_instance = east_adjacent_room.instance()
	if south_adjacent_room != null:
		south_adjacent_room_instance = south_adjacent_room.instance()
	if west_adjacent_room != null:
		west_adjacent_room_instance = west_adjacent_room.instance()


func change_rooms(room_instance):
	_next_room = room_instance
	
	changing_rooms = true
	_next_room.changing_rooms = true
	
	# Remove camera limits so they do not affect camera transitions
	remove_camera_limits()
	#_next_room.remove_camera_limits()
	
	# Slide camera to correct position
	_tween.interpolate_property(
		camera,
		"position",
		camera.position,
		Vector2(
			clamp(_next_room.position.x + _next_room.camera.position.x, _next_room.camera.limit_left, _next_room.camera.limit_right),
			clamp(_next_room.position.y + _next_room.camera.position.y, _next_room.camera.limit_top, _next_room.camera.limit_bottom)
		),
		1.0,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	_tween.start()


func _ready():
	# Connect doorways to their functions
	if north_doorway != null:
		_north_doorway_node = get_node(north_doorway)
		_north_doorway_node.connect("body_entered", self, "_north_doorway_entered")
	if east_doorway != null:
		_east_doorway_node = get_node(east_doorway)
		_east_doorway_node.connect("body_entered", self, "_east_doorway_entered")
	if south_doorway != null:
		_south_doorway_node = get_node(south_doorway)
		_south_doorway_node.connect("body_entered", self, "_south_doorway_entered")
	if west_doorway != null:
		_west_doorway_node = get_node(west_doorway)
		_west_doorway_node.connect("body_entered", self, "_west_doorway_entered")
	
	# Set room extents
	var used_rect = _tile_map_floor.get_used_rect()
	var tile_size = _tile_map_floor.cell_size
	_room_extents = Vector2(used_rect.end.x * tile_size.x, used_rect.end.y * tile_size.y)
	
	# Set Camera posiiton
	camera.position = player_start_location
	set_camera_limits()


func _north_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms:
		change_rooms(north_adjacent_room_instance)
func _east_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms:
		change_rooms(east_adjacent_room_instance)
func _south_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms:
		change_rooms(south_adjacent_room_instance)
func _west_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms:
		change_rooms(west_adjacent_room_instance)


func _physics_process(_delta):
	if _player != null and not changing_rooms:
		camera.position = lerp(camera.position, _player.position, _cam_acceleration)


func _on_room_change_tween_completed():
	emit_signal("room_changed", _next_room)
	changing_rooms = false
	_next_room.changing_rooms = false
