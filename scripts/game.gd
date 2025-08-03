extends Node2D

var collected_items = []  # Array to store collected items

var inventory = {
	"keys": 0,
	"ammo": 0,
	"items": [],
}

signal key_collected()
var deaths = 0

var active_generators = 0;

# Inventory access method
func get_inventory() -> Dictionary:
	return inventory

# Key management methods
func has_keys(amount: int = 1) -> bool:
	return inventory["keys"] >= amount

func add_keys(amount: int = 1):
	inventory["keys"] += amount
	emit_signal("key_collected")

func use_keys(amount: int = 1) -> bool:
	if has_keys(amount):
		inventory["keys"] -= amount
		return true
	return false

# Rest of your existing code...
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# Print all collected items when game ends
		print("Final collection: ", collected_items)
		end_game()

func end_game():
	get_tree().change_scene_to_file("res://scenes/win.tscn")

var fade_rect: ColorRect
var fade_tween: Tween

func _ready():
	deaths = 0;
	if deaths == 0:
		$Player.current_health = 40;
	# Connect to all collectables in group
	for collectable in get_tree().get_nodes_in_group("collectable"):
		collectable.connect("collected", _on_collected)
	for switch in get_tree().get_nodes_in_group("generator"):
		switch.connect("switch_activated", _on_switch_activated)
	for exit in get_tree().get_nodes_in_group("exit"):
		exit.connect("exit_activated", _on_exit_activated)
	for player in get_tree().get_nodes_in_group("player"):
		player.connect("death", _death)
		player.connect("blood", _blood)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("blood", _blood)
		
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(10000,10000)
	fade_rect.position = Vector2(-4000, -4000)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fade_rect)
	
	# Handle window resizing
	
	# Create tween
	fade_tween = create_tween()

func fade_to_black(duration: float = 1.0):
	fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await fade_tween.finished

func fade_from_black(duration: float = 1.0):
	fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await fade_tween.finished

func fade_black_transition(duration: float = 1.0):
	await fade_to_black(0)
	await fade_from_black(3)
	
func _blood(pos):
	print("blood")
	$BloodCanvas.add_blood(pos,1)
func _death():
	deaths += 1;
	fade_black_transition()
	
func collect_ammo(n):
	$Player/gun.collect_ammo(n)
	return

func _on_switch_activated(switch_name):
	print("Switch activated: ", switch_name)
	if switch_name == "Generator":
		active_generators += 1
	# Handle whatever should happen when switch is activated
	
func _on_collected(collect):
	print("game collected %s" % collect)
	inventory["items"].append(collect)
	
	match collect:
		"Key":
			add_keys(1)
		"Ammo":
			collect_ammo(5)

func _on_exit_activated():
	if active_generators == 3:
		print("Exit activated! Level complete!")
		end_game()
	print("generators not activated")
	# Handle level completion here
	
