extends Sprite

class_name CreatureSprite

func flip_h(flipped):
	if flipped:
		scale.x = -1
	else:
		scale.x = 1

func animate_take_damage():
	pass

func animate_stun():
	pass

func animate_unstun():
	pass

func animate_explode():
	pass

func animate_fade_away():
	pass

func animate_disintegrate():
	pass
