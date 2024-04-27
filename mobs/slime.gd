extends CharacterBody2D

################################### Переменные ##############################################

# Базовые Характеристики
var alive = true
var speed = 70
var hp = 60
var damage = 10

# Для Атаки и получения урона и преследования
var has_meet_player = false
var remember_where_the_player_was = false
var I_can_see_the_player = false
var chase = false
var player_in_attack_range = false
var cooldown = false
var player_damage = 10
@onready var player = $"../player"


# Для дропа лута
@onready var slime = $Drop
@export var itnvRes: InvItem

# Для Анимаций
@onready var animplayer = $AnimationPlayer
var curr_direction = "right"

# Привязка всех сигналов 
func _ready():
	slime.texture = itnvRes.texture
	Global.connect("player_change_damage", Callable(self, "_player_change_damage"))
	Global.connect("enemy_see_player", Callable(self, "_can_see_the_player"))
	Global.connect("enemy_cant_see_player", Callable(self, "_cant_see_the_player"))

#####\\\ Главная функуция всех процессов ///#####
func _physics_process(_delta):
	
	#print("chase = ", chase)
	#print("see = ", I_can_see_the_player)
	
	if alive:
		var direction = (player.position - self.position).normalized()
		locking_for_player(direction)
		if hp <= 0:
			death()
		if player_in_attack_range and not cooldown:
			Global.emit_signal("player_take_damage", damage)
			cooldown = true
			$cooldown.start()
			
		if chase:
			if I_can_see_the_player:
				if direction.x < 0:
					$AnimatedSprite2D.flip_h = true
					animplayer.play("walk")
					curr_direction = "left"
				else:
					$AnimatedSprite2D.flip_h = false
					animplayer.play("walk")
					curr_direction = "right"
				velocity = direction * speed
		else:
			if not remember_where_the_player_was:
				velocity = Vector2()
				if curr_direction == "right":
					$AnimatedSprite2D.flip_h = false
					animplayer.play("idle")
				elif curr_direction == "left":
					$AnimatedSprite2D.flip_h = true
					animplayer.play("idle")
		move_and_slide()

################################### Функции ##############################################

# Базовые функции
func locking_for_player(dir):
	# eyes mechanic
	var eye = preload("res://mobs/enemy_eye.tscn")
	var eye_instance = eye.instantiate()
	eye_instance.direction = dir
	eye_instance.parent_name = self.name
	add_child(eye_instance)
func death():
	alive = false
	$Drop/collect_range/collect_range_coll.disabled= false
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$Chase/chase_coll.disabled = true
	$Hit_box/Hit_box_coll.disabled = true
	slime_drop()
func slime_drop():
	slime.visible = true
func slime_collect():
	Global.emit_signal("player_collect_item", itnvRes)
	slime.visible = false
	queue_free()
func take_damage(enemy_damage):
	self.hp -= enemy_damage

# При получении Signals из глобальных скриптов
func _player_change_damage(new_damage):
	player_damage = new_damage
func _can_see_the_player(parent_name):
	if parent_name == self.name:
		has_meet_player = true
		chase = true
		I_can_see_the_player =  true
func _cant_see_the_player(parent_name):
	if parent_name == self.name:
		if has_meet_player:
			I_can_see_the_player = false
			if not remember_where_the_player_was:
				$remember_timer.start()
				remember_where_the_player_was = true

#####\\\ Функции Сигналов от Узлов ///#####

# Для преследования (chase)
func _on_chase_body_entered(body):
	if body.name == "player":
		chase = true
func _on_chase_body_exited(body):
	if body.name == "player":
		chase = false
func _on_remember_timer_timeout():
	remember_where_the_player_was = false
	$remember_timer.stop()
	chase = false
	has_meet_player = false

# Для атаки
func _on_hurt_box_area_entered(area):
	if area.is_in_group("player"):
		player_in_attack_range = true
	if area.is_in_group("weapon"):
		take_damage(player_damage)
func _on_hurt_box_area_exited(area):
	if area.is_in_group("player"):
		player_in_attack_range = false
func _on_cooldown_timeout():
	cooldown = false
	$cooldown.stop()

# Для сбора лута
func _on_collect_range_body_entered(body):
	if body.name == "player":
		slime_collect()


