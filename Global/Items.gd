extends Node

signal recharging(action_num)
signal charged(action_num)
signal equipped(item_id)

# Actions
var bite_action = load("res://creatures/player/abilities/bite_action.tscn").instance()
var blue_action = load("res://creatures/player/abilities/blue_action.tscn").instance()
var charm_action = load("res://creatures/player/abilities/charm_action.tscn").instance()
var lunge_action = load("res://creatures/player/abilities/lunge_action.tscn").instance()
var mindcontrol_action = load("res://creatures/player/abilities/mindcontrol_action.tscn").instance()
var shoot_action = load("res://creatures/player/abilities/shoot_action.tscn").instance()
var slowmo_action = load("res://creatures/player/abilities/slowmo_action.tscn").instance()
var stunbomb_action = load("res://creatures/player/abilities/stunbomb_action.tscn").instance()
# Passives
var stun_passive = load("res://creatures/player/abilities/stomp_passive.tscn").instance()
var damageupgrade_passive = load("res://creatures/player/abilities/damageupgrade_passive.gd").new()
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
	"stunbomb": stunbomb_action,
	# Passives
	"cubeupgrade": damageupgrade_passive,
	"redupgrade": damageupgrade_passive,
	"doublejump": doublejump_passive,
	"glide": glide_passive,
	"stun": stun_passive,
	"walljump": walljump_passive
}

const ids_to_sprites = {
	"bite": preload("res://creatures/player/abilities/frames/Bite.tscn"),
	"blue": preload("res://creatures/player/abilities/frames/Blue.tscn"),
	"cubeupgrade": preload("res://creatures/player/abilities/frames/CubeUpgrade.tscn"),
	"doublejump": preload("res://creatures/player/abilities/frames/DoubleJump.tscn"),
	"glide": preload("res://creatures/player/abilities/frames/Glide.tscn"),
	"lunge": preload("res://creatures/player/abilities/frames/Lunge.tscn"),
	"mindcontrol": preload("res://creatures/player/abilities/frames/MindControl.tscn"),
	"redupgrade": preload("res://creatures/player/abilities/frames/RedUpgrade.tscn"),
	"shoot": preload("res://creatures/player/abilities/frames/Shoot.tscn"),
	"slowmo": preload("res://creatures/player/abilities/frames/Slowmo.tscn"),
	"stun": preload("res://creatures/player/abilities/frames/Stun.tscn"),
	"stunbomb": preload("res://creatures/player/abilities/frames/StunBomb.tscn")
}

const ids_to_text = {
	"bite": "[center]Red Mandibles\n\nBite and slice through your enemies.[/center]",
	"blue": "[center]Blue-Tenna\n\nConnect with a room's Blue Bells, then remotely control your environment.[/center]",
	"cubeupgrade": "[center]Enhanced Cube\n\nBlue cubes deal double damage.[/center]",
	"doublejump": "[center]Fly Wings\n\nJump once more in the air.[/center]",
	"glide": "[center]Airy Elixer\n\nHold jump while in the air to gently glide to the ground.[/center]",
	"lunge": "[center]Beetle Horn\n\nLunge with great force, bashing your enemies away.[/center]",
	"mincontrol": "[center]Permission Granted\n\nUse while above an enemy to take control of its mind.[/center]",
	"redupgrade": "[center]Viral Dagger\n\nYour attacks deal double damage.[/center]",
	"shoot": "[center]Volatile Elixer\n\nShoot enemies from a distance.[/center]",
	"slowmo": "[center]Overclocked\n\nSlow down your enemies for a short period of time.[/center]",
	"stun": "[center]Green Claws\n\nStomp on enemies to temporarily stun them. Clear rooms by stunning all enemies.[/center]",
	"stunbomb": "[center]Jolt Bomb\n\nLaunch a bomb that stuns nearby enemies on impact.[/center]"
}


const active_items = [
	"bite",
	"blue",
	"charm",
	"lunge",
	"mindcontrol",
	"shoot",
	"slowmo",
	"stunbomb"
]

# Indicates which items should be added to the item pool after an item is picked up
const pickup_unlocks = {
	"bite": ["shoot", "redupgrade"],
	"stun": ["slowmo", "stunbomb"],
	"blue": ["mindcontrol", "cubeupgrade"],
}

var _equipped_items = []
var _item_pool = []
var _player = null
var _recharge_action_item1 = null
var _recharge_action_item2 = null

func is_active(item_id):
	return item_id in active_items


# Adds item to the equipped_items array, removes it from the item pool, and adds new items to the pool
# If it is an action, it equips it to the action button specified. This only matters when the item is an action
func equip_item(item_id : String, action : int = 1):
	var item = ids_to_items[item_id]
	# Equip it to player
	item.equip(_player)
	# Make it an action if applicable
	if item_id in active_items:
		if action == 1:
			_player.action1_script = item
		elif action == 2:
			_player.action2_script = item
		
		# Connect recharging and charged signals if applicable
		if item.has_signal("recharging") and item.has_signal("charged"):
			if action == 1:
				item.connect("recharging", self, "_on_action1_recharging")
				item.connect("charged", self, "_on_action1_charged")
				_recharge_action_item1 = item
			elif action == 2:
				item.connect("recharging", self, "_on_action2_recharging")
				item.connect("charged", self, "_on_action2_charged")
				_recharge_action_item2 = item
	
	# Add to equipped items
	_equipped_items.append(item_id)
	# Take out of item pool
	_item_pool.erase(item_id)
	# Add new items to item pool
	if pickup_unlocks.has(item_id):
		_item_pool.append_array(pickup_unlocks[item_id])
	
	#emit_signal("equipped", item_id)


# Returns the empty string if there are no ids to pick from
func get_random_item_id_from_pool():
	if _item_pool.size() == 0:
		return ""
	else:
		return _item_pool[randi() % _item_pool.size()]


func get_item_sprite(item_id):
	if ids_to_sprites.has(item_id):
		return ids_to_sprites[item_id].instance()
	else:
		return null


func get_item_text(item_id):
	if ids_to_text.has(item_id):
		return ids_to_text[item_id]
	else:
		return ""


# Sets item pool to the player's default unlocked item pool
func reset_item_pool():
	_item_pool = SaveData.item_pool.duplicate()


func unequip_all():
	if _recharge_action_item1 != null:
		_recharge_action_item1.disconnect("recharging", self, "_on_action1_recharging")
		_recharge_action_item1.disconnect("charged", self, "_on_action1_charged")
		_recharge_action_item1 = null
	if _recharge_action_item2 != null:
		_recharge_action_item2.disconnect("recharging", self, "_on_action2_recharging")
		_recharge_action_item2.disconnect("charged", self, "_on_action2_charged")
		_recharge_action_item2 = null
	
	for id in _equipped_items:
		var item = ids_to_items[id]
		item.unequip()
	
	_equipped_items.clear()
	
	if _player.action1_script != null:
		_player.action1_script = null
	if _player.action2_script != null:
		_player.action2_script = null


# Unequips equipped items from current player, and equips them on a new player
func set_player(player):
	if _player != null and _player != player:
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


func _on_action1_recharging():
	emit_signal("recharging", 1)
func _on_action1_charged():
	emit_signal("charged", 1)
func _on_action2_recharging():
	emit_signal("recharging", 2)
func _on_action2_charged():
	emit_signal("charged", 2)
