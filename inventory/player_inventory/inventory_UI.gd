extends Control

@onready var inv: Inv = preload("res://inventory/player_inventory/player_Inv.tres")
@onready var slots: Array = $Slots/GridContainer.get_children()

var is_open = false

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()
	
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func close():
	visible = false
	is_open = false
	
func open():
	visible = true
	is_open = true
