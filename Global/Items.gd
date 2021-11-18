extends Node

# Actions
var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()
var blue_action = load("res://creatures/player/abilities/blue_action.tscn").instance()
var charm_action = load("res://creatures/player/abilities/charm_action.tscn").instance()
var lunge_action = load("res://creatures/player/abilities/lunge_action.tscn").instance()
var mindcontrol_action = load("res://creatures/player/abilities/mindcontrol_action.tscn").instance()
var slowmo_action = load("res://creatures/player/abilities/slowmo_action.tscn").instance()
var shoot_action = load("res://creatures/player/abilities/shoot_action.tscn").instance()
# Passives
var stun_passive = load("res://creatures/player/abilities/stomp_passive.tscn").instance()
var doublejump_passive = load("res://creatures/player/abilities/doublejump_passive.gd").new()
var walljump_passive = load("res://creatures/player/abilities/walljump_passive.tscn").instance()
var glide_passive = load("res://creatures/player/abilities/glide_passive.gd").new()


var ids_to_items = {
	# Actions
	"bite": bite_action,
	"blue": blue_action,
	"charm": charm_action,
	"lunge": lunge_action,
	"mindcontrol": mindcontrol_action,
	"shoot": shoot_action,
	"slowmo": slowmo_action,
	# Passives
	"doublejump": doublejump_passive,
	"glide": glide_passive,
	"stun": stun_passive,
	"walljump": walljump_passive
}

const active_items = [
	"bite",
	"blue",
	"charm",
	"lunge",
	"mindcontrol",
	"shoot",
	"slowmo"
]

# Indicates which items should be added to the item pool after an item is picked up
const pickup_unlocks = {
	"bite": ["shoot"],
	"blue": ["charm"],
	"charm": ["mindcontrol"]
}

var _equipped_items = []
var _item_pool = []
var _player = null


# Adds item to the equipped_items array, removes it from the item pool, and adds new items to the pool
func equip_item(item_id : String):
	var item = ids_to_items[item_id]
	# Equip it to player
	item.equip(_player)
	# Make it an action if applicable
	if item_id in active_items:
		_player.action1_script = item
	# Add to equipped items
	_equipped_items.append(item_id)
	# Take out of item pool
	_item_pool.erase(item_id)
	# Add new items to item pool
	if pickup_unlocks.has(item_id):
		_item_pool.append_array(pickup_unlocks[item_id])


# Returns the empty string if there are no ids to pick from
func get_random_item_id_from_pool():
	if _item_pool.size() == 0:
		return ""
	else:
		return _item_pool[randi() % _item_pool.size()]


# Sets item pool to the player's default unlocked item pool
func reset_item_pool():
	_item_pool = SaveData.item_pool


# Unequips equipped items from current player, and equips them on a new player
func set_player(player):
	if _player != null:
		# Transfer items to new player
		for id in _equipped_items:
			var item = ids_to_items[id]
			item.unequip()
			item.equip(player)
			if _player.action1_script == item:
				_player.action1_script = null
				player.action1_script = item
			if _player.action2_script == item:
				_player.action2_script = null
				player.action2_script = item
	
	_player = player
