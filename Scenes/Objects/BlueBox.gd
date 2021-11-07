extends RigidBody2D


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
#var can_change = false
#var charged = false
#
##charged.
#func charge():
#	charged = true
##object no longer selected.
#func turn_off():
#	$AnimationPlayer.play("idle")
#
#
##what the object does: this one dies.
#func change():
#	can_change = true
#
#
#func _process(_delta: float) -> void:
#	if can_change == true: 
#		$AnimationPlayer.play("change")
#		can_change = false
#
#	if charged == true: 
#		$AnimationPlayer.play("charged")
#		charged = false
#
#
#
#func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
#	if anim_name == "charged":
#		$AnimationPlayer.play("charged")
