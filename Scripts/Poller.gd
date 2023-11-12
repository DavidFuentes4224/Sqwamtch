extends Timer

class_name Poller

enum TickSpeed { FAST, NORMAL, SLOW }

@export var hello:float = 0
#distances are squared
@onready var speedByDistance:Dictionary = {
	50:TickSpeed.NORMAL,
	400:TickSpeed.SLOW
}
@onready var tickRateBySpeed:Dictionary = {
	TickSpeed.SLOW:1.0,
	TickSpeed.NORMAL:0.5,
	TickSpeed.FAST:0.1
}
var distances:Array

var currentSpeed:TickSpeed

func _ready():
	currentSpeed = TickSpeed.NORMAL
	speedByDistance.make_read_only()
	distances = speedByDistance.keys()
	distances.sort_custom(func(a,b): return a > b)
	
func update_rate(distance:float):
	# query all tick distances
	for queryDistance in distances:
		if distance > queryDistance:
			_update_rate_core(speedByDistance[queryDistance])
			return
	# default to fast tick rate
	if currentSpeed != TickSpeed.FAST:
		_update_rate_core(TickSpeed.FAST)

func _update_rate_core(speed:TickSpeed) -> void:
	currentSpeed = speed
	wait_time = tickRateBySpeed[currentSpeed]
