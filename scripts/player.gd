extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D  

@export var speed = 400
@export var camera_look_ahead_distance = 200  
@export var camera_follow_speed = 5.0 

func get_input():
	# movement
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	# rotation
	var mouse_pos = get_global_mouse_position();
	var direction_to_mouse = (mouse_pos - global_position).normalized();
	rotation = direction_to_mouse.angle();
	
func _physics_process(delta):
	get_input()
	update_camera_position(delta)
	move_and_slide()

func update_camera_position(delta):
	# Get mouse position relative to player
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	
	# Calculate target camera offset (limited by look_ahead_distance)
	var target_offset = mouse_direction * min(
		global_position.distance_to(mouse_pos),
		camera_look_ahead_distance
	)
	
	# Smoothly move the camera offset toward the target
	camera.offset = camera.offset.lerp(target_offset, camera_follow_speed * delta)
