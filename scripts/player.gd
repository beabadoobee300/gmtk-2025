extends CharacterBody2D



# Combat Settings
@export var max_health := 100
@export var respawn_delay := 0.0
@export var respawn_points : Array[Node2D]
@export var invulnerability_duration := 2.0

# Nodes
@onready var gun: Node2D = $gun
@onready var sprite: Sprite2D = $player


@export var enemy_scene : PackedScene
@export var death_enemy_scale := 1.0
# signals

signal health_updated(value)
signal ammo_updated(value)
# State variables
var current_health := max_health
var is_dead := false
var is_invulnerable := false
var shooting = false
var original_position : Vector2

@export var normal_speed := 300
@export var shooting_speed := 150  # Reduced speed when shooting
var speed := normal_speed


# damage
var can_take_damage = true
var damage_cooldown = 0.5  # 1 second cooldown
var cooldown_timer = 0.0

func _ready():
	$PointLight2D.shadow_enabled = true
	$PointLight2D.shadow_color = Color(0, 0, 0, 0.8)  # Darker shadows = less visibility
	current_health = max_health
	original_position = global_position

	update_labels()
	if respawn_points.is_empty():
		respawn_points.append(self) # Default to starting position

func _physics_process(delta):
	if !is_dead:
		get_input(delta)
		move_and_slide()
		update_labels()
		
	
	
func update_labels():
	emit_signal("health_updated", current_health)
	emit_signal("ammo_updated", gun.current_magazine, gun.current_reserve)
	
func _process(delta):
	if shooting and !is_dead:
		gun.shoot()
	if !can_take_damage:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_take_damage = true

func set_shooting_state(is_shooting: bool):
	shooting = is_shooting
	
func get_input(delta):
	# Handle continuous movement input
	var input_direction = Input.get_vector("left", "right", "up", "down")
	speed = shooting_speed if shooting else normal_speed
	
	velocity = (input_direction * speed ) * (current_health + 100) / 200
	
	# Handle rotation toward mouse
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	$flashlight.rotation = direction_to_mouse.angle()
	$player.rotation = direction_to_mouse.angle()
	
	# Handle event-based inputs
	if Input.is_action_just_pressed("reload"):
		gun.reload()
	
	if Input.is_action_just_pressed("kill"):
		kill_player()
	
	# Handle shooting
	if gun.automatic:
		shooting = Input.is_action_pressed("shoot")
	else:
		if Input.is_action_just_pressed("shoot"):
			gun.shoot()

func kill_player():
	if is_dead: 
		return
	spawn_zombie()
	print("killed")
	is_dead = true
	current_health = 0
	
	# Disable player
	visible = false
	set_process(false)
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	# Start respawn timer
	await get_tree().create_timer(respawn_delay).timeout
	respawn_player()

func respawn_player():
	# Choose random respawn point
	var spawn_point = respawn_points.pick_random()
	
	# Reset player
	global_position = spawn_point.global_position
	current_health = max_health
	is_dead = false
	
	# Re-enable player with invulnerability
	visible = true
	set_process(true)
	set_physics_process(true)
	collision_layer = 1
	collision_mask = 1
	
	# Temporary invulnerability
	is_invulnerable = true
	sprite.modulate.a = 0.5  # Visual indication
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false
	sprite.modulate.a = 1.0

func take_damage(amount: int):
	if is_dead or is_invulnerable:
		return
		
	current_health -= amount
	if current_health <= 0:
		kill_player()

func spawn_zombie():
	if !enemy_scene:
		push_warning("No enemy scene assigned for death spawn")
		return
	
	var new_enemy = enemy_scene.instantiate()
	
	# Configure enemy
	new_enemy.global_position = global_position
	new_enemy.scale = Vector2(death_enemy_scale, death_enemy_scale)
	
	# Add to scene tree
	get_tree().current_scene.add_child(new_enemy)


func _on_area_2d_area_entered(area: Area2D) -> void:
	var other_body = area.get_parent()
	if other_body.is_in_group("enemies") and can_take_damage:
		print("Touching:", other_body.name)
		take_damage(20)
		# Start cooldown
		can_take_damage = false
		cooldown_timer = damage_cooldown
		# Optional: Visual feedback (flash effect)
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE
	pass # Replace with function body.
