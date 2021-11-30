extends Node

func equip(_player):
	Global.damage_multiplier += 1.0
func unequip():
	Global.damage_multiplier -= 1.0
