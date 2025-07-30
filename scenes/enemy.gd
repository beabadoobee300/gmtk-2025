extends CharacterBody2D

@export var speed := 150
@export var health := 30
@export var damage := 10

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

var is_dead := false

@export var view_distance := 300.0
@export var view_angle := 45.0  # Degrees
@export var chase_speed := 180.0
var normal_speed := 100.0
var is_chasing := false

func _physics_process(delta):
	if can_see_player():
		is_chasing = true
		var player = get_tree().get_first_node_in_group("player")
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * chase_speed
	else:
		is_chasing = false
		# Default patrol/wander behavior
		if is_on_wall() or not is_on_floor():
			rotate(PI/2 * delta)  # Simple turn when obstructed
		velocity = transform.x * normal_speed
	
	move_and_slide()
	
func can_see_player():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("DEBUG: No player found in 'player' group")
		return false
	
	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)
	#print("DEBUG: Distance to player: %.1f (max %.1f)" % [distance_to_player, view_distance])
	
	# Check if player is within view distance
	if distance_to_player > view_distance:
		#print("DEBUG: Player too far away")
		return false
	
	# Check angle (convert to degrees for easier understanding)
	var angle_to_player = rad_to_deg(direction_to_player.angle() - rotation)
	#print("DEBUG: Angle to player: %.1f° (max %.1f°)" % [angle_to_player, view_angle])
	
	if abs(angle_to_player) > view_angle:
		#print("DEBUG: Player outside view cone")
		return false
	
	# Raycast to check line of sight
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		print("DEBUG: Raycast hit: ", result.collider.name)
		if result.collider == player:
			print("DEBUG: Clear line of sight to player!")
		else:
			print("DEBUG: Vision blocked by: ", result.collider.name)
	else:
		print("DEBUG: Raycast didn't hit anything (unexpected)")
	
	return result.is_empty() or result.collider == player
	
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
		
