extends Sprite

onready var _animation_player = $AnimationPlayer

func damage():
	_animation_player.play("damaged")

func restore():
	_animation_player.play("restored")
