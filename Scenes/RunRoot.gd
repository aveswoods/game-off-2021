extends Node2D

export(NodePath) var starting_room = null
var _current_room = null
var _adjacent_rooms = []
export(NodePath) var player = null
onready var player_node = get_node(player)


func _spawn_adjacent_rooms():
	# Set up North room
	if _current_room.north_adjacent_room != null and _current_room.north_adjacent_room_instance == null:
		# Instantiate
		_current_room.north_adjacent_room_instance = _current_room.north_adjacent_room.instance()
		# Add to tree
		add_child(_current_room.north_adjacent_room_instance)
		# Add to array
		_adjacent_rooms.append(_current_room.north_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var doorway = _current_room.north_doorway_node
		var adj_extents = _current_room.north_adjacent_room_instance.get_room_extents()
		var adj_doorway = _current_room.north_adjacent_room_instance.south_doorway_node
		_current_room.north_adjacent_room_instance.position = Vector2(
			position.x + round((doorway.position.x - adj_doorway.position.x) / 32.0) * 32,
			position.y - adj_extents.y
			)
		# Connect room changed signal
		_current_room.north_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		# Open correct doorway
		_current_room.north_adjacent_room_instance.open_doorway(2)
		
		# Connect South room
		_current_room.north_adjacent_room_instance.south_adjacent_room_instance = _current_room
	
	# Set up East room
	if _current_room.east_adjacent_room != null and _current_room.east_adjacent_room_instance == null:
		# Instantiate
		_current_room.east_adjacent_room_instance = _current_room.east_adjacent_room.instance()
		# Add to tree
		add_child(_current_room.east_adjacent_room_instance)
		# Add to array
		_adjacent_rooms.append(_current_room.east_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var doorway = _current_room.east_doorway_node
		var adj_extents = _current_room.east_adjacent_room_instance.get_room_extents()
		var adj_doorway = _current_room.east_adjacent_room_instance.west_doorway_node
		_current_room.east_adjacent_room_instance.position = Vector2(
			position.x + extents.x,
			position.y + round((doorway.position.y - adj_doorway.position.y) / 32.0) * 32
			)
		# Connect room changed signal
		_current_room.east_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		# Open correct doorway
		_current_room.east_adjacent_room_instance.open_doorway(3)
		
		# Connect West room
		_current_room.east_adjacent_room_instance.west_adjacent_room_instance = _current_room
	
	# Set up South room
	if _current_room.south_adjacent_room != null and _current_room.south_adjacent_room_instance == null:
		# Instantiate
		_current_room.south_adjacent_room_instance = _current_room.south_adjacent_room.instance()
		# Add to tree
		add_child(_current_room.south_adjacent_room_instance)
		# Add to array
		_adjacent_rooms.append(_current_room.south_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var doorway = _current_room.south_doorway_node
		var adj_extents = _current_room.south_adjacent_room_instance.get_room_extents()
		var adj_doorway = _current_room.south_adjacent_room_instance.north_doorway_node
		_current_room.south_adjacent_room_instance.position = Vector2(
			position.x + round((doorway.position.x - adj_doorway.position.x) / 32.0) * 32,
			position.y + extents.y
			)
		# Connect room changed signal
		_current_room.south_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		# Open correct doorway
		_current_room.south_adjacent_room_instance.open_doorway(0)
		
		# Connect North room
		_current_room.south_adjacent_room_instance.north_adjacent_room_instance = _current_room
	
	# Set up West room
	if _current_room.west_adjacent_room != null and _current_room.west_adjacent_room_instance == null:
		# Instantiate
		_current_room.west_adjacent_room_instance = _current_room.west_adjacent_room.instance()
		# Add to tree
		add_child(_current_room.west_adjacent_room_instance)
		# Add to array
		_adjacent_rooms.append(_current_room.west_adjacent_room_instance)
		# Set position
		var extents = _current_room.get_room_extents()
		var doorway = _current_room.west_doorway_node
		var adj_extents = _current_room.west_adjacent_room_instance.get_room_extents()
		var adj_doorway = _current_room.west_adjacent_room_instance.east_doorway_node
		_current_room.west_adjacent_room_instance.position = Vector2(
			position.x - adj_extents.x,
			position.y + round((doorway.position.y - adj_doorway.position.y) / 32.0) * 32
			)
		# Connect room changed signal
		_current_room.west_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		# Open correct doorway
		_current_room.west_adjacent_room_instance.open_doorway(1)
		# Connect East room
		_current_room.west_adjacent_room_instance.east_adjacent_room_instance = _current_room


func _on_room_changed(new_room):
	_current_room = new_room
	#_current_room.close_doorways()
	_spawn_adjacent_rooms()
	_current_room.camera.current = true


func _ready():
	_current_room = get_node(starting_room)
	_current_room.east_adjacent_room = preload("res://Scenes/Rooms/test_room2.tscn")
	_current_room.west_adjacent_room = preload("res://Scenes/Rooms/test_room2.tscn")
	_current_room.connect("room_changed", self, "_on_room_changed")
	_spawn_adjacent_rooms()
	
	_current_room.set_player(player_node)
	_current_room.set_limited_camera_position(player_node.position)
	_current_room.camera.current = true
	
	# For testing
	_current_room.open_doorways()
