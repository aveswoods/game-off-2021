extends Node

# Contains all player save data. Examples of data include:
# - Number of total runs
# - Which items are unlocked
# - Permanent unlocks
# - Currency for unlocks
var save_file = null
var _saved = false

# Default values, when first booting up the game
var num_runs = 0
var currency = 0
var unlocks = {}
var equipped_unlocks = {}
var item_pool = [
	"doublejump",
	"glide"
] # Only the id's


func save_data():
	var save_data = {
		"num_runs": num_runs,
		"currency": currency,
		"unlocks": unlocks,
		"equipped_unlocks": equipped_unlocks,
		"item_pool": item_pool
	}
	
	save_file.store_string(to_json(save_data))
	save_file.flush()
	_saved = true


func load_data():
	if save_file.is_open():
		save_file.close()
	save_file.open("user://save.dat", File.READ)
	
	var save_data_string = save_file.get_as_text()
	
	if save_data_string.length() != 0:
		var save_data = parse_json(save_data_string)
		num_runs = save_data.num_runs
		currency = save_data.currency
		unlocks = save_data.unlocks
		equipped_unlocks = save_data.equipped_unlocks
		item_pool = save_data.item_pool
		
		print("Loaded data")
	
	save_file.close()
	save_file.open("user://save.dat", File.WRITE)
	_saved = false
	
	if save_data_string.length() == 0:
		save_data()
		
		print("Could not load data")


func _ready():
	save_file = File.new()
	
	connect("tree_exiting", self, "_on_tree_exiting")


func _on_tree_exiting():
	if not _saved:
		save_data()
	save_file.close()
