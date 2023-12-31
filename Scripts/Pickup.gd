class_name Pickup
extends Node3D

@onready var mesh := $Mesh
@onready var pickupArea : Area3D = $Area3D

# Spin Variables
@export var rotationSpeed : float = 2.0
@export var height : float = 1.0
@onready var startY : float = position.y
var t : float = 0

func _ready():
	var player:Player = get_tree().get_first_node_in_group("Player")
	player.player_captured.connect(enable_item)

func _physics_process(delta):
	t += delta
	mesh.rotate_y(rotationSpeed * delta)
	var d = (sin(t * rotationSpeed)+1)/2 * height
	mesh.position.y = d

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as Player
		player.pick_up_item(self)
		disable_item()
		
func disable_item():
	mesh.visible = false
	pickupArea.monitoring = false
	
func enable_item():
	mesh.visible = true
	pickupArea.monitoring = true
	
