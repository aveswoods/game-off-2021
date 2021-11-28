extends Sprite

onready var _animation_player = $AnimationPlayer

var _item = null

func set_item(item_id):
	_item = Items.get_item_sprite(item_id)
	if _item != null:
		_item.position = Vector2.ZERO
		add_child(_item)

func animate_set_item(item_id):
	set_item(item_id)
	if _item != null:
		bump()


func remove_item():
	if _item != null:
		remove_child(_item)
		_item = null


func bump():
	_animation_player.play("bump")

func display():
	_animation_player.play("displayed")


func inactive():
	modulate = Color(1.0, 1.0, 1.0, 0.35)
func active():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	bump()
