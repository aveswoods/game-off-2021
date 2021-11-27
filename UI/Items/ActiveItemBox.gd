extends Sprite

onready var _animation_player = $AnimationPlayer

var _item = null

func set_item(item_id):
	_item = Items.get_item_sprite(item_id)
	if _item != null:
		_item.position = Vector2(18, 19)
		add_child(_item)

func remove_item():
	if _item != null:
		remove_child(_item)
		_item = null

func bump():
	_animation_player.play("bump")
