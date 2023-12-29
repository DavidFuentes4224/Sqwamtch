extends Node3D
var menuScene = load("res://Nodes/Menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as Player
		if player.items == player.maxItems:
			get_tree().change_scene_to_packed(menuScene)
	pass # Replace with function body.
