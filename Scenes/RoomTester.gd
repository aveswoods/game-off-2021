extends Node2D

onready var _camera = $Camera2D
onready var _player = $Player
export(NodePath) var room = null
var _current_room = null


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


func _ready():
	randomize()
	VisualServer.set_default_clear_color(Color("#27232a"))
	
	_player.hp = 5
	
	_current_room = get_node(room)
	_current_room.close_doorways()
	_current_room.show_room()
	
	Items.set_player(_player)
	Items.equip_item("shoot")
	#Items.equip_item("stun")
	#Items.equip_item("doublejump")
	#Items.equip_item("charm")
	#Items.equip_item("glide")
	
	$"Gladiator Boss".set_player(_player)
	

	
func _physics_process(_delta):
	_set_limited_camera_position(_player.position)
