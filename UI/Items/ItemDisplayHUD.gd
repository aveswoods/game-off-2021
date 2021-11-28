extends Control

signal active_slot_picked(item_id, slot_num)
signal opened
signal closed

onready var _color_rect = $ColorRect
onready var _item_text = $ItemText
onready var _equip_text = $EquipText
onready var _sprite_container = $SpriteContainer
onready var _box = $SpriteContainer/ActiveItemBox
onready var _tween = $Tween

const active_text = "[center]Press Z or X to place in an active item slot[/center]"
const passive_text = "[center]Press Z or X to continue[/center]"

var _item_id = ""
var _active_item = false
var _open = false
var _tweening = false


func open(item_id : String, active_item : bool = false):
	_item_id = item_id
	_active_item = active_item
	
	# Set item
	_box.remove_item()
	_box.set_item(item_id)
	
	# Set texts
	_item_text.bbcode_text = Items.get_item_text(item_id)
	if _active_item:
		_equip_text.bbcode_text = active_text
	else:
		_equip_text.bbcode_text = passive_text
	
	# Color rect
	_tween.interpolate_property(
		_color_rect,
		"color",
		Color(_color_rect.color.r, _color_rect.color.g, _color_rect.color.b, 0.0),
		Color(_color_rect.color.r, _color_rect.color.g, _color_rect.color.b, 0.5),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT
	)
	# Position of box
	_tween.interpolate_property(
		_sprite_container,
		"rect_position",
		_sprite_container.rect_position + Vector2(0, 64),
		_sprite_container.rect_position + Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT,
		0.25
	)
	# Transparency of box
	_tween.interpolate_property(
		_sprite_container,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		0.25
	)
	# Position of item text
	_tween.interpolate_property(
		_item_text,
		"rect_position",
		_item_text.rect_position,
		_item_text.rect_position - Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT,
		0.5
	)
	# Transparency of item text
	_tween.interpolate_property(
		_item_text,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		0.5
	)
	# Position of equip text
	_tween.interpolate_property(
		_equip_text,
		"rect_position",
		_equip_text.rect_position,
		_equip_text.rect_position - Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT,
		0.6
	)
	# Transparency of equip text
	_tween.interpolate_property(
		_equip_text,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		0.6
	)
	_tween.start()
	
	_open = true
	_tweening = true
	emit_signal("opened")


func close():
	# Color rect
	_tween.interpolate_property(
		_color_rect,
		"color",
		Color(_color_rect.color.r, _color_rect.color.g, _color_rect.color.b, 0.5),
		Color(_color_rect.color.r, _color_rect.color.g, _color_rect.color.b, 0.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT,
		0.25
	)
	# Position of box
	_tween.interpolate_property(
		_sprite_container,
		"rect_position",
		_sprite_container.rect_position,
		_sprite_container.rect_position - Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	# Transparency of box
	_tween.interpolate_property(
		_sprite_container,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT
	)
	# Position of item text
	_tween.interpolate_property(
		_item_text,
		"rect_position",
		_item_text.rect_position,
		_item_text.rect_position + Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	# Transparency of item text
	_tween.interpolate_property(
		_item_text,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT
	)
	# Position of equip text
	_tween.interpolate_property(
		_equip_text,
		"rect_position",
		_equip_text.rect_position,
		_equip_text.rect_position + Vector2(0, 32),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	# Transparency of equip text
	_tween.interpolate_property(
		_equip_text,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.25,
		Tween.TRANS_QUAD,Tween.EASE_IN_OUT
	)
	_tween.start()
	
	_open = false
	_tweening = true


func _ready():
	_box.display()
	
	_sprite_container.rect_position -= Vector2(0, 32)
	_item_text.rect_position += Vector2(0, 32)
	_equip_text.rect_position += Vector2(0, 32)


func _process(_delta):
	if not _tweening and _open:
		if Input.is_action_just_pressed("ui_accept"):
			close()
			_open = false
			if _active_item:
				emit_signal("active_slot_picked", _item_id, 1)
		elif Input.is_action_just_pressed("ui_select"):
			close()
			_open = false
			if _active_item:
				emit_signal("active_slot_picked", _item_id, 2)


func _on_Tween_tween_all_completed():
	_tweening = false
	if not _open:
		emit_signal("closed")
