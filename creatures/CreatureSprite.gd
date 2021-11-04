extends Sprite

class_name CreatureSprite

var _shader_material = null


func flip_h(flipped):
	if flipped:
		scale.x = -1
	else:
		scale.x = 1


func animate_take_damage():
	pass

func animate_stun():
	_shader_material.set_shader_param("stunned", true)

func animate_unstun():
	_shader_material.set_shader_param("stunned", false)

func animate_explode():
	pass

func animate_big_explode():
	pass

func animate_fade_away():
	pass

func animate_disintegrate():
	pass

func _ready():
	_shader_material = material
