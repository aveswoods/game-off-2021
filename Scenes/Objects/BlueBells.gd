extends Area2D

signal disconnect

export(Array) var blue_paths = []
var blue_nodes = []

func animate_change():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("change")
func animate_idle():
	$AnimationPlayer.play("idle")
func stop_animation():
	$AnimationPlayer.stop()

func _ready():
	stop_animation()
	
	for path in blue_paths:
		blue_nodes.append(get_node(path))


func send_disconnect():
	emit_signal("disconnect")


func _on_BlueBells_tree_exiting():
	send_disconnect()
