extends CanvasLayer
func _ready():
	var player = get_node("../Player")
	player.health_updated.connect(_on_health_updated)
	player.ammo_updated.connect(_on_ammo_updated)

func _on_health_updated(value):
	$VBoxContainer/health.text = "Health: %d/100" % value

func _on_ammo_updated(value):
	$VBoxContainer/ammo.text = "Ammo: %d/15" % value
