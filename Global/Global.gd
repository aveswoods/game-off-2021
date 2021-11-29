extends Node

#Autoloaded Scene
##Global scene to take care of stuff such as music and stats between levels
##armor, abilities etc.

# Reference to the viewport
onready var _viewport = get_viewport()
onready var _tween = Tween.new()

# Allows for slowdown of flow of time for everything except for the player
var time_multiplier = 1.0

# Additional upgrades
var bonus_hp = 0
var damage_multiplier = 1.0

var color_overlay = null

func flash_color_overlay(color : Color):
	if color_overlay != null and color_overlay is ColorRect:
		_tween.interpolate_property(
			color_overlay,
			"color",
			color,
			Color(color.r, color.g, color.b, 0.0),
			2.0,
			Tween.TRANS_EXPO,Tween.EASE_OUT
		)
		_tween.start()


func _ready():
	add_child(_tween)
