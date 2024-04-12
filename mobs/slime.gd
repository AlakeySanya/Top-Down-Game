extends CharacterBody2D

var speed = 70
var hp = 30
var damage = 10

var chase = false
var player_in_attack_range = false
var cooldown = false
var player 

@onready var animplayer = $AnimationPlayer
@export var itnvRes: InvItem
@onready var slime = $Drop


#var curr_x_direction = "right"
#var curr_y_direction = "down"
var curr_direction = "right"

func _ready():
	slime.texture = itnvRes.texture
	Global.connect("player_make_damage", Callable(self, "_take_damage"))

func _physics_process(_delta):
	
	if hp <= 0:
		death()
	
	if player_in_attack_range and not cooldown:
		Global.emit_signal("player_take_damage", damage)
		cooldown = true
		$cooldown.start()
		
	if not chase:
		velocity = Vector2()
		if curr_direction == "right":
			$AnimatedSprite2D.flip_h = false
			animplayer.play("idle")
		elif curr_direction == "left":
			$AnimatedSprite2D.flip_h = true
			animplayer.play("idle")
	else:
		var direction = (player.position - self.position).normalized()
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
			animplayer.play("walk")
			curr_direction = "left"
		else:
			$AnimatedSprite2D.flip_h = false
			animplayer.play("walk")
			curr_direction = "right"
		velocity = direction * speed
	move_and_slide()

# basic funcs
func death():
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$Chase/CollisionShape2D.disabled = true
	slime_drop()
func slime_drop():
	slime.visible = true
func slime_collect():
	Global.emit_signal("player_collect_item", itnvRes)
	slime.visible = false
	queue_free()

# Signal funcs
func _take_damage(damage):
	self.hp -= damage

# Функции привязки
func _on_chase_body_entered(body):
	if body.name == "player":
		player = body
		chase = true
func _on_chase_body_exited(body):
	if body.name == "player":
		chase = false

func _on_hurt_box_area_entered(area):
	if area.is_in_group("player"):
		player_in_attack_range = true
func _on_hurt_box_area_exited(area):
	if area.is_in_group("player"):
		player_in_attack_range = false
func _on_cooldown_timeout():
	cooldown = false
	$cooldown.stop()

func _on_hit_box_area_entered(area):
	if area.name == "Arrow":
		self.hp -= 10

func _on_collect_range_body_entered(body):
	if body.name == "player":
		slime_collect()
