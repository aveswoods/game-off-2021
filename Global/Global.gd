extends Node

#Autoloaded Scene
##Global scene to take care of stuff such as music and stats between levels
##armor, abilities etc.

onready var _tween = $Tween
onready var audio_enemies_erased = $AudioEnemiesErased
onready var _music_hub = $MusicHub
onready var _music_run = $MusicRun
onready var _music_boss = $MusicBoss

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


func fade_out_music(name : String, duration : float):
	var music_player = null
	match name:
		"hub":
			music_player = _music_hub
		"run":
			music_player = _music_run
		"boss":
			music_player = _music_boss
	if music_player != null:
		_tween.interpolate_property(
			music_player,
			"volume_db",
			0,
			-80,
			duration,
			Tween.TRANS_EXPO,Tween.EASE_IN
		)
		_tween.start()

func play_music(name : String):
	var music_player = null
	match name:
		"hub":
			music_player = _music_hub
		"run":
			music_player = _music_run
		"boss":
			music_player = _music_boss
	if music_player != null:
		music_player.volume_db = 0
		music_player.play(0)


func _on_Tween_tween_completed(object, key):
	if key == "volume_db":
		object.playing = false
