extends Node2D

var collected_items = []  # Array to store collected items

var inventory = {
	"keys": 0,
	"ammo": 0,
	"items": []
}
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
			inventory["keys"] += 1
		"Ammo":
			collect_ammo(5)
		"health_potion":
			inventory["health_potions"] = inventory.get("health_potions", 0) + 1
