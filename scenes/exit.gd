extends Area2D

signal exit_activated

@export var exit_name := "Exit"
@export var required_switches := 3
@export var disabled_text := " (Requires 3 Switches)"
@export var enabled_text := " (E)"

var player_in_range := false
var switches_activated := 0
var is_ready := true

func _ready():
	update_label_text()
	$Label.visible = true
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	$CollisionShape2D.disabled = true  # Start disabled

func update_label_text():
	if player_in_range:
		if is_ready:
			$Label.text = exit_name + enabled_text
		else:
			$Label.text = exit_name + disabled_text + " (" + str(switches_activated) + "/" + str(required_switches) + ")"
	else:
		$Label.text = exit_name

func _on_body_entered(body):
	print("exit entered")
	if body.is_in_group("player"):
		player_in_range = true
		update_label_text()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		update_label_text()

func _input(event):

	if player_in_range and event.is_action_pressed("interact") and is_ready:
		emit_signal("exit_activated")
		# Handle what happens when exit is used (e.g., level complete)
		queue_free()
