class_name SpawnPoint
extends Node3D
## Defines where player will spawn on level load. Also defines logic for finishing game upon
# player entering with all items.

var menu_scene = load("res://Nodes/Levels/Menu.tscn")

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as Player
		if player.items == player.maxItems:
			get_tree().change_scene_to_packed(menu_scene)
	pass # Replace with function body.
