extends Node2D


#will make a list to put in each of the blue objects
var blue_list = []
var m = 0 #counter moving along the array
var bluesTotal = 0


func _ready() -> void:
	bluesTotal = self.get_child_count() 
	#now put in all the objects in this list.
	for i in self.get_children():
		blue_list.append(i)

#testing to only check when a button is pressed. 
#This will hopefully stop calling the same object all the time
func _input(event: InputEvent) -> void:
#func _process(delta: float) -> void:
	
	if $BlueBells.activated:
		if Input.is_action_just_pressed("ui_up"):
			blue_list[m].turn_off()
			m = m+1
			
		if Input.is_action_just_pressed("ui_down"):
			blue_list[m].turn_off()
			m = m-1
			
		if m == bluesTotal: #reseting index if too big
				m = 0
		if m == -bluesTotal:
				m = 0
		#previously selected object turns_off.
		#the selected object charges up.
		blue_list[m].charge()
		#if button pressed, CHANGE selected object
		if Input.is_action_just_pressed("ui_accept"):
			blue_list[m].change()
	else:
		for i in self.get_children():
			blue_list[m].turn_off()



func _on_BlueBells_stop_blue() -> void:
	for i in self.get_children():
			blue_list[m].turn_off()
