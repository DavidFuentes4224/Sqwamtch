extends Node

class_name BehaviorStateMachine

enum BehaviorState {IDLE, SEARCH, CHASE, INVESTIGATE}

signal StateUpdated(newState:BehaviorState)

@export var currentState : BehaviorState = BehaviorState.SEARCH :
	set = _set_state

func _set_state(value):
	currentState = value
	StateUpdated.emit(currentState)

func get_state() -> BehaviorState:
	return currentState

func print_state() -> void:
	match currentState:
		BehaviorState.IDLE:
			print("IDLE")
		BehaviorState.SEARCH:
			print("SEARCH")
		BehaviorState.CHASE:
			print("CHASE")
		BehaviorState.INVESTIGATE:
			print("INVESTIGATE")
