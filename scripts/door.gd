extends Area2D

# Export variables for easy customization
@export var required_keys := 1         # Number of keys needed
@export var disappear_on_open := true  # Whether the door disappears when opened
@export var respawn_time := 0.0        # 0 means don't respawn

# Custom signal for when door is opened
signal door_opened(door_name)

@export var door_name := "Door"        # Text to display
@export var show_name := true          # Toggle visibility

var player_in_range := false

func _ready():
	# Connect the area's signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Configure the label
	update_label_text()
	$Label.visible = show_name
	# Center the text
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func update_label_text():
	if player_in_range:
		$Label.text = door_name + " (E)"
	else:
		$Label.text = door_name

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		update_label_text()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		update_label_text()

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		# Check if player has the required key
		if has_required_key():
			handle_door_opening()
		else:
			$Label.text = door_name + " (Need " + str(required_keys) + " "  + ")"
			await get_tree().create_timer(2.0).timeout
			update_label_text()
			
func has_required_key() -> bool:
	var root_node = get_tree().root.get_child(0)
	if root_node.has_method("has_keys"):
		return root_node.has_keys(required_keys)
	return false

func handle_door_opening():
	var root_node = get_tree().root.get_child(0)
	if root_node.has_method("use_keys") and root_node.use_keys(required_keys):
		emit_signal("door_opened", door_name)
		if disappear_on_open:
			visible = false
			$CollisionShape2D.set_deferred("disabled", true)
			
			if respawn_time > 0:
				await get_tree().create_timer(respawn_time).timeout
				visible = true
				$CollisionShape2D.set_deferred("disabled", false)
			else:
				queue_free()
