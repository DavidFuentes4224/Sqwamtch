class_name Poller
extends Timer
## Calculates AI pathfinding tick rate based on distance to target.

enum TickSpeed { FAST, NORMAL, SLOW }

@export var hello: = 0.0

var distances: Array
var current_speed: TickSpeed

#distances are squared
@onready var speed_by_distance: Dictionary = {
	50:TickSpeed.NORMAL,
	400:TickSpeed.SLOW
}
@onready var tickRateBySpeed: Dictionary = {
	TickSpeed.SLOW: 1.0,
	TickSpeed.NORMAL: 0.5,
	TickSpeed.FAST: 0.1
}

func _ready():
	current_speed = TickSpeed.NORMAL
	speed_by_distance.make_read_only()
	distances = speed_by_distance.keys()
	distances.sort_custom(func(a,b): return a > b)


func update_rate(distance: float):
	# query all tick distances
	for query_distance in distances:
		if distance > query_distance:
			_update_rate_core(speed_by_distance[query_distance])
			return
	# default to fast tick rate
	if current_speed != TickSpeed.FAST:
		_update_rate_core(TickSpeed.FAST)


func _update_rate_core(speed: TickSpeed) -> void:
	current_speed = speed
	wait_time = tickRateBySpeed[current_speed]
