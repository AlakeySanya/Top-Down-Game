extends CharacterBody2D

################################### Переменные ##############################################

# Базовые Характеристики
var speed = 160
var hp = 100
var damage: int
var stamina = 100

# Координаты и положение мыши на экране относительно игрока
var mouse_pos # Создана тут чтобы отовсюду можно было обратится
var curr_x_mouse_direction: String
var curr_y_mouse_direction: String

# Для Атаки
var curr_weapon_type = HANDS
enum{
	HANDS,
	BOW,
	SWORD,
	STICK,
	STAFF,
	AXE
}
var bow_cooldown = false
var sword_cooldown = false
var staff_cooldown = false
var axe_cooldown = false

var equipt_weapon = "stick" # "bow" "Hands"
var weapon_collision
var attack_in_process = false

# Для Анимаций
@onready var animpsprite = $Player_Sprite
@onready var animplayer = $AnimationPlayer 
var attack_anim: Node

# Для инвентаря
@onready var inventory_ui = $Inventory_UI
@export var inventory: Inventory
var using_inventory_interface = false
var using_interface = false
var in_interface_obj_area = false

# Для Запоминания Последнего направления
var curr_x_player_direction = "right"
var curr_y_player_direction = "down"
var last_direction = Vector2()

# Для State Mashine
var state = MOVE
enum {
	MOVE,
	ATTACK,
	SLIDE,
	USE,
	USE_INTERFACE
}

# Привязка всех сигналов 
func _ready():
	
	$sword_attack/sword_collision.disabled = true
	
	Global.connect("player_collect_item", Callable(self, "_collect"))
	Global.connect("player_take_damage", Callable(self, "_take_damage"))

#####\\\ Главная функуция всех процессов ///#####
func _physics_process(_delta):
	
	# for using objects
	if Input.is_action_just_pressed("use_curr_object"):
		if equipt_weapon == "Hands":
			Global.emit_signal("player_use_object")
		else:
			state = ATTACK
	
	# equip items
	if Input.is_action_just_pressed("0"):
		equipt_weapon = "Hands"
		change_damage(1)
	if Input.is_action_just_pressed("1"):
		equipt_weapon = "bow"
		change_damage(20)
	if Input.is_action_just_pressed("2"):
		equipt_weapon = "stick"
		change_damage(10)

	## USING INTERFACE ##

	# INTERFACE USING
	if Input.is_action_just_pressed("use_interface"):
		if in_interface_obj_area:
			if not using_interface:
				state = USE_INTERFACE
				using_interface = true
			else:
				state = MOVE
				using_interface = false
			Global.emit_signal("player_use_interface")
	# Inventory using
	if Input.is_action_just_pressed("use_inventory"):
		if not using_inventory_interface:
			using_inventory_interface = true
			state = USE_INTERFACE
			inventory_ui.open()
		else:
			using_inventory_interface = false
			state = MOVE
			inventory_ui.close()

	# Для отслеживания позиции мыши
	mouse_pos = get_global_mouse_position()
	var mouse_direction = mouse_pos - self.position
	
	if mouse_direction.x <= 0:
		curr_x_mouse_direction = "left"
	else:
		curr_x_mouse_direction = "right"
	if mouse_direction.y <= 0:
		curr_y_mouse_direction = "up"
	else:
		curr_y_mouse_direction = "down"
	
	$Marker2D.look_at(mouse_pos)
	
	## For state Mashine ##
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		SLIDE:
			slide_state()
		USE:
			use_state()
		USE_INTERFACE:
			use_interface_state()
	move_and_slide()

################################### Функции ##############################################

# STATES 
func move_state(): # main state

	var direction = Vector2()
	if not using_interface:
		if Input.is_action_pressed("up"):
			direction.y -= 1
			curr_y_player_direction = "up"
		if Input.is_action_pressed("down"):
			direction.y += 1
			curr_y_player_direction = "down"
		if Input.is_action_pressed("right"):
			direction.x += 1
			curr_x_player_direction = "right"
		if Input.is_action_pressed("left"):
			direction.x -= 1
			curr_x_player_direction = "left"

	if direction != Vector2():
		last_direction = direction
		if curr_y_player_direction == "down":
			if curr_x_player_direction == "right":
				animpsprite.flip_h = false
				#animplayer.play("")
			elif curr_x_player_direction == "left":
				animpsprite.flip_h = true
				#animplayer.play("")
		elif curr_y_player_direction == "up":
			if curr_x_player_direction == "right":
				animpsprite.flip_h = false
				#animplayer.play("")
			elif curr_x_player_direction == "left":
				animpsprite.flip_h = true
				#animplayer.play("")
		velocity = direction.normalized() * speed
	# If player dont move
	else:
		velocity = Vector2()
func use_state():
	pass
func slide_state():
	pass
func use_interface_state():
	velocity = Vector2()
func attack_state():
	
	if equipt_weapon == "stick":
		attack_anim = $stick_attack
		curr_weapon_type = SWORD
	elif equipt_weapon == "bow":
		attack_anim = null
		curr_weapon_type = BOW
		
		# add new weapon
		
	match curr_weapon_type:
		BOW:
			weapon_collision = null
			bow_attack()
		SWORD:
			weapon_collision = $sword_attack/sword_collision
			sword_attack()
		STAFF:
			weapon_collision = null
			staff_attack()
		AXE:
			weapon_collision = null
			axe_attack()
	
	state = MOVE

# Weapon states 
func bow_attack():
	
	var arrow = preload("res://player/weapons/arrow.tscn")
	
	if not bow_cooldown:
		bow_cooldown = true
		var arrow_instance = arrow.instantiate()
		arrow_instance.rotation = $Marker2D.rotation
		arrow_instance.global_position = $Marker2D.global_position
		add_child(arrow_instance)
		$bow_cooldown.start()
func sword_attack():
	
	if not sword_cooldown:
		sword_cooldown = true
		
		if curr_x_mouse_direction == "right":
			attack_anim.flip_h = false
			attack_anim.position.x = 36.5
			weapon_collision.position.x = 30.5
		else:
			attack_anim.flip_h = true
			attack_anim.position.x = -36.5
			weapon_collision.position.x = -30.5
			
		if curr_y_mouse_direction == "up":
			attack_anim.flip_v= false
			attack_anim.position.y = -36.5
			weapon_collision.position.y = -30.5
		else:
			attack_anim.flip_v = true
			attack_anim.position.y = 36.5
			weapon_collision.position.y = 30.5
		
		animplayer.play("stick_attack")
		$sword_cooldown.start()
func staff_attack():
	pass
func axe_attack():
	pass

# Базовые функции
func change_damage(new_damage):
	self.damage = new_damage
	Global.emit_signal("player_change_damage", damage)

# Signal Funcs
func _collect(item):
	inventory.insert(item)
func _take_damage(enemy_damage):
	self.hp -= enemy_damage

# Cooldowns timeout
func _on_bow_cooldown_timeout():
	bow_cooldown = false
	$bow_cooldown.stop()
func _on_sword_cooldown_timeout():
	sword_cooldown = false
	$sword_cooldown.stop()

# Interface area 
func _on_interface_use_area_entered(area):
	if area.is_in_group("interface"):
		in_interface_obj_area = true
func _on_interface_use_area_exited(area):
	if area.is_in_group("interface"):
		in_interface_obj_area = false
