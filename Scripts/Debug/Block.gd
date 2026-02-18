extends Node3D

@onready var mesh = $MeshInstance3D

@export var Test:float = 5.0:
	set = _set_Test
	
func _set_Test(value):
	Test = value
	mesh.scale = Vector3(value)
