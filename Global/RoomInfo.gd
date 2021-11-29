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
const room_dict_template = {
	"id": {
		"room": preload("res://Scenes/Rooms/room_base.tscn"),
		"extents": Vector2(0, 0),
		"north_door_pos": Vector2(0, 0),
		"east_door_pos": Vector2(0, 0),
		"south_door_pos": Vector2(0, 0),
		"west_door_pos": Vector2(0, 0)
	}
}

const rooms = {
	"start_north": {
		"room": preload("res://Scenes/Rooms/Run/room_start_north.tscn"),
		"extents": Vector2(12, 9),
		"south_door_pos": Vector2(5, 8)
	},
	"start_east": {
		"room": preload("res://Scenes/Rooms/Run/room_start_east.tscn"),
		"extents": Vector2(12, 7),
		"west_door_pos": Vector2(0, 3)
	},
	"start_south": {
		"room": preload("res://Scenes/Rooms/Run/room_start_south.tscn"),
		"extents": Vector2(12, 9),
		"north_door_pos": Vector2(5, 0)
	},
	"start_west": {
		"room": preload("res://Scenes/Rooms/Run/room_start_west.tscn"),
		"extents": Vector2(12, 7),
		"east_door_pos": Vector2(11, 3)
	},
	
	"item_north": {
		"room": preload("res://Scenes/Rooms/Run/room_item_north.tscn"),
		"extents": Vector2(14, 12),
		"south_door_pos": Vector2(6, 11)
	},
	"item_east": {
		"room": preload("res://Scenes/Rooms/Run/room_item_east.tscn"),
		"extents": Vector2(14, 10),
		"west_door_pos": Vector2(0, 7)
	},
	"item_south": {
		"room": preload("res://Scenes/Rooms/Run/room_item_south.tscn"),
		"extents": Vector2(14, 12),
		"north_door_pos": Vector2(6, 0)
	},
	"item_west": {
		"room": preload("res://Scenes/Rooms/Run/room_item_west.tscn"),
		"extents": Vector2(14, 10),
		"east_door_pos": Vector2(13, 7)
	},
	
	"01": {
		"room": preload("res://Scenes/Rooms/Run/room01.tscn"),
		"extents": Vector2(18, 14),
		"east_door_pos": Vector2(17, 8),
		"south_door_pos": Vector2(11, 13),
		"west_door_pos": Vector2(0, 8)
	},
	"02": {
		"room": preload("res://Scenes/Rooms/Run/room02.tscn"),
		"extents": Vector2(18, 7),
		"east_door_pos": Vector2(17, 3),
		"west_door_pos": Vector2(0, 3)
	},
	"03": {
		"room": preload("res://Scenes/Rooms/Run/room03.tscn"),
		"extents": Vector2(18, 14),
		"north_door_pos": Vector2(4, 0),
		"west_door_pos": Vector2(0, 10)
	},
	"04": {
		"room": preload("res://Scenes/Rooms/Run/room04.tscn"),
		"extents": Vector2(18, 16),
		"north_door_pos": Vector2(8, 0),
		"south_door_pos": Vector2(14, 15)
	},
	"05": {
		"room": preload("res://Scenes/Rooms/Run/room05.tscn"),
		"extents": Vector2(18, 13),
		"east_door_pos": Vector2(17, 9),
		"south_door_pos": Vector2(8, 12)
	},
	"06": {
		"room": preload("res://Scenes/Rooms/Run/room06.tscn"),
		"extents": Vector2(18, 15),
		"south_door_pos": Vector2(8, 14),
		"west_door_pos": Vector2(0, 8)
	},
	"07": {
		"room": preload("res://Scenes/Rooms/Run/room07.tscn"),
		"extents": Vector2(22, 13),
		"north_door_pos": Vector2(10, 0),
		"east_door_pos": Vector2(21, 9),
		"west_door_pos": Vector2(0, 9)
	},
	"08": {
		"room": preload("res://Scenes/Rooms/Run/room08.tscn"),
		"extents": Vector2(14, 12),
		"north_door_pos": Vector2(11, 0),
		"west_door_pos": Vector2(0, 8)
	},
	"09": {
		"room": preload("res://Scenes/Rooms/Run/room09.tscn"),
		"extents": Vector2(15, 14),
		"south_door_pos": Vector2(11, 13),
		"west_door_pos": Vector2(0, 2)
	},
	"10": {
		"room": preload("res://Scenes/Rooms/Run/room10.tscn"),
		"extents": Vector2(13, 15),
		"east_door_pos": Vector2(12, 1),
		"south_door_pos": Vector2(2, 14),
	},
	"11": {
		"room": preload("res://Scenes/Rooms/Run/room11.tscn"),
		"extents": Vector2(17, 13),
		"north_door_pos": Vector2(2, 0),
		"east_door_pos": Vector2(16, 9)
	},
	"12": {
		"room": preload("res://Scenes/Rooms/Run/room12.tscn"),
		"extents": Vector2(18, 17),
		"north_door_pos": Vector2(8, 0),
		"east_door_pos": Vector2(17, 7),
		"south_door_pos": Vector2(4, 16)
	},
	"13": {
		"room": preload("res://Scenes/Rooms/Run/room13.tscn"),
		"extents": Vector2(18, 17),
		"north_door_pos": Vector2(9, 0),
		"south_door_pos": Vector2(5, 16),
		"west_door_pos": Vector2(0, 7)
	}
}

const ids_with_north_doors = [
	"item_south",
	"03",
	"04",
	"07",
	"08",
	"11",
	"12",
	"13"
]

const ids_with_east_doors = [
	"item_west",
	"01",
	"02",
	"05",
	"07",
	"10",
	"11",
	"12"
]

const ids_with_south_doors = [
	"item_north",
	"01",
	"04",
	"05",
	"06",
	"09",
	"10",
	"12",
	"13"
]

const ids_with_west_doors = [
	"item_east",
	"01",
	"02",
	"03",
	"06",
	"07",
	"08",
	"09",
	"13"
]

# Rooms that have three or four doorways are in here
const branches = [
	"01",
	"07",
	"12",
	"13"
]

# Rooms that have only one doorway are in here
const deadends = [
	"item_north",
	"item_east",
	"item_south",
	"item_west"
]

# Rooms that the run begins in
const starting_rooms = [
	"start_north",
	"start_east",
	"start_south",
	"start_west"
]

const boss_rooms = [
	preload("res://Scenes/Rooms/Boss/GladiatorBossRoom.tscn")
]


static func get_random_starting_room():
	var room_id = starting_rooms[randi() % starting_rooms.size()]
	return rooms[room_id].duplicate()


static func get_random_boss_room():
	return boss_rooms[randi() % boss_rooms.size()].duplicate()


# Gets a random room dict. The room will have a door in the specified direction.
# direction: the "going to" direction; (N, E, S, W) = (0, 1, 2, 3)
# type: (deadend, hallway, branch, boss) = (0, 1, 2)
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
	
	return rooms[room_id].duplicate()
