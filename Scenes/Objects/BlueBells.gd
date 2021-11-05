extends Area2D

#checking if player is inside and able to use the blue controls
var inside = false
#if activated, the BlueStuff can be accessed with arrow keys.
var activated = false

func _on_BlueBells_body_entered(body: Node) -> void:
	if body.name == "Player":
		inside = true
		print("Inisde player")


func _process(delta: float) -> void:
	if inside && Input.is_action_just_pressed("ui_accept"):
			print("BLUE_BELLS ACTIVATED!")
			activated = true
			


#player no longer inside, no longer activated BlueBells
func _on_BlueBells_body_exited(body: Node) -> void:
	print("outside")
	inside = false
	activated = false
	$AnimationPlayer.play("idle")


func turn_off():
	pass

#what the blue object does.
func charge():
	$AudioStreamPlayer.play()

func change():
	$AnimationPlayer.play("change")
