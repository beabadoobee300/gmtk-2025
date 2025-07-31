extends Node2D

# Gun settings
@export var damage := 15
@export var max_distance := 700
@export var fire_rate := 0.2
@export var slow_duration := 0.3
@export var automatic := false
@export var ammo := 15
@export var max_ammo := 15
@export var reload_time := 1.5
@export var enemy: PackedScene

# Debug settings
@export var show_raycast := true
@export var raycast_color := Color(1, 0, 0)
@export var raycast_duration := 0.1

# Spread settings
@export var base_spread_angle := 5.0
@export var max_spread_angle := 10.0
@export var spread_decay_rate := 5.0
@export var spread_increase_per_shot := 1.0

var current_spread := 8.0
var last_bullet_angle := 0.0
var time_since_last_shot := 0.0

# State
var can_shoot := true
var is_reloading := false
var current_ammo := ammo
var cooldown_timer := 0.0
var reload_timer := 0.0

func _ready():
	current_ammo = ammo

func _process(delta):
	# Handle cooldown
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Handle reload
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			finish_reload()
	
	# Handle spread decay
	time_since_last_shot += delta
	if time_since_last_shot > fire_rate * 2:
		current_spread = move_toward(current_spread, 0, spread_decay_rate * delta)
	
	# Always face mouse
	look_at(get_global_mouse_position())
	
	if show_raycast:
		queue_redraw()

func _draw():
	if show_raycast and cooldown_timer > 0:
		var direction = (get_global_mouse_position() - global_position).normalized()
		var spread_rotation = direction.rotated(deg_to_rad(last_bullet_angle))
		var end_point = global_position + spread_rotation * max_distance
		draw_line(Vector2.ZERO, to_local(end_point), raycast_color, 1.0)

func shoot():
	if not can_shoot or is_reloading or cooldown_timer > 0:
		return
	if current_ammo <= 0:
		print("out of ammo")
		return
	
	current_ammo -= 1
	cooldown_timer = fire_rate
	time_since_last_shot = 0.0
	
	# Calculate base direction to mouse
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	var base_angle = mouse_direction.angle()
	
	# Apply random spread
	last_bullet_angle = randf_range(-current_spread, current_spread)
	var spread_angle = base_angle + deg_to_rad(last_bullet_angle)
	var spread_direction = Vector2.RIGHT.rotated(spread_angle)
	
	# Increase spread
	#current_spread = clamp(current_spread + spread_increase_per_shot, base_spread_angle, max_spread_angle)
	
	# Visual effects
	if get_parent().has_method("set_shooting_state"):
		get_parent().set_shooting_state(true)
	
	get_tree().create_timer(fire_rate).timeout.connect(
		func(): 
			if get_parent().has_method("set_shooting_state"):
				get_parent().set_shooting_state(false)
	)
	
	# Raycast
	var end_point = global_position + spread_direction * max_distance
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, end_point)
	
	if show_raycast:
		queue_redraw()
		get_tree().create_timer(raycast_duration).timeout.connect(queue_redraw)
	
	var result = space_state.intersect_ray(query)
	if result and result.collider.is_in_group("enemies"):
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(damage)
		

func reload():
	if is_reloading or current_ammo == ammo:
		return
	is_reloading = true
	reload_timer = reload_time

func finish_reload():
	var ammo_needed = ammo - current_ammo
	var ammo_available = min(max_ammo, ammo_needed)
	current_ammo += ammo_available
	max_ammo -= ammo_available
	is_reloading = false
