extends Area2D

signal switch_activated(switch_name)

@export var switch_name := "Generator"    # Text to display
@export var show_name := true          # Toggle visibility
@export var interaction_text := " (E)" # Text to show when player can interact

var player_in_range := false
var is_active := false

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
	if player_in_range && !is_active:
		$Label.text = switch_name + interaction_text
	else:
		$Label.text = "Activated"

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		update_label_text()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		update_label_text()

func _input(event):
	if player_in_range and event.is_action_pressed("interact") and !is_active:
		activate_switch()

func activate_switch():
	is_active = true
	emit_signal("switch_activated", switch_name)
	update_label_text()
	# Visual feedback
