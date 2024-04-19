extends StaticBody2D

var player_in_picable_area = false

@export var apple: InvItem

func _ready():
	Global.connect("player_use_object", Callable(self, "_take_apple"))

func _take_apple():
	if player_in_picable_area:
		Global.emit_signal("player_collect_item", apple)

func _on_area_2d_body_entered(body):
	if body.name == "player":
		player_in_picable_area = true

func _on_area_2d_body_exited(body):
	if body.name == "player":
		player_in_picable_area = false
