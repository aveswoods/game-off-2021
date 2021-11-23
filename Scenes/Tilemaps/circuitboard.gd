extends Sprite

export(float) var speed = 6 # px per second
var _position = null

func _ready():
	position.x -= region_rect.size.x / 2.0
	_position = position
	region_rect.size.x = 2.0 * region_rect.size.x

func _process(delta):
	position.x += speed * delta
	if position.x > region_rect.size.x / 2 + _position.x:
		position.x = _position.x
