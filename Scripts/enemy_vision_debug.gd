extends Node3D

@onready var player = get_tree().get_first_node_in_group("PlayerCollision")
#Get helper working!
@export var debug_helper:Node3D

func _process(delta):
	debug_helper.draw_ray(self.position, player.global_position,Color.RED)
