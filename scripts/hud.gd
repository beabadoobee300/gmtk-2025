extends CanvasLayer
func _ready():
	var player = get_node("../Player")
	var game = get_node("../../Game")
	player.health_updated.connect(_on_health_updated)
	player.ammo_updated.connect(_on_ammo_updated)
	game.key_collected.connect(_on_key_updated)

var keys = 0

func _on_health_updated(value):
	$VBoxContainer/health.text = "Health: %d/100" % value

func _on_ammo_updated(current_magazine : int, current_reserve : int):
	$VBoxContainer/ammo.text = "Ammo: %d Reserve: %d" % [current_magazine, current_reserve]
	
func _on_key_updated():
	keys += 1
	$VBoxContainer/items.text = "Keys: %d" % keys
