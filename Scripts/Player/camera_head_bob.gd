class_name CameraHeadBob
extends Node3D

@export_category("Bob Settings")
@export_range(0,0.05) var max_x_offset: = 0.03
@export_range(0,0.01) var max_y_offset: = 0.01
@export_range(0,15) var x_speed: = 5
@export_range(0,15) var y_speed: = 10
@export_range(0,2) var bob_scale: = 1.0

var _initial_pos:Vector3
var _t:float=0.0
var _spring_scale:float = 1.0
var _x_offset:float = 0.0

func _ready():
	_initial_pos = position

func _process(delta):
	var x = ((Vector3.RIGHT * sin(_t * x_speed * bob_scale * _spring_scale)) * _x_offset)
	var y = ((Vector3.UP * cos(_t * y_speed * bob_scale * _spring_scale)) * max_y_offset)
	position = lerp(position, _initial_pos + x + y, 0.1) 
	_t+=delta
		
func set_speed(speed: float):
	_spring_scale = speed
	if speed < 0.5:
		_x_offset = 0.0
	else:
		_x_offset = max_x_offset
