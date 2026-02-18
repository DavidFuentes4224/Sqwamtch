class_name DebugRay
extends Node3D
## Configures a "ray" to visualize a raycast then queue free after timer elapses.

@export var life_span: float = 10.0
@onready var timer: Timer = $Timer
@onready var mesh := $Line

func _ready():
	if life_span != 0:
		timer.wait_time = life_span
		timer.start()


func initialize(start: Vector3, finish: Vector3, color: Color):
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
