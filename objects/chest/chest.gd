extends StaticBody2D

@onready var anim = $AnimatedSprite2D
#@onready var work_table_ui = $chest_UI
var player_in_my_area = false
var is_open = false
@export var inv: Inventory

func _ready():
	Global.connect("player_use_object", Callable(self, "_use_work_table"))

## MAIN FUNCTION ##
func _use_work_table():
	if not is_open:
		if player_in_my_area:
			is_open = true
			anim.play("open")
			#chest_ui.open()
			pass
	else:
		if player_in_my_area:
			is_open = false
			anim.play("close")
			#chest_ui.close()

func _on_use_area_area_entered(area):
	if area.name == "interface_use":
		player_in_my_area = true
func _on_use_area_area_exited(area):
	if area.name == "interface_use":
		player_in_my_area = false
