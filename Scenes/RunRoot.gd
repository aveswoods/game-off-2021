extends Node2D

export(NodePath) var starting_room = null
var _current_room = null
var _adjacent_rooms = []
export(NodePath) var player = null
onready var player_node = get_node(player)


func _connect_adjacent_rooms():
	if _current_room.north_adjacent_room_instance != null:
		_adjacent_rooms.append(_current_room.north_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var adj_extents = _current_room.north_adjacent_room_instance.get_room_extents()
		_current_room.north_adjacent_room_instance.position = Vector2(0, -1 * adj_extents.y)
		# Add to tree
		add_child(_current_room.north_adjacent_room_instance)
		# Connect room changed signal
		_current_room.north_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
	
	if _current_room.east_adjacent_room_instance != null:
		_adjacent_rooms.append(_current_room.east_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var adj_extents = _current_room.east_adjacent_room_instance.get_room_extents()
		_current_room.east_adjacent_room_instance.position = Vector2(extents.x, 0)
		# Add to tree
		add_child(_current_room.east_adjacent_room_instance)
		# Connect room changed signal
		_current_room.east_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		
	if _current_room.south_adjacent_room_instance != null:
		_adjacent_rooms.append(_current_room.south_adjacent_room_instance)
	if _current_room.west_adjacent_room_instance != null:
		_adjacent_rooms.append(_current_room.west_adjacent_room_instance)


func _on_room_change(new_room):
	_current_room.remove_player()
	new_room.add_player(player_node)
	
	_current_room = new_room
	_current_room.camera.current = true
	_current_room.instance_adjacent_rooms()
	_connect_adjacent_rooms()


func _ready():
	_current_room = get_node(starting_room)
	_current_room.connect("room_changed", self, "_on_room_change")
	_current_room.instance_adjacent_rooms()
	_connect_adjacent_rooms()
	
	remove_child(player_node)
	_current_room.add_player(player_node)
	_current_room.camera.current = true
	#_current_room.set_camera_limits()
