extends Node

onready var _background_color = $BackgroundColor
onready var _run_root = $RunRoot

func _ready():
	VisualServer.set_default_clear_color(_background_color.color)
