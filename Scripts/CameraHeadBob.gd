extends Node3D

@export_category("Bob Settings")
@export_range(0,0.05) var MaxXOffset = 0.03
@export_range(0,0.01) var MaxYOffset = 0.01
@export_range(0,15) var XSpeed = 5
@export_range(0,15) var YSpeed = 10
@export_range(0,2) var bobScale = 1.0

var initialPos:Vector3
var t:float=0.0
var sprintScale:float = 1.0
var xOffset:float = 0.0

func _ready():
	initialPos = position

func _process(delta):
	var x = ((Vector3.RIGHT * sin(t * XSpeed * bobScale * sprintScale)) * xOffset)
	var y = ((Vector3.UP * cos(t * YSpeed * bobScale * sprintScale)) * MaxYOffset)
	position = lerp(position, initialPos + x + y, 0.1) 
	t+=delta
		
func set_speed(speed:float)->void:
	sprintScale = speed
	if (speed < 0.5):
		xOffset = 0.0
	else:
		xOffset = MaxXOffset
