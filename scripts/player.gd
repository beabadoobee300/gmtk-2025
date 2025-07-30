extends CharacterBody2D

# Movement and Camera Settings
@export var speed = 400
@export var camera_look_ahead_distance = 200  
@export var camera_follow_speed = 5.0 

# Combat Settings
@export var max_health := 100
@export var respawn_delay := 0.0
@export var respawn_points : Array[Node2D]
@export var invulnerability_duration := 2.0

# Nodes
@onready var camera: Camera2D = $Camera2D  
@onready var gun: Node2D = $gun
@onready var sprite: Sprite2D = $player  # Assuming you have a sprite
@export var enemy_scene : PackedScene  # Drag enemy.tscn here in inspector
@export var death_enemy_scale := 1.0  # Size multiplier for spawned enemy
# State variables
var current_health : int
var is_dead := false
var is_invulnerable := false
var shooting = false
var original_position : Vector2

func _ready():
	current_health = max_health
	original_position = global_position
	if respawn_points.is_empty():
		respawn_points.append(self) # Default to starting position

func _physics_process(delta):
	if !is_dead:
		get_input(delta)
		update_camera_position(delta)
		move_and_slide()

func _process(delta):
	if shooting and !is_dead:
		gun.shoot()

func get_input(delta):
	# Handle continuous movement input
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	# Handle rotation toward mouse
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	rotation = direction_to_mouse.angle()
	
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

func update_camera_position(delta):
	# Get mouse position relative to player
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	
	# Calculate target camera offset
	var target_offset = mouse_direction * min(
		global_position.distance_to(mouse_pos) / 2,
		camera_look_ahead_distance
	)
	
	# Smoothly move the camera offset
	camera.offset = camera.offset.lerp(target_offset, camera_follow_speed * delta)

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
	
	# Add to scene tree (use owner for proper level cleanup)
	get_tree().current_scene.add_child(new_enemy)
	
