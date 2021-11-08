extends Area2D

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


#signal stop_blue

##checking if player is inside and able to use the blue controls
#var inside = false
#
##if activated, the BlueStuff can be accessed with arrow keys.
#var activated = false
#
#
#func _on_BlueBells_body_entered(body: Node) -> void:
#	if body.name == "Player":
#		inside = true
#		print("Inside player")
#
#
##player no longer inside, no longer activated BlueBells
#func _on_BlueBells_body_exited(body: Node) -> void:
#	if body.name == "Player":
#		print("outside")
#		inside = false
#		activated = false
#		$AnimationPlayer.play("idle")
#	#attempt to deactivate all blue. Siganal connected with BlueStuff
#		emit_signal("stop_blue")
#
#
#func _process(_delta: float) -> void:
#	if inside && Input.is_action_just_pressed("ui_accept"):
#			print("BLUE_BELLS ACTIVATED!")
#			activated = true
#
#
#func turn_off():
#	pass
#
##what the blue object does.
#func charge():
#	$AudioStreamPlayer.play()
#
#func change():
#	$AnimationPlayer.play("change")
