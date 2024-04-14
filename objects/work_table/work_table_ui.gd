extends Control

var is_open = false

func _ready():
	close()

func close():
	visible = false
	is_open = false
func open():
	visible = true
	is_open = true
