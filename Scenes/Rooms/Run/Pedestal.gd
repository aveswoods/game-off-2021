extends Node2D

onready var _item_sprite = $ItemArea/ItemSprite
onready var _item_area = $ItemArea
onready var _debug_text = $RichTextLabel

var _item_id = ""
var _item_picked = false


func is_item_set():
	return _item_picked


func set_item(item_id):
	_debug_text.text = item_id
	_item_id = item_id
	# TODO set sprite dynamically instead of text
	_item_sprite.visible = true
	_item_area.monitoring = true
	_item_picked = true


func _on_ItemArea_body_entered(body):
	if body.is_in_group("player"):
		_item_sprite.visible = false
		_item_area.set_deferred("monitoring", false)
		_debug_text.visible = false
		
		Items.emit_signal("equipped", _item_id)
