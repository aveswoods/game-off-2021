extends Node

#Autoloaded Scene
##Global scene to take care of stuff such as music and stats between levels
##armor, abilities etc.

# Allows for slowdown of flow of time for everything except for the player
var time_multiplier = 1.0


func _ready() -> void:
	#$AudioMusic.play()
	pass


func _on_AudioMusic_finished() -> void: #this replays music forever. 
	#$AudioMusic.play()
	pass
