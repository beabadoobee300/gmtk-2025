extends CanvasGroup
# In your blood manager script (autoload recommended)
var blood_stains = []

func add_blood(pos: Vector2, size: float = 1.0):
	var blood = Sprite2D.new()
	blood.texture = preload("res://asssets/blood.png")  # Fixed typo in "assets"
	
	if blood.texture == null:
		printerr("Blood texture failed to load!")
		return

	var canvas = get_node("/root/Game/BloodCanvas")
	if !canvas:
		printerr("BloodCanvas node not found!")
		return

	# Add random offset (±10 pixels)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var x_offset = rng.randf_range(-10, 10)
	var y_offset = rng.randf_range(-10, 10)
	blood.global_position = Vector2(pos.x + x_offset, pos.y + y_offset)
	
	blood.scale = Vector2(0.2, 0.2) * size  # Incorporate size parameter
	blood.modulate = Color(0.4, 0, 0, 0.8)  # Red with slight transparency
	blood.z_index = 0  # Render above other sprites
	
	canvas.add_child(blood)
	blood_stains.append(blood)
	
	# Debug output
	print("Blood added at:", blood.global_position, " | Offset:", Vector2(x_offset, y_offset))
	print("Total stains:", blood_stains.size())
