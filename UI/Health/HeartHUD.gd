extends Control

onready var _timer = $Timer

const heart = preload("res://UI/Health/Heart.tscn")
const _heart_width = 20
var num_hearts = 0
var _heart_nodes = []
var _index_to_spawn
var _healthy_index = 0


func damage(amount : int = 1):
	for i in amount:
		if _healthy_index >= 0:
			if _healthy_index == num_hearts:
				_healthy_index -= 1
			_heart_nodes[_healthy_index].damage()
			_healthy_index -= 1

func restore(amount : int = 1):
	for i in amount:
		if _healthy_index < num_hearts:
			_heart_nodes[_healthy_index].restore()
			_healthy_index += 1


func close():
	for heart_node in _heart_nodes:
		heart_node.queue_free()
	_heart_nodes.clear()


func open(num : int = 3, num_healthy : int = 3):
	num_hearts = num
	_healthy_index = clamp(num_healthy - 1, 0, num - 1)
	for i in num:
		var heart_node = heart.instance()
		if i > _healthy_index:
			heart_node.frame = 21
		heart_node.position.x = i * _heart_width
		_heart_nodes.append(heart_node)
		add_child(heart_node)


func spawn_and_animate_hearts(num : int = 3):
	num_hearts = num
	_healthy_index = num - 1
	if num > 0:
		var heart_node = heart.instance()
		heart_node.position.x = 0
		_heart_nodes.append(heart_node)
		add_child(heart_node)
		heart_node.restore()
		
		_index_to_spawn = 1
		_timer.start()


func _on_Timer_timeout():
	if _index_to_spawn < num_hearts:
		var heart_node = heart.instance()
		heart_node.position.x = _index_to_spawn * _heart_width
		_heart_nodes.append(heart_node)
		add_child(heart_node)
		heart_node.restore()
		
		_index_to_spawn += 1
		_timer.start()
