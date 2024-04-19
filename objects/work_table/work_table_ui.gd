extends Control
	
# TabContainer Каждый элемент который тоже как бы контейнер будет иметь свою
# собственную вкладку
# ScrollContainer в нем должен быть контейнер
# LineEdit Чтобы игрок мог вводить текст

var is_open = false

func _ready():
	close()

func close():
	visible = false
	is_open = false
func open():
	visible = true
	is_open = true
