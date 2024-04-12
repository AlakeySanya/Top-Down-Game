extends Control

@onready var inv: Inventory = preload("res://inventory/inventories/player_Inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

func _ready():
	inv.update.connect(update_slots)
	Global.connect("open_inventory", Callable(self, "_open"))
	Global.connect("close_inventory", Callable(self, "_close"))
	update_slots()
	_close()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func _close():
	visible = false
	is_open = false
func _open():
	visible = true
	is_open = true