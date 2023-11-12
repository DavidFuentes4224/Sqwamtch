extends Node

func draw_ray(start:Vector3, finish:Vector3, color:Color) -> void:
	var ray = load("res://Misc/DebugRay.tscn").instantiate()
	add_child(ray)
	ray.initialize(start, finish, color)
