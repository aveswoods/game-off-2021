extends Node

#Autoloaded Scene
##Global scene to take care of stuff such as music and stats between levels
##armor, abilities etc.

func _ready() -> void:
	$AudioMusic.play()





func _on_AudioMusic_finished() -> void: #this replays music forever. 
	$AudioMusic.play()
