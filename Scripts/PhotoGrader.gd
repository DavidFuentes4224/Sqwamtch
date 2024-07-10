extends Node
@export_category("Settings")
@export_range(0.01,1) var distance_falloff:float = .1
@export_category("Weights")
@export var distance_weight:float = 1
@export var direction_weight:float = 1
@export var state_weight:float = 1

func _on_photo_taker_take_photo(texture):
	var distance_score = _get_distance_score()
	var direction_score = _get_direction_score()
	var state_score = _get_state_score()
	
	var score = (distance_score * distance_weight) + (direction_score * direction_weight) + (state_score * state_weight)
	print_debug(score)

func _get_distance_score() -> float:
	var player:CollisionShape3D = get_tree().get_first_node_in_group("PlayerCollision")
	var enemy:CollisionShape3D = get_tree().get_first_node_in_group("EnemyCollision")
	var distance:float = (player.global_position - enemy.global_position).length_squared()
	var score:float = (1 - (distance_falloff * distance))
	print_debug(score)
	return score

func _get_direction_score()->float:
	var player:Node3D = get_tree().get_first_node_in_group("PlayerCollision")
	var enemy:Node3D = get_tree().get_first_node_in_group("EnemyCollision")
	var player_forward:Vector3 = (player.get_global_transform().basis * Vector3.FORWARD).normalized()
	var enemy_dir:Vector3 = (enemy.global_position - player.global_position).normalized()
	var dot:float = enemy_dir.dot(player_forward)
	
	print_debug(dot)
	return dot
	
func _get_state_score()->float:
	return 0.0
