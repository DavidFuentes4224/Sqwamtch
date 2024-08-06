extends Node3D

@export var trees : Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	var tree = trees[randi() % trees.size() -1]
	get_tree().add_child(tree)
	pass # Replace with function body.
