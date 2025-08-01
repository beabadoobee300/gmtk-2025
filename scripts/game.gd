extends Node2D

var collected_items = []  # Array to store collected items

var inventory = {
	"keys": 0,
	"ammo": 0,
	"items": [],
}

# Inventory access method
func get_inventory() -> Dictionary:
	return inventory

# Key management methods
func has_keys(amount: int = 1) -> bool:
	return inventory["keys"] >= amount

func add_keys(amount: int = 1):
	inventory["keys"] += amount

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
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _ready():
	# Connect to all collectables in group
	for collectable in get_tree().get_nodes_in_group("collectable"):
		collectable.connect("collected", _on_collected)

func collect_ammo(n):
	print("j")
	$Player/gun.collect_ammo(n)
	return
	
func _on_collected(collect):
	print("game collected %s" % collect)
	inventory["items"].append(collect)
	
	match collect:
		"Key":
			add_keys(1)
		"Ammo":
			collect_ammo(5)
