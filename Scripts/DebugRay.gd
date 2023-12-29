extends Node3D

class_name DebugRay

@export var Lifespan:float = 10
@onready var timer:Timer = $Timer
@onready var mesh := $Line

func _ready():
	if Lifespan != 0:
		timer.wait_time = Lifespan
		timer.start()
		
func initialize(start:Vector3, finish:Vector3, color:Color) -> void:
	var dir = finish - start
	var dist = dir.length()
	mesh.scale.z = dist
	global_position = start + (dir/2)
	look_at(finish, Vector3.UP)
	var material = mesh.get_surface_override_material(0).duplicate()
	material.albedo_color = color
	mesh.set_surface_override_material(0, material)

func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
