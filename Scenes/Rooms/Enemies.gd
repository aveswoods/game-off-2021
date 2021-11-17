extends Node2D

signal enemies_killed

var _enemies = []


func has_enemies():
	return _enemies.size() > 0


func enable():
	for enemy in _enemies:
		enemy.disabled = false


func _ready():
	_enemies = get_children()
	for enemy in _enemies:
		enemy.disabled = true
		enemy.connect("killed", self, "_on_enemy_killed", [enemy])


func _on_enemy_killed(_source, enemy):
	_enemies.erase(enemy)
	
	if _enemies.size() == 0:
		emit_signal("enemies_killed")
