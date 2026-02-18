class_name Pickup
extends Node3D
## Pickup-able item behaviors and visuals.

# Spin Variables
@export var rotation_speed: float = 2.0
@export var height: float = 1.0
@onready var startY: float = position.y
@onready var audio_player: AudioStreamPlayer3D = $audio_player

var t : float = 0

@onready var mesh: = $Mesh
@onready var pickupArea: Area3D = $Area3D

func _ready():
	var player:Player = get_tree().get_first_node_in_group("Player")
	player.player_captured.connect(enable_item)

func _physics_process(delta):
	t += delta
	mesh.rotate_y(rotation_speed * delta)
	var d = (sin(t * rotation_speed)+1)/2 * height
	mesh.position.y = d

func _on_area_3d_body_entered(body):
	if not body.is_in_group("Player"):
		return
	var player = body as Player
	player.pick_up_item(self)
	call_deferred("disable_item")
	audio_player.play()

func disable_item():
	mesh.visible = false
	pickupArea.monitoring = false
	
	
func enable_item():
	mesh.visible = true
	pickupArea.monitoring = true
