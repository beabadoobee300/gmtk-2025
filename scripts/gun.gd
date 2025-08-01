extends Node2D

# Weapon Configuration
@export var damage := 15
@export var max_distance := 700
@export var fire_rate := 0.5
@export var slow_duration := 0.5
@export var automatic := false
@export var magazine_size := 5
@export var reload_time := 2.0
@export var enemy: PackedScene

# Debug Visualization
@export var show_raycast := true
@export var raycast_color := Color(1, 0, 0)
@export var raycast_duration := 0.1

# Spread Mechanics
@export var base_spread_angle := 5.0
@export var max_spread_angle := 10.0
@export var spread_decay_rate := 5.0	
@export var spread_increase_per_shot := 1.0

# Internal State
var current_magazine := 0
var current_reserve := 0
var is_reloading := false
var can_shoot := true
var cooldown_timer := 0.0
var reload_timer := 0.0
var current_spread := 0.0
var last_bullet_angle := 0.0
var time_since_last_shot := 0.0

func _ready():
	# Initialize ammo - 5 in magazine, 10 in reserve (15 total starting)
	current_magazine = magazine_size
	current_reserve = 10  # Starting reserve ammo
	print("Weapon ready. Ammo: %d/%d" % [current_magazine, current_reserve])

func _process(delta):
	# Handle cooldown between shots
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Handle reload progress
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			finish_reload()
	
	# Spread decay over time
	time_since_last_shot += delta
	if time_since_last_shot > fire_rate * 2:
		current_spread = move_toward(current_spread, 0, spread_decay_rate * delta)
	
	# Face toward mouse cursor
	look_at(get_global_mouse_position())
	
	# Debug raycast drawing
	if show_raycast:
		queue_redraw()

func shoot():
	if not can_shoot or is_reloading or cooldown_timer > 0:
		return
		
	# Check ammo status
	if current_magazine <= 0:
		if current_reserve > 0:
			reload()
		else:
			print("Out of ammo!")
		return
	
	# Deduce ammo and start cooldown
	current_magazine -= 1
	cooldown_timer = fire_rate
	time_since_last_shot = 0.0
	
		
	# Calculate bullet spread
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	var base_angle = mouse_direction.angle()
	last_bullet_angle = randf_range(-current_spread, current_spread)
	var spread_angle = base_angle + deg_to_rad(last_bullet_angle)
	var spread_direction = Vector2.RIGHT.rotated(spread_angle)
	
	# Increase spread
	current_spread = clamp(current_spread + spread_increase_per_shot, base_spread_angle, max_spread_angle)
	
	# Visual effects
	if get_parent().has_method("set_shooting_state"):
		get_parent().set_shooting_state(true)
	
	get_tree().create_timer(fire_rate).timeout.connect(
		func(): 
			if get_parent().has_method("set_shooting_state"):
				get_parent().set_shooting_state(false)
	)
	
	# Raycast for hit detection
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
	
	
	print("Fired! Ammo: %d/%d" % [current_magazine, current_reserve])
	
	# Auto-reload when magazine is empty
	if current_magazine <= 0 and current_reserve > 0:
		reload()

func reload():
	if is_reloading or current_magazine == magazine_size or current_reserve <= 0:
		return
	
	is_reloading = true
	reload_timer = reload_time
	print("Reloading...")

func finish_reload():
	var ammo_needed = magazine_size - current_magazine
	var ammo_to_take = min(ammo_needed, current_reserve)
	
	current_magazine += ammo_to_take
	current_reserve -= ammo_to_take
	is_reloading = false
	
	print("Reload complete. Ammo: %d/%d" % [current_magazine, current_reserve])

func collect_ammo(amount: int):
	current_reserve += amount  # Simply add to reserve with no cap
	print("Collected %d ammo. Total: %d/%d" % [amount, current_magazine, current_reserve])
