extends CharacterBody2D

@export var speed := 150
@export var health := 30
@export var damage := 10

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

var is_dead := false

func take_damage(damage_amount):
	
	health -= damage_amount
	if (health <= 0):
		kill_zombie()
	else:
		print("hit for %d " % damage_amount )
		print("health left %d" % health )
		#slow zombie down

func kill_zombie():
	if is_dead:
		return
	is_dead = true
	print("zombie killed")
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	await get_tree().create_timer(0.0).timeout
	queue_free()

func _on_hitbox_body_entered(body):
	if is_dead:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
