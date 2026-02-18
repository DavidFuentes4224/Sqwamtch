class_name TreeWithCollision
extends Node3D
## Combines a tree scene with collision. Not sure what this is needed for.

@export var trees: Array[PackedScene]

func _ready():
	var tree = trees[randi() % trees.size() -1]
	get_tree().add_child(tree)
