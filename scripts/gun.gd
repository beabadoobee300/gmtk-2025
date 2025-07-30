extends Node2D


#gun stuff
@export var damage := 30
@export var max_distance := 1000
@export var fire_rate := 0.2
@export var automatic := false
@export var ammo := 30
@export var max_ammo := 90
@export var reload_time := 1.5

# effects

# state

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
			
func shoot():
	print("shooting ammo: %d " % current_ammo)
	if not can_shoot or is_reloading or cooldown_timer > 0:
		print("can't shoot")
		return
	if current_ammo <= 0:
		print("out of ammo");
		return
	
	current_ammo -= 1
	cooldown_timer = fire_rate
	
	#raycasting
	var space_state = get_world_2d().direct_space_state
	var end_point = global_position + Vector2.RIGHT.rotated(global_rotation) * max_distance
	var query = PhysicsRayQueryParameters2D.create(global_position, end_point)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		print("hit")
	
	
func reload():
	print("reload")
	if is_reloading or current_ammo == ammo:
		print("ammo full return");
		return
	
	is_reloading = true
	reload_timer = reload_time	
	# Play reload sound/animation here

func finish_reload():
	var ammo_needed = ammo - current_ammo
	var ammo_available = min(max_ammo, ammo_needed)
	
	current_ammo += ammo_available
	max_ammo -= ammo_available
	is_reloading = false
