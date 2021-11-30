extends Area2D

onready var _audio_change = $AudioChange
onready var _audio_connect = $AudioConnect

var _player = null
var _bluebells = null
var _bluebells_near = false
var _bluebells_connected = false
var _blue_nodes = null
var _active_blue_node_index = -1


func equip(player):
	_player = player
	_player.add_child(self)
func unequip():
	_player.remove_child(self)
	_player = null


func trigger():
	# Cycles through "activating" and "charging" blue objects
	if _bluebells_connected:
		# Special case where there is only one blue object
		if _blue_nodes.size() == 1:
			if _blue_nodes[0].is_charged():
				_blue_nodes[0].activate()
			else:
				_blue_nodes[0].charge()
		else:
			# Idle previous object
			_blue_nodes[_active_blue_node_index].idle()
			# Move index ahead
			_active_blue_node_index = (_active_blue_node_index + 1) % _blue_nodes.size()
			# Activate current object
			_blue_nodes[_active_blue_node_index].activate()
			# Charge next object
			_blue_nodes[(_active_blue_node_index + 1) % _blue_nodes.size()].charge()
		
		# Animate
		_bluebells.animate_change()
		
		# Play audio
		if not _audio_connect.playing:
			_audio_change.pitch_scale = rand_range(0.8, 1.1)
			_audio_change.play()
		
		
	# If not connected to a room's bluebells, connects to them if near them
	elif _bluebells_near:
		_bluebells_connected = true
		_blue_nodes = _bluebells.blue_nodes
		_active_blue_node_index = 0
		# Removes the connection with the player when the bluebells leave the tree, i.e. the player changes room
		_bluebells.connect("disconnect", self, "reset")
		
		trigger()
		
		# Play audio
		_audio_connect.play()


func reset():
	if _bluebells.is_connected("disconnect", self, "reset"):
		_bluebells.disconnect("disconnect", self, "reset")
	_bluebells = null
	_bluebells_near = false
	_bluebells_connected = false
	for node in _blue_nodes:
		node.idle()
	_blue_nodes = null
	_active_blue_node_index = -1


func _on_Area2D_area_entered(area):
	if area.is_in_group("bluebells"):
		if not _bluebells_connected:
			_bluebells = area
		_bluebells_near = true
		# Animate
		area.animate_idle()


func _on_Area2D_area_exited(area):
	if area.is_in_group("bluebells"):
		if not _bluebells_connected:
			_bluebells = null
		_bluebells_near = false
		# Stop animation
		area.stop_animation()
