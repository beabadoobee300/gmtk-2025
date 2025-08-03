extends Area2D

# Export variables for easy customization
@export var collectable_name := "item"
@export var value := 1
@export var disappear_on_collect := true
@export var respawn_time := 0.0 # 0 means don't respawn

# Custom signal for collection
signal collected(item_name)

@export var item_name := collectable_name  # Text to display
@export var show_name := true    # Toggle visibility

func _ready():
	# Connect the area's signal
	body_entered.connect(_on_body_entered)
	 # Configure the label
	$Label.text = item_name
	$Label.visible = show_name
	# Center the text
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if item_name == "Key":
		$Sprite2D.texture = preload("res://asssets/key.png")
		$Sprite2D.scale = Vector2(1, 1)  # 3x scale
		$Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST  # Preserve pixel art sharpness
	if item_name == "Ammo":
		$Sprite2D.texture = preload("res://asssets/ammo.png")
		$Sprite2D.scale = Vector2(1, 1)  # 3x scale
		$Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST  # Preserve pixel art sharpness

func _on_body_entered(body):
	if body.is_in_group("player"): # Or whatever your player group is
		handle_collection()
		

func handle_collection():
	emit_signal("collected", item_name)
	if disappear_on_collect:
		visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		
		if respawn_time > 0:
			await get_tree().create_timer(respawn_time).timeout
			visible = true
			$CollisionShape2D.set_deferred("disabled", false)
		else:
			queue_free()
