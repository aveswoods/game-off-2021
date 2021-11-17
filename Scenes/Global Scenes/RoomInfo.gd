extends Node

# Rooms
# ---
# Contains information needed for generating a level map without instancing rooms.
#
# Extents: rectangular size of a room in number of tiles
#
# ""_Door_Pos: The position of a room's door in number of tiles. Since doorways are two tiles,
# the location is the top tile (if a vertical door) or the left tile (if horizontal door)
# No need to include a position if the door does not exist
const rooms = {
	"01": {
		"room": preload("res://Scenes/Rooms/room01.tscn"),
		"extents": Vector2(18, 14),
		"east_door_pos": Vector2(17, 8),
		"south_door_pos": Vector2(11, 13),
		"west_door_pos": Vector2(0, 8)
	},
	"02": {
		"room": preload("res://Scenes/Rooms/room02.tscn"),
		"extents": Vector2(18, 7),
		"east_door_pos": Vector2(17, 3),
		"west_door_pos": Vector2(0, 3)
	},
	"03": {
		"room": preload("res://Scenes/Rooms/room03.tscn"),
		"extents": Vector2(18, 14),
		"north_door_pos": Vector2(4, 0),
		"west_door_pos": Vector2(0, 10)
	},
	"04": {
		"room": preload("res://Scenes/Rooms/room04.tscn"),
		"extents": Vector2(18, 16),
		"north_door_pos": Vector2(8, 0),
		"south_door_pos": Vector2(14, 15)
	},
	"05": {
		"room": preload("res://Scenes/Rooms/room05.tscn"),
		"extents": Vector2(18, 13),
		"east_door_pos": Vector2(17, 9),
		"south_door_pos": Vector2(8, 12)
	},
	"06": {
		"room": preload("res://Scenes/Rooms/room06.tscn"),
		"extents": Vector2(18, 15),
		"south_door_pos": Vector2(8, 14),
		"west_door_pos": Vector2(0, 8)
	},
	"07": {
		"room": preload("res://Scenes/Rooms/room07.tscn"),
		"extents": Vector2(22, 13),
		"north_door_pos": Vector2(10, 0),
		"east_door_pos": Vector2(21, 9)
	}
}

const ids_with_north_doors = [
	"03",
	"04",
	"07"
]

const ids_with_east_doors = [
	"01",
	"02",
	"05",
	"07"
]

const ids_with_south_doors = [
	"01",
	"04",
	"05",
	"06"
]

const ids_with_west_doors = [
	"01",
	"02",
	"03",
	"06"
]

# Rooms that have three or four doorways are in here
const branches = [
	"01"
]

# Rooms that have only one doorway are in here
const deadends = [
	
]

# Gets a random room dict. The room will have a door in the specified direction.
# direction: the "going to" direction; (N, E, S, W) = (0, 1, 2, 3)
# type: (deadend, hallway, branch) = (0, 1, 2)
static func get_random_room(direction : int, type : int):
	var valid_room = false
	var room_id = null
	var room_pool = null
	match direction:
		0: room_pool = ids_with_south_doors
		1: room_pool = ids_with_west_doors
		2: room_pool = ids_with_north_doors
		3: room_pool = ids_with_east_doors
	
	while not valid_room:
		room_id = room_pool[randi() % room_pool.size()]
		var is_branch = room_id in branches
		var is_deadend = room_id in deadends
		match type:
			0:
				if is_deadend:
					valid_room = true
			1:
				if not is_deadend and not is_branch:
					valid_room = true
			2:
				if is_branch:
					valid_room = true
	#print("Picked room id " + str(room_id))
	
	return rooms[room_id].duplicate()
