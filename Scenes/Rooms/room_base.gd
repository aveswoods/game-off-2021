extends Node2D

# Base for a Room
# 
# SETUP:
#
# TileMap MUST have its top-left corner at (0, 0). i.e., EVERY tile must be in positive
# coordinates
# Each connected room MUST have a Doorway! Doorways should be placed on the EDGE of the room

signal room_changed(room)
signal teleported(destination)

onready var _tile_map_floor = $TileMapFloor
onready var _room_change_timer = $RoomChangeTimer
onready var _tween = $Tween

# Public variables
var changing_rooms = false
var changing_velocity = Vector2.ZERO

#export(Vector2) var player_start_location = Vector2.ZERO
# Adjacent rooms are Scenes, Doorways are Area2Ds, where if the player enters them, the camera is
# moved to the next room
var north_adjacent_room = null
var north_adjacent_room_instance = null
export(NodePath) var north_doorway = null
var north_doorway_node = null
var east_adjacent_room = null
var east_adjacent_room_instance = null
export(NodePath) var east_doorway = null
var east_doorway_node = null
var south_adjacent_room = null
var south_adjacent_room_instance = null
export(NodePath) var south_doorway = null
var south_doorway_node = null
var west_adjacent_room = null
var west_adjacent_room_instance = null
export(NodePath) var west_doorway = null
var west_doorway_node = null

# Internal variables
var _room_extents = Vector2.ZERO
var _enemies_node = null
var _has_enemies = false
var _player = null
var _next_room = null
var _teleporter = null
var _pedestal = null


func disable_collisions():
	_tile_map_floor.set_collision_layer_bit(0, false)
	_tile_map_floor.set_collision_layer_bit(1, false)
	_tile_map_floor.set_collision_layer_bit(2, false)
func enable_collisions():
	_tile_map_floor.set_collision_layer_bit(0, true)
	_tile_map_floor.set_collision_layer_bit(1, true)
	_tile_map_floor.set_collision_layer_bit(2, true)


func show_room(delay : float = 0.0):
	# If there is a pedestal, set the item
	if _pedestal != null and not _pedestal.is_item_set():
		var item_id = Items.get_random_item_id_from_pool()
		if item_id != "":
			_pedestal.set_item(item_id)
	
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		delay
	)
	_tween.start()

func hide_room(delay : float = 0.0):
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		#Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		delay
	)
	_tween.start()


func set_player(player):
	_player = player

func remove_player():
	_player = null


func get_room_extents():
	return Vector2(_room_extents.x, _room_extents.y)


func close_doorway(direction : int):
	match direction:
		0:
			if north_doorway_node != null:
				north_doorway_node.close()
		1:
			if east_doorway_node != null:
				east_doorway_node.close()
		2:
			if south_doorway_node != null:
				south_doorway_node.close()
		3:
			if west_doorway_node != null:
				west_doorway_node.close()

func close_doorways():
	if north_doorway_node != null:
		north_doorway_node.close()
	if east_doorway_node != null:
		east_doorway_node.close()
	if south_doorway_node != null:
		south_doorway_node.close()
	if west_doorway_node != null:
		west_doorway_node.close()


func open_doorway(direction : int):
	match direction:
		0:
			if north_doorway_node != null:
				north_doorway_node.open()
		1:
			if east_doorway_node != null:
				east_doorway_node.open()
		2:
			if south_doorway_node != null:
				south_doorway_node.open()
		3:
			if west_doorway_node != null:
				west_doorway_node.open()

func open_doorways():
	if north_doorway_node != null:
		north_doorway_node.open()
	if east_doorway_node != null:
		east_doorway_node.open()
	if south_doorway_node != null:
		south_doorway_node.open()
	if west_doorway_node != null:
		west_doorway_node.open()


func change_rooms(room_instance):
	_next_room = room_instance
	changing_rooms = true
	_next_room.changing_rooms = true
	_player.input_disabled = true
	
	hide_room(0.25)
	_next_room.show_room()
	
	_room_change_timer.start()


func _ready():
	# Connect doorways to their functions
	if north_doorway != null:
		north_doorway_node = get_node(north_doorway)
		north_doorway_node.connect("body_entered", self, "_north_doorway_entered")
	if east_doorway != null:
		east_doorway_node = get_node(east_doorway)
		east_doorway_node.connect("body_entered", self, "_east_doorway_entered")
	if south_doorway != null:
		south_doorway_node = get_node(south_doorway)
		south_doorway_node.connect("body_entered", self, "_south_doorway_entered")
	if west_doorway != null:
		west_doorway_node = get_node(west_doorway)
		west_doorway_node.connect("body_entered", self, "_west_doorway_entered")

	# Set room extents
	var used_rect = _tile_map_floor.get_used_rect()
	var tile_size = _tile_map_floor.cell_size
	_room_extents = Vector2(used_rect.end.x * tile_size.x, used_rect.end.y * tile_size.y)
	# Set if has enemies
	_enemies_node = get_node_or_null("Enemies")
	if _enemies_node != null:
		_has_enemies = _enemies_node.has_enemies()
	# Set signal connection
	_teleporter = get_node_or_null("Teleporter")
	if _teleporter != null:
		_teleporter.connect("teleported", self, "_on_teleported")
	# Set pedestal, if applicable
	_pedestal = get_node_or_null("Pedestal")
	
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	#modulate = Color(1.0, 1.0, 1.0, 1.0)


func _north_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms and _player != null:
		changing_velocity = Vector2(0, -1 * 300)
		change_rooms(north_adjacent_room_instance)
func _east_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms and _player != null:
		changing_velocity = Vector2(_player.move_speed, 0)
		change_rooms(east_adjacent_room_instance)
func _south_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms and _player != null:
		changing_velocity = Vector2(0, 300)
		change_rooms(south_adjacent_room_instance)
func _west_doorway_entered(body):
	if body.is_in_group("player") and not changing_rooms and _player != null:
		changing_velocity = Vector2(-1 * _player.move_speed, 0)
		change_rooms(west_adjacent_room_instance)


func _set_overlay_color(color : Color):
	material.set_shader_param("overlay", color)


func _on_RoomChangeTimer_timeout():
	changing_rooms = false
	_next_room.changing_rooms = false
	_player.input_disabled = false
	_next_room.set_player(_player)
	remove_player()
	
	if _next_room._has_enemies:
		_next_room._enemies_node.enable()
		_next_room.close_doorways()
	
	emit_signal("room_changed", _next_room)


func _physics_process(_delta):
	if _player != null and changing_rooms:
			_player.velocity = changing_velocity


func _on_enemies_killed():
	_has_enemies = false
	open_doorways()


func _on_teleported(destination):
	emit_signal("teleported", destination)
