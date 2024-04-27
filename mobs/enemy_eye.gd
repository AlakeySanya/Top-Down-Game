extends CharacterBody2D

# Переменные
var has_seen_player = false
var speed = 1000
var direction: Vector2
var parent_name: String

# Функции
func _physics_process(delta):
	position += (direction * speed).rotated(rotation) * delta

func _on_area_2d_area_entered(area):
	if area.is_in_group("eye") or area.is_in_group("slime") or area.is_in_group("weapon") or area.is_in_group("eye_ignore"):
		pass
	elif area.is_in_group("player"):
		Global.emit_signal("enemy_see_player", parent_name)
		has_seen_player = true
		queue_free()
	else:
		if has_seen_player:
			Global.emit_signal("enemy_cant_see_player", parent_name)
			has_seen_player = false
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("slime"):
		pass
	else:
		Global.emit_signal("enemy_cant_see_player", parent_name)
		queue_free()

func _on_area_2d_area_exited(area):
	if area.name == "Chase":
		queue_free()
