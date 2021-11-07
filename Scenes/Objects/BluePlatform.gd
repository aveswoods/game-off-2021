extends StaticBody2D




func _ready() -> void:
	$AnimationTree.active = true
	


#charged.
func charge():
	$AudioStreamPlayer.play()
	$AnimationTree.set("parameters/energy_state/current",1)
#object no longer selected.
func turn_off():
	$AnimationTree.set("parameters/energy_state/current",0)


#what the object does: this one dies.
func change():
	$AnimationTree.set("parameters/OneShot/active",true)
	



#
##charged.
#func charge():
#	$AudioStreamPlayer.play()
#	$AnimationPlayer.play("charged")
##object no longer selected.
#func turn_off():
#	$AnimationPlayer.play("idle")
#
#
##what the object does: this one dies.
#func change():
#	$AnimationPlayer.play("change")
#	yield(get_tree().create_timer(1), "timeout")
#	yield(get_node("AnimationPlayer"), "animation_finished")
#	$AnimationPlayer.play("charged")
#
##called upon after animation finishes.
#func destroy():
#	queue_free()
