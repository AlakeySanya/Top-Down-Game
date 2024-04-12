extends CharacterBody2D

# Basic
var speed = 100
var hp = 100
var damage = 10
var stamina = 100

# for attack
enum{
	BOW,
	SWORD,
	STAFF,
	AXE
}

var bow_cooldown = false
var sword_cooldown = false
var staff_cooldown = false
var axe_cooldown = false

var curr_weapon_type = BOW

# for inventory
@export var inventory: Inventory
var using_inventory = false
var can_close_inventory = true

# For anim
@onready var animplayer = $AnimationPlayer
var curr_x_direction = "right"
var curr_y_direction = "down"
var attack_in_process = false

# For state Mashine
enum {
	MOVE,
	ATTACK,
	SLIDE,
	USE
}
var state = MOVE
 
# For velocity
var last_direction = Vector2()

func _ready():
	Global.connect("player_collect_item", Callable(self, "_collect"))
	Global.connect("player_take_damage", Callable(self, "_take_damage"))

func _physics_process(_delta):
	
	var mouse_pos = get_global_mouse_position()
	$Marker2D.look_at(mouse_pos)
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		SLIDE:
			slide_state()
		USE:
			use_state()
	move_and_slide()

# STATES 
func move_state():

	var direction = Vector2()
	if not using_inventory:
		if Input.is_action_pressed("up"):
			direction.y -= 1
			curr_y_direction = "up"
		if Input.is_action_pressed("down"):
			direction.y += 1
			curr_y_direction = "down"
		if Input.is_action_pressed("right"):
			direction.x += 1
			curr_x_direction = "right"
		if Input.is_action_pressed("left"):
			direction.x -= 1
			curr_x_direction = "left"
		if Input.is_action_pressed("1"):
			curr_weapon_type = BOW
		if Input.is_action_pressed("2"):
			curr_weapon_type = SWORD
		if Input.is_action_pressed("use"):
			Global.emit_signal("player_use")
		if Input.is_action_pressed("attack"):
			state = ATTACK
	# For Inventory using
	if Input.is_action_just_pressed("use_inventory"):
		if not using_inventory:
			velocity = Vector2()
			using_inventory = true
			Global.emit_signal("open_inventory")
		elif can_close_inventory:
			using_inventory = false
			Global.emit_signal("close_inventory")
		can_close_inventory = false
	if Input.is_action_just_released("use_inventory"):
		can_close_inventory = true

	if direction != Vector2():
		last_direction = direction
		if curr_y_direction == "down":
			if curr_x_direction == "right":
				$AnimatedSprite2D.flip_h = false
				animplayer.play("idle_down")
			elif curr_x_direction == "left":
				$AnimatedSprite2D.flip_h = true
				animplayer.play("idle_down")
		elif curr_y_direction == "up":
			if curr_x_direction == "right":
				$AnimatedSprite2D.flip_h = false
				animplayer.play("idle_up")
			elif curr_x_direction == "left":
				$AnimatedSprite2D.flip_h = true
				animplayer.play("idle_up")
		velocity = direction.normalized() * speed
	# If player dont move
	else:
		velocity = Vector2()
func slide_state():
	
	pass
	state = MOVE
func use_state():
	pass
func attack_state():
	
	match curr_weapon_type:
		BOW:
			bow_attack()
		SWORD:
			sword_attack()
		STAFF:
			staff_attack()
		AXE:
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
		await get_tree().create_timer(0.5).timeout
		bow_cooldown = false
func sword_attack():
	if not sword_cooldown:
		if curr_x_direction == "left":
			$sword_attack/CollisionShape2D.position.x = -30
		elif curr_x_direction == "left":
			$sword_attack/CollisionShape2D.position.x = 30
		if curr_y_direction == "up":
			$sword_attack/CollisionShape2D.position.x = -30
		elif curr_y_direction == "down":
			$sword_attack/CollisionShape2D.position.x = 30
		
		await get_tree().create_timer(0.5).timeout
		sword_cooldown = false
		
		
		
func staff_attack():
	pass
func axe_attack():
	pass

# Signal Funcs
func _collect(item):
	inventory.insert(item)
func _take_damage(damage):
	self.hp -= damage
