extends Node2D

signal enemies_killed

var _enemies = []
var _num_enemies = 0
var _num_stunned = 0


func has_enemies():
	return _num_enemies > 0


func enable():
	for enemy in _enemies:
		enemy.disabled = false


func _ready():
	_enemies = get_children()
	_num_enemies = _enemies.size()
	for enemy in _enemies:
		enemy.disabled = true
		enemy.connect("killed", self, "_on_enemy_killed", [enemy])
		enemy.connect("stunned", self, "_on_enemy_stunned", [enemy])
		enemy.connect("unstunned", self, "_on_enemy_unstunned")


func _on_enemy_stunned(enemy):
	if not enemy.stunned:
		_num_stunned += 1
	if _num_stunned == _num_enemies:
		for i in _num_enemies:
			_enemies[_num_enemies - 1 - i].take_damage(1000000, Enemy.death_source.ERASE)


func _on_enemy_unstunned():
	_num_stunned -= 1


func _on_enemy_killed(_source, enemy):
	_enemies.erase(enemy)
	
	if _enemies.size() == 0:
		emit_signal("enemies_killed")
