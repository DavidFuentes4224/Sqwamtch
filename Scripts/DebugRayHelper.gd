extends Node

@export_category("Settings")
@export var start_pos : Node3D
@export var end_pos : Node3D
@export_range(0.1,10) var draw_delay:float = 0.5
@export var ray_color:Color = Color.WHITE

@onready var _timer:Timer = $Timer

func _ready()->void:
	var delay:float = draw_delay if draw_delay != 0 else 0.1
	_timer = Timer.new()
	_timer.wait_time = delay
	_timer.one_shot = false
	_timer.start()

func draw_ray(start:Vector3, finish:Vector3, color:Color) -> void:
	_draw_ray_core(start, finish, color)

func _draw_ray_core(start:Vector3, finish:Vector3, color:Color) -> void:
	var ray = load("res://Misc/DebugRay.tscn").instantiate()
	add_child(ray)
	ray.initialize(start, finish, color)

func _on_timer_timeout():
	_draw_ray_core(start_pos.global_position, end_pos.global_position, ray_color)
