extends StaticBody2D

@onready var work_table_ui = $work_table_UI
var player_in_my_area = false
var is_open = false
@export var inv: Inventory

func _ready():
	Global.connect("player_use_interface", Callable(self, "_use_work_table"))

## MAIN FUNCTION ##
func _use_work_table():
	print("use")
	if not is_open:
		if player_in_my_area:
			is_open = true
			work_table_ui.open()
			pass
	else:
		if player_in_my_area:
			is_open = false
			work_table_ui.close()

func _on_area_2d_area_entered(area):
	if area.name == "interface_use":
		player_in_my_area = true
func _on_area_2d_area_exited(area):
	if area.name == "interface_use":
		player_in_my_area = false
		
# Items 
var slime = preload("res://inventory/items/slime.tres")
var arrow = preload("res://inventory/items/arrow.tres")
var cole = preload("res://inventory/items/cole.tres")
var iron = preload("res://inventory/items/iron.tres")
var wooden_shoes = preload("res://inventory/items/wooden_shoes.tres")
var wooden_pants = preload("res://inventory/items/wooden_pants.tres")
var wooden_chestplate = preload("res://inventory/items/wooden_chestplate.tres")
var wooden_helmet = preload("res://inventory/items/wooden_helmet.tres")
var stick = preload("res://inventory/items/stick.tres")
var apple = preload("res://inventory/items/apple.tres")



