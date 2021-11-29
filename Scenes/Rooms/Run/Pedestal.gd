extends Node2D

onready var _sprite = $Sprite
onready var _item_sprite = $ItemArea/ItemSprite
onready var _item_area = $ItemArea

var _item_id = ""
var _item_picked = false


func disable():
	_sprite.visible = false
	_item_area.monitoring = false
	_item_sprite.visible = false
func enable():
	_sprite.visible = true
	_item_sprite.visible = true
	_item_area.monitoring = true


func is_item_set():
	return _item_picked


func set_item(item_id):
	enable()
	_item_id = item_id
	# TODO set sprite dynamically instead of text
	_item_picked = true


func _ready():
	disable()


func _on_ItemArea_body_entered(body):
	if body.is_in_group("player"):
		_item_sprite.visible = false
		_item_area.set_deferred("monitoring", false)
		
		Items.emit_signal("equipped", _item_id)
