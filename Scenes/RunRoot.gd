extends Node2D

signal player_killed

const door_open_space = Vector2(30, 20)

var _current_room = null
var _loaded_rooms = []
export(NodePath) var player = null
onready var player_node = get_node(player)
onready var _camera = $Camera2D
onready var _tween = $Tween
var _visible = false


func start():
	# Make player active
	player_node.set_collision_layer_bit(0, true)
	player_node.set_collision_mask_bit(0, true)
	player_node.set_collision_mask_bit(1, true)
	player_node.visible = true
	player_node.disabled = false
	player_node.input_disabled = true
	player_node.hp = player_node.base_hp + Global.bonus_hp
	# Make scene visible
	_visible = true
	_current_room.set_player(player_node)
	_current_room.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_camera.current = true
	
	_tween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		1.0
	)
	_tween.start()
	
	SaveData.num_runs += 1
	SaveData.save_data()


func stop():
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


func setup_run():
	# Generate first room with correct starting door
	# Place adjacent rooms, breadth first, avoiding overlaps
	# Only "branch" three times
	# Place rooms until max number of rooms is reached
	# Last three rooms placed will be boss room and two prize rooms
	var rooms = []
	var taken_space = {} # Dict of coordinates that are occupied
	var max_tries = 50
	
	var num_rooms = 1
	var max_rooms = 14 + randi() % 4 # Arbitrary...
	var branching_room1 = randi() % 2 # Rooms left until it branches
	var branching_room2 = branching_room1 + int(max_rooms / 3) + randi() % 2 # Rooms left until it branches
	
	# Set up first room
	rooms.append(RoomInfo.get_random_starting_room())
	rooms[0].previous_direction = -1
	rooms[0].position = Vector2(0, 0)
	for i in rooms[0].extents.x:
		for j in rooms[0].extents.y:
			taken_space[(str(i) + "," + str(j))] = true
	
	# Prepare it in the scene, this is done to adjacent rooms in _spawn_adjacent_rooms
	_current_room = rooms[0].room.instance()
	rooms[0].instance = _current_room
	add_child(_current_room)
	_current_room.position = Vector2(0, 0)
	_loaded_rooms.append(_current_room)
	_current_room.connect("room_changed", self, "_on_room_changed")
	
	# Close appropriate door
	_current_room.open_doorways()
	
	# Add player to correct spot
	player_node.position = _current_room.player_start_location
	
	# Loop through the remaining rooms
	# For every case in this loop, all elements of rooms are rooms that have been added to the scene
	# already. For an entry in rooms, it must have its adjacent room(s) picked, then it must call
	# _spawn_adjacent_rooms, and finally it must add its adjacent room(s) to the array rooms
	while rooms.size() > 0: #num_rooms < max_rooms:
		var room = rooms.pop_front()
		
		# Room variables
		var north_room = null
		var east_room = null
		var south_room = null
		var west_room = null
		
		# --------------
		# | NORTH LOOP |
		# --------------
		if room.has("north_door_pos") and room.previous_direction != 2:
			var type = 1
			if branching_room1 == 0 or branching_room2 == 0:
				type = 2
				if branching_room1 == branching_room2:
					branching_room2 += 1
			elif num_rooms >= max_rooms - 3:
				type = 0
			var valid_room = false
			var new_room = null
			var new_pos = Vector2(0, 0)
			var tries = 0
			# Pick a new valid room
			while not valid_room and tries < max_tries:
				tries += 1
				new_room = RoomInfo.get_random_room(0, type) # Get north room
				# Check if it overlaps with rooms, by checking that certain points are not taken
				new_pos = Vector2(
					room.position.x + room.north_door_pos.x - new_room.south_door_pos.x,
					room.position.y - new_room.extents.y
				)
				if _is_open_space(taken_space, new_pos, new_room.extents):
					# Check if new doors have room for new rooms
					if ((not new_room.has("north_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y - door_open_space.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
						and
						(not new_room.has("east_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x + new_room.extents.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
						and
						(not new_room.has("west_door_pos") or _is_open_space(
							taken_space,
#							Vector2(new_pos.x - door_open_space.x, new_pos.y - new_room.west_door_pos.y + door_open_space.y),
#							door_open_space
							Vector2(new_pos.x - door_open_space.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
					):
						valid_room = true
						print("Valid north room")
			
			if tries == max_tries:
				branching_room1 = 0
				room.instance.north_doorway_node.permanently_closed = true
				print("Could not pick valid north room")
			else:
				# From here, the room is valid
				new_room.previous_direction = 0
				new_room.position = new_pos
				for i in new_room.extents.x:
					for j in new_room.extents.y:
						taken_space[(str(new_pos.x + i) + "," + str(new_pos.y + j))] = true
				
				room.instance.north_adjacent_room = new_room.room
				num_rooms += 1
				branching_room1 -= 1
				branching_room2 -= 1
				# Assign variable for connecting with dict objects
				north_room = new_room
		
		# -------------
		# | EAST LOOP |
		# -------------
		if room.has("east_door_pos") and room.previous_direction != 3:
			var type = 1
			if branching_room1 == 0 or branching_room2 == 0:
				type = 2
				if branching_room1 == branching_room2:
					branching_room2 += 1
			elif num_rooms >= max_rooms - 3:
				type = 0
			var valid_room = false
			var new_room = null
			var new_pos = Vector2(0, 0)
			var tries = 0
			# Pick a new valid room
			while not valid_room and tries < max_tries:
				tries += 1
				new_room = RoomInfo.get_random_room(1, type) # Get east room
				# Check if it overlaps with rooms, by checking that certain points are not taken
				new_pos = Vector2(
					room.position.x + room.extents.x,
					room.position.y + room.east_door_pos.y - new_room.west_door_pos.y
				)
				if _is_open_space(taken_space, new_pos, new_room.extents):
					valid_room = true
					# Check if new doors have room for new rooms
					if ((not new_room.has("north_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y - door_open_space.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
						and
						(not new_room.has("east_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x + new_room.extents.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
						and
						(not new_room.has("south_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y + new_room.extents.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
					):
						valid_room = true
						print("Valid east room")
			
			if tries == max_tries:
				branching_room1 = 0
				room.instance.east_doorway_node.permanently_closed = true
				print("Could not pick valid east room")
			else:
				# From here, the room is valid
				new_room.previous_direction = 1
				new_room.position = new_pos
				for i in new_room.extents.x:
					for j in new_room.extents.y:
						taken_space[(str(new_pos.x + i) + "," + str(new_pos.y + j))] = true
				
				room.instance.east_adjacent_room = new_room.room
				num_rooms += 1
				branching_room1 -= 1
				branching_room2 -= 1
				# Assign variable for connecting with dict objects
				east_room = new_room
		
		# --------------
		# | SOUTH LOOP |
		# --------------
		if room.has("south_door_pos") and room.previous_direction != 0:
			var type = 1
			if branching_room1 == 0 or branching_room2 == 0:
				type = 2
				if branching_room1 == branching_room2:
					branching_room2 += 1
			elif num_rooms >= max_rooms - 3:
				type = 0
			var valid_room = false
			var new_room = null
			var new_pos = Vector2(0, 0)
			var tries = 0
			# Pick a new valid room
			while not valid_room and tries < max_tries:
				tries += 1
				new_room = RoomInfo.get_random_room(2, type) # Get south room
				# Check if it overlaps with rooms, by checking that certain points are not taken
				new_pos = Vector2(
					room.position.x + room.south_door_pos.x - new_room.north_door_pos.x,
					room.position.y + room.extents.y
				)
				if _is_open_space(taken_space, new_pos, new_room.extents):
					if ((not new_room.has("east_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x + new_room.extents.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
						and
						(not new_room.has("south_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y + new_room.extents.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
						and
						(not new_room.has("west_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x - door_open_space.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
					):
						valid_room = true
						print("Valid south room")
			
			if tries == max_tries:
				branching_room1 = 0
				room.instance.south_doorway_node.permanently_closed = true
				print("Could not pick valid south room")
			else:
				# From here, the room is valid
				new_room.previous_direction = 2
				new_room.position = new_pos
				for i in new_room.extents.x:
					for j in new_room.extents.y:
						taken_space[(str(new_pos.x + i) + "," + str(new_pos.y + j))] = true
				
				room.instance.south_adjacent_room = new_room.room
				num_rooms += 1
				branching_room1 -= 1
				branching_room2 -= 1
				# Assign variable for connecting with dict objects
				south_room = new_room
		
		# -------------
		# | WEST LOOP |
		# -------------
		if room.has("west_door_pos") and room.previous_direction != 1:
			var type = 1
			if branching_room1 == 0 or branching_room2 == 0:
				type = 2
				if branching_room1 == branching_room2:
					branching_room2 += 1
			elif num_rooms >= max_rooms - 3:
				type = 0
			var valid_room = false
			var new_room = null
			var new_pos = Vector2(0, 0)
			var tries = 0
			# Pick a new valid room
			while not valid_room and tries < max_tries:
				tries += 1
				new_room = RoomInfo.get_random_room(3, type) # Get east room
				# Check if it overlaps with rooms, by checking that certain points are not taken
				new_pos = Vector2(
					room.position.x - new_room.extents.x,
					room.position.y + room.west_door_pos.y - new_room.east_door_pos.y
				)
				if _is_open_space(taken_space, new_pos, new_room.extents):
					if ((not new_room.has("north_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y - door_open_space.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
						and
						(not new_room.has("south_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x, new_pos.y + new_room.extents.y),
							Vector2(new_room.extents.x, door_open_space.y)
						))
						and
						(not new_room.has("west_door_pos") or _is_open_space(
							taken_space,
							Vector2(new_pos.x - door_open_space.x, new_pos.y),
							Vector2(door_open_space.x, new_room.extents.y)
						))
					):
						valid_room = true
						print("Valid west room")
			
			if tries == max_tries:
				branching_room1 = 0
				room.instance.west_doorway_node.permanently_closed = true
				print("Could not pick valid west room")
			else:
				# From here, the room is valid
				new_room.previous_direction = 3
				new_room.position = new_pos
				for i in new_room.extents.x:
					for j in new_room.extents.y:
						taken_space[(str(new_pos.x + i) + "," + str(new_pos.y + j))] = true
				
				room.instance.west_adjacent_room = new_room.room
				num_rooms += 1
				branching_room1 -= 1
				branching_room2 -= 1
				# Assign variable for connecting with dict objects
				west_room = new_room
		
		
		# All rooms have been picked and connected, so spawn them (instantiate them)
		_spawn_adjacent_rooms(room.instance)
		# ..and hook up to room dict objects
		if north_room != null:
			north_room.instance = room.instance.north_adjacent_room_instance
			room.instance.open_doorway(0)
			north_room.instance.open_doorway(2)
			rooms.append(north_room)
		if east_room != null:
			east_room.instance = room.instance.east_adjacent_room_instance
			room.instance.open_doorway(1)
			east_room.instance.open_doorway(3)
			rooms.append(east_room)
		if south_room != null:
			south_room.instance = room.instance.south_adjacent_room_instance
			room.instance.open_doorway(2)
			south_room.instance.open_doorway(0)
			rooms.append(south_room)
		if west_room != null:
			west_room.instance = room.instance.west_adjacent_room_instance
			room.instance.open_doorway(3)
			west_room.instance.open_doorway(1)
			rooms.append(west_room)
	
	# Final check, if seed is bad, start it allll over!
	if num_rooms < max_rooms:
		for room in _loaded_rooms:
			remove_child(room)
		_loaded_rooms = []
		setup_run()


func _ready():
	player_node.set_collision_layer_bit(0, false)
	player_node.set_collision_mask_bit(0, false)
	player_node.set_collision_mask_bit(1, false)
	player_node.visible = false
	player_node.disabled = true
	_visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)


func _is_open_space(taken_space : Dictionary, pos : Vector2, extents : Vector2):
	for i in extents.x:
		for j in extents.y:
			if taken_space.has(str(pos.x + i) + "," + str(pos.y + j)):
				return false
	return true


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


func _spawn_adjacent_rooms(room):
	# Set up North room
	if room.north_adjacent_room != null and room.north_adjacent_room_instance == null:
		# Instantiate
		room.north_adjacent_room_instance = room.north_adjacent_room.instance()
		# Add to tree
		add_child(room.north_adjacent_room_instance)
		# Add to array
		_loaded_rooms.append(room.north_adjacent_room_instance)
		# Set position
		var doorway = room.north_doorway_node
		var adj_extents = room.north_adjacent_room_instance.get_room_extents()
		var adj_doorway = room.north_adjacent_room_instance.south_doorway_node
		room.north_adjacent_room_instance.position = Vector2(
			room.position.x + round((doorway.position.x - adj_doorway.position.x) / 32.0) * 32,
			room.position.y - adj_extents.y
			)
		# Connect room changed signal
		room.north_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		
		# Connect South room
		room.north_adjacent_room_instance.south_adjacent_room_instance = room
	
	# Set up East room
	if room.east_adjacent_room != null and room.east_adjacent_room_instance == null:
		# Instantiate
		room.east_adjacent_room_instance = room.east_adjacent_room.instance()
		# Add to tree
		add_child(room.east_adjacent_room_instance)
		# Add to array
		_loaded_rooms.append(room.east_adjacent_room_instance)
		# Set position
		var extents = room.get_room_extents()
		var doorway = room.east_doorway_node
		var adj_doorway = room.east_adjacent_room_instance.west_doorway_node
		room.east_adjacent_room_instance.position = Vector2(
			room.position.x + extents.x,
			room.position.y + round((doorway.position.y - adj_doorway.position.y) / 32.0) * 32
			)
		# Connect room changed signal
		room.east_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		
		# Connect West room
		room.east_adjacent_room_instance.west_adjacent_room_instance = room
	
	# Set up South room
	if room.south_adjacent_room != null and room.south_adjacent_room_instance == null:
		# Instantiate
		room.south_adjacent_room_instance = room.south_adjacent_room.instance()
		# Add to tree
		add_child(room.south_adjacent_room_instance)
		# Add to array
		_loaded_rooms.append(room.south_adjacent_room_instance)
		# Set position
		var extents = room.get_room_extents()
		var doorway = room.south_doorway_node
		var adj_doorway = room.south_adjacent_room_instance.north_doorway_node
		room.south_adjacent_room_instance.position = Vector2(
			room.position.x + round((doorway.position.x - adj_doorway.position.x) / 32.0) * 32,
			room.position.y + extents.y
			)
		# Connect room changed signal
		room.south_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		
		# Connect North room
		room.south_adjacent_room_instance.north_adjacent_room_instance = room
	
	# Set up West room
	if room.west_adjacent_room != null and room.west_adjacent_room_instance == null:
		# Instantiate
		room.west_adjacent_room_instance = room.west_adjacent_room.instance()
		# Add to tree
		add_child(room.west_adjacent_room_instance)
		# Add to array
		_loaded_rooms.append(room.west_adjacent_room_instance)
		# Set position
		var doorway = room.west_doorway_node
		var adj_extents = room.west_adjacent_room_instance.get_room_extents()
		var adj_doorway = room.west_adjacent_room_instance.east_doorway_node
		room.west_adjacent_room_instance.position = Vector2(
			room.position.x - adj_extents.x,
			room.position.y + round((doorway.position.y - adj_doorway.position.y) / 32.0) * 32
			)
		# Connect room changed signal
		room.west_adjacent_room_instance.connect("room_changed", self, "_on_room_changed")
		
		# Connect East room
		room.west_adjacent_room_instance.east_adjacent_room_instance = room


func _on_room_changed(new_room):
	_current_room = new_room


func _physics_process(_delta):
	if _visible and not _current_room.changing_rooms:
		_set_limited_camera_position(player_node.position)


func _on_Tween_tween_all_completed():
	if _visible:
		player_node.input_disabled = false
	else:
		player_node.set_collision_layer_bit(0, false)
		player_node.set_collision_mask_bit(0, false)
		player_node.set_collision_mask_bit(1, false)
		player_node.visible = false
		player_node.disabled = true
		player_node.reset()
		
		for room in _loaded_rooms:
			remove_child(room)
		_loaded_rooms = []


func _on_Player_killed():
	emit_signal("player_killed")
