extends Node

#Autoloaded Scene
##Global scene to take care of stuff such as music and stats between levels
##armor, abilities etc.

# Reference to the viewport
onready var _viewport = get_viewport()

# Allows for slowdown of flow of time for everything except for the player
var time_multiplier = 1.0


func _ready() -> void:
	# Set up screen resize connection
	var error = get_tree().connect("screen_resized", self, "_on_screen_resized")
	if error:
		print("Could not set up screen resize connection")
	
	#$AudioMusic.play()


func _on_AudioMusic_finished() -> void: #this replays music forever. 
	#$AudioMusic.play()
	pass

## Handle any screen sizes
## Full credits to Godot forums users sysharm and SKison for this screen resize script
## See link to the original post here:
## https://godotengine.org/qa/25504/pixel-perfect-scaling
func _on_screen_resized():
	pass
#	var window_size = OS.get_window_size()
#
#	# Compare window to viewport size, find how much to scale up the screen
#	var scale_x = floor(window_size.x / _viewport.size.x)
#	var scale_y = floor(window_size.y / _viewport.size.y)
#
#	# Compare these scales, scale up to the min of these, with a min of 1 total
#	var scale = max(1, min(scale_x, scale_y))
#
#	# Extend the viewport, inpixel perfect amounts, to fit the screen as much as possible
#	#Find the scaled size difference (basically visual pixel difference) between the screen and viewport dimensions
#	var size_diff = window_size - (_viewport.size * scale)
#	var pixel_diff = (size_diff / scale).ceil()
#	# If either dimension is odd, make it even by adding a pixel (otherwise you might have everything offset by a half pixel)
#	if int(pixel_diff.x) % 2 == 1:
#		pixel_diff.x += 1
#	if int(pixel_diff.y) % 2 == 1:
#		pixel_diff.y += 1
#	# Now actually scale up the viewport to make it fill the screen
#	_viewport.set_size(_viewport.size + pixel_diff)
#
#	# find the coordinate we will use to center the viewport inside the window
#	var diff = window_size - (_viewport.size * scale)
#	var diffhalf = (diff * 0.5).floor()
#
#	# attach the viewport to the rect we calculated
#	_viewport.set_attach_to_screen_rect(Rect2(diffhalf, _viewport.size * scale))
