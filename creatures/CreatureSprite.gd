extends AnimatedSprite

class_name CreatureSprite

func flip_h(is_flipped):
	if is_flipped:
		scale = Vector2(-1, 1)
	else:
		scale = Vector2(1, 1)

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
