class_name BehaviorStateMachine
extends Node
## State machine logic controlling sasquatch.

signal state_updated(newState:BehaviorState)
enum BehaviorState {IDLE, SEARCH, CHASE, INVESTIGATE, RETURN, FLEE}
@export var current_state : BehaviorState = BehaviorState.SEARCH :
	set = _set_state

func _set_state(value):
	current_state = value
	state_updated.emit(current_state)


func get_state() -> BehaviorState:
	return current_state


func print_state() -> void:
	match current_state:
		BehaviorState.IDLE:
			print("IDLE")
		BehaviorState.SEARCH:
			print("SEARCH")
		BehaviorState.CHASE:
			print("CHASE")
		BehaviorState.INVESTIGATE:
			print("INVESTIGATE")
		BehaviorState.RETURN:
			print("RETURN")
