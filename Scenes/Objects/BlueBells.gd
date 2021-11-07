extends Area2D


signal stop_blue
#checking if player is inside and able to use the blue controls
var inside = false
#if activated, the BlueStuff can be accessed with arrow keys.
var activated = false


func _on_BlueBells_body_entered(body: Node) -> void:
	if body.name == "Player":
		inside = true
		print("Inside player")


func _process(_delta: float) -> void:
	if inside && Input.is_action_just_pressed("ui_accept"):
			print("BLUE_BELLS ACTIVATED!")
			activated = true



#player no longer inside, no longer activated BlueBells
func _on_BlueBells_body_exited(body: Node) -> void:
	if body.name == "Player":
		print("outside")
		inside = false
		activated = false
		$AnimationPlayer.play("idle")
	#attempt to deactivate all blue. Siganal connected with BlueStuff
		emit_signal("stop_blue")


func turn_off():
	pass

#what the blue object does.
func charge():
	$AudioStreamPlayer.play()

func change():
	$AnimationPlayer.play("change")
