extends CharacterBody2D

@export var speed := 150
@export var health := 30
@export var damage := 10

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

var is_dead := false

@export var default_view_distance := 500.0
@export var max_view_distance := 1000.0
@export var close_proximity_distance := 200.0;
@export var max_view_angle := 270.0  # Degrees
@export var default_view_angle := 90.0
@export var chase_speed := 300.0
var view_angle := default_view_angle;
var view_distance := default_view_distance;
var normal_speed := 50.0
var is_chasing := false

var wander_timer = 0
var wander_wait_time = 0
var current_wander_direction = 1
var target_rotation = 0
var current_rotation_speed = 0
var max_rotation_speed = PI/2  # 180 degrees per second
var rotation_acceleration = PI/2  # Speed increase per second
var is_waiting = false
var walk_duration = 0
var walk_timer = 0

var rotation_smoothing = 20.0  # Higher values = faster rotation to face player

# zombie slow
var is_slowed = false
var slow_timer = 0.0
var slow_duration = 0.3  # half second slow duration


func _process(delta):
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			is_slowed = false
	if can_see_player():
		is_chasing = true
		view_distance = max_view_distance
		
		view_angle = max_view_angle
		
		var player = get_tree().get_first_node_in_group("player")
		var direction = (player.global_position - global_position).normalized()
		
		# Improved rotation to face player smoothly
		var target_angle = atan2(direction.y, direction.x)
		var angle_diff = fposmod(target_angle - rotation, PI * 2)
		if angle_diff > PI:
			angle_diff -= PI * 2
		
		# Apply rotation with smoothing
		rotation += angle_diff 	* rotation_smoothing * delta
		
	
		
		velocity = direction * (chase_speed if !is_slowed else chase_speed * 0.3)
	
		
		# Reset wandering variables
		wander_timer = 0
		current_rotation_speed = 0
		is_waiting = false
		target_rotation = 0
	else:
		
		is_chasing = false
		view_distance = default_view_distance;
		view_angle = default_view_angle
		wander_timer += delta
		
		# State machine for wandering behavior
		if is_waiting:
			# Waiting state - stand still
			velocity = Vector2.ZERO
			
			# Check if waiting time is over
			if wander_timer >= wander_wait_time:
				is_waiting = false
				wander_timer = 0
				# Set random walk duration (1-3 seconds)
				walk_duration = randf_range(1.0, 5)
				# Random turn angle (between -180 and 180 degrees)
				target_rotation = randf_range(-PI, PI)
			
		else:
			# Walking state
			walk_timer += delta
			
			# Smooth turning logic
			if abs(target_rotation) > 0.01:
				var rotation_direction = sign(target_rotation)
				current_rotation_speed = min(current_rotation_speed + rotation_acceleration * delta, max_rotation_speed)
				var rotation_this_frame = current_rotation_speed * delta * rotation_direction
				if abs(rotation_this_frame) > abs(target_rotation):
					rotation_this_frame = target_rotation
				rotate(rotation_this_frame)
				target_rotation -= rotation_this_frame
			else:
				current_rotation_speed = 0
			
			# Move in current direction
			velocity = transform.x * (normal_speed if !is_slowed else normal_speed * 0.3) * current_wander_direction
			
			# Check if walk duration is over or if we hit a wall
			if walk_timer >= walk_duration or is_on_wall():
				# If we hit a wall, turn around smoothly
				if is_on_wall():
					target_rotation = PI * current_wander_direction
					current_wander_direction *= -1
					velocity = transform.x * normal_speed * current_wander_direction
				
				# Transition to waiting state
				is_waiting = true
				wander_timer = 0
				walk_timer = 0
				# Set random wait time (0.5-2 seconds)
				wander_wait_time = randf_range(0.5, 2.0)
				velocity = Vector2.ZERO
	move_and_slide()
	
func can_see_player():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("DEBUG: No player found in 'player' group")
		return false
	
	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# --- RAYCAST CHECK (for walls/obstacles) ---
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	ray_query.exclude = [self]  # Ignore self-collision
	var ray_result = space_state.intersect_ray(ray_query)
	
	# If something blocks LOS (and it's not the player), fail detection
	if ray_result and ray_result.collider != player:
		return false
	
	# --- CLOSE PROXIMITY DETECTION (any direction, no angle check) ---
	if distance_to_player <= close_proximity_distance:
		return true  # Detected, no further checks needed
	
	# --- CONE-OF-VISION DETECTION (distance + angle) ---
	if distance_to_player > view_distance:
		return false
	
	var angle_to_player = rad_to_deg(direction_to_player.angle() - rotation)
	if abs(angle_to_player) > view_angle:
		return false
	
	# If all checks passed (LOS, distance, angle), player is visible
	return true
func take_damage(damage_amount):
	health -= damage_amount
	if health <= 0:
		kill_zombie()
	else:
		print("hit for %d " % damage_amount)
		print("health left %d" % health)
		# Activate slow effect
		is_slowed = true
		slow_timer = slow_duration

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
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	var other_body = area.get_parent()
	if other_body.is_in_group("player") :
		print("Touching:", other_body.name)
	is_slowed = true
	slow_timer = slow_duration
	pass # Replace with function body.
