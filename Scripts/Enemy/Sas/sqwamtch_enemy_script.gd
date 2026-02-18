class_name Sasquatch
extends CharacterBody3D
## Main class for controlling Sasquath behavior. To be refactored later.

@export_category("Movement")
@export var walk_speed: float = 2.0
@export var run_speed: float = 6.0
@export var acceleration: float = 4.0

@export_category("Vision")
@export var search_radius: float = 20.0
@export var sight_distance: float = 20.0
@export var sight_angle: float = deg_to_rad(75.0)

@export_category("Misc")
@export var draw_debug_rays: bool = false
@export var player : Player

# 30 degrees
var flee_angle_rad: float = 0.52
var ready_to_nav := false
var looking_for_player: bool = false
var last_seen_pos: Vector3
var is_attacking: = false
var is_returning_player: = false
var player_spawn: Vector3
var is_fleeing: = false

@onready var eyes: Node3D = get_tree().get_first_node_in_group("EnemyEyes")
@onready var nav_agent := $NavigationAgent3D
@onready var mesh := $Sqwamtch
@onready var anim_tree:AnimationTree = get_tree().get_first_node_in_group("EnemyAnimTree")
@onready var behavior_state_machine : BehaviorStateMachine = $StateMachine
@onready var debug_ray_helper = get_node("/root/DebugRayHelper")
@onready var vision_poller: Poller = $RayTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var movement_speed := walk_speed


func _ready():
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	call_deferred("_actor_setup")
	
	
func _actor_setup():
	await get_tree().physics_frame
	player_spawn = get_tree().get_first_node_in_group("Spawn").position
	
	ready_to_nav = true
	_set_nav_target_from_state(behavior_state_machine.get_state())


func _physics_process(delta):
	if !ready_to_nav:
		return

	var dir = Vector3()
	dir = nav_agent.get_next_path_position() - self.global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * movement_speed, acceleration * delta)
	if (movement_speed > 0):
		_face_player(velocity)
	_process_animations()
	move_and_slide()
	var dist = global_position.distance_squared_to(player.global_position)
	vision_poller.update_rate(dist)
	if dist < 10 and !is_attacking and !is_returning_player:
		_try_attack()


func _try_attack():
	is_attacking = true
		# sometimes the seek gets set to -1.0, always set it 0.8 instead
	anim_tree.set("parameters/AttackSeek/seek_request", 0.8)
	anim_tree.set("parameters/AttackShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(2.0).timeout
	is_attacking = false
	
	
func _face_player(targetVel: Vector3):
	var destination = transform.origin - targetVel
	if destination != transform.origin:
		mesh.look_at(transform.origin - targetVel, Vector3.UP)
	
	
func _check_can_see_player() -> bool:
	if is_returning_player:
		return false
	var spaceState = get_world_3d().direct_space_state
	var dir = player.global_position - eyes.global_position
	var hitEnd = dir.normalized() * sight_distance
	var query = PhysicsRayQueryParameters3D.create(eyes.global_position,
			eyes.global_position + hitEnd)
	query.collide_with_areas = true
	var result = spaceState.intersect_ray(query)
	var forward = eyes.get_global_transform().basis.z
	var can_see_player:bool = (!result.is_empty()
			&& result.collider != null 
			&& result.collider.is_in_group("playerCollision") 
			&& forward.angle_to(dir) < sight_angle)
	if draw_debug_rays:
		debug_ray_helper.draw_ray(eyes.global_position, 
				eyes.global_position + (forward.rotated(Vector3.UP, sight_angle) * sight_distance),
				Color(1,1,1))
		debug_ray_helper.draw_ray(eyes.global_position, 
				eyes.global_position + (forward.rotated(Vector3.UP, -sight_angle) * sight_distance),
				Color(1,1,1))
		debug_ray_helper.draw_ray(eyes.global_position, 
				eyes.global_position + hitEnd,
				Color(0,1,0) if can_see_player else Color(1,0,0))
	return can_see_player
	
	
func _process_animations():
	var anim_speed = 0.0
	match(behavior_state_machine.current_state):
		behavior_state_machine.BehaviorState.SEARCH:
			anim_speed = 0.2
		behavior_state_machine.BehaviorState.CHASE, behavior_state_machine.BehaviorState.INVESTIGATE, behavior_state_machine.BehaviorState.RETURN, behavior_state_machine.BehaviorState.FLEE:
			anim_speed = 1
		behavior_state_machine.BehaviorState.IDLE:
			anim_speed = 0
	anim_tree.set("parameters/Locomotion/blend_position", anim_speed)


func _get_random_position_near_player() -> Vector3:
	var current_player_pos = player.global_position
	var targetPos = current_player_pos + (Vector3.FORWARD * randf_range(-search_radius, search_radius)) + (Vector3.LEFT * randf_range(-search_radius, search_radius))
	return targetPos
	
	
func _get_random_position_away_from_player() -> Vector3:
	var current_player_pos = player.global_position
	var dir = (global_position - current_player_pos).normalized()
	var degrees = atan2(dir.z, dir.x)
	var rads = deg_to_rad(degrees)
	var target_angle_rads = randf_range(rads + flee_angle_rad, rads - flee_angle_rad)
	var target_x = cos(target_angle_rads) * 75
	var target_z = sin(target_angle_rads) * 75
	var target = Vector3(target_x,0,target_z)
	return global_position + target


func _set_nav_target_from_state(state : BehaviorStateMachine.BehaviorState) -> void:
	nav_agent.path_desired_distance = 0.5
	match (state):
		behavior_state_machine.BehaviorState.SEARCH:
			nav_agent.target_position = _get_random_position_near_player()
		behavior_state_machine.BehaviorState.CHASE:
			nav_agent.target_position = player.global_position
		behavior_state_machine.BehaviorState.INVESTIGATE:
			nav_agent.target_position = last_seen_pos if looking_for_player else _get_random_position_near_player()
		behavior_state_machine.BehaviorState.RETURN:
			nav_agent.target_position = player_spawn
			nav_agent.path_desired_distance = 20.0
		behavior_state_machine.BehaviorState.FLEE:
			if (!is_fleeing):
				is_fleeing = true
				nav_agent.target_position = _get_random_position_away_from_player()


# called when finished getting to last known position or random position
func _on_navigation_agent_3d_navigation_finished():
	# finished looking at last known location, stay for a while, then move on
	if behavior_state_machine.current_state == behavior_state_machine.BehaviorState.INVESTIGATE:
		looking_for_player = false
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.IDLE
		idle_timer.start()
	elif behavior_state_machine.current_state == behavior_state_machine.BehaviorState.RETURN:
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.IDLE
		idle_timer.start()
		player.get_thrown(position, player_spawn)
		is_returning_player = false
	elif behavior_state_machine.current_state == behavior_state_machine.BehaviorState.FLEE:
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.SEARCH
		is_fleeing = false
	else:
		# nav target is set as a result of state being set. Not ideal
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.SEARCH


func _on_ray_timer_timeout():
	if _check_can_see_player():
		var player_has_photo = false
		if (player_has_photo):
			behavior_state_machine.current_state = behavior_state_machine.BehaviorState.CHASE		
			last_seen_pos = player.global_position
			looking_for_player = true
		else:
			behavior_state_machine.current_state = behavior_state_machine.BehaviorState.FLEE
	elif is_returning_player:
		pass
	elif looking_for_player:
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.INVESTIGATE


func _on_state_machine_state_updated(newState):
	#behavior_state_machine.print_state()
	_set_nav_target_from_state(newState)
	_set_walk_speed_from_state(newState)
	
	
func _set_walk_speed_from_state(state: BehaviorStateMachine.BehaviorState) -> void:
	match(state):
		behavior_state_machine.BehaviorState.SEARCH:
			movement_speed = walk_speed
		behavior_state_machine.BehaviorState.INVESTIGATE, behavior_state_machine.BehaviorState.CHASE, behavior_state_machine.BehaviorState.RETURN, behavior_state_machine.BehaviorState.FLEE:
			movement_speed = run_speed
		behavior_state_machine.BehaviorState.IDLE:
			movement_speed = 0.0


func _on_idle_timer_timeout():
	if !is_returning_player:
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.SEARCH


func _on_capture_area_body_entered(body):
	if body.is_in_group("Player"):
		var player_body = body as Player
		player_body._start_capture(get_tree().get_first_node_in_group("HoldPosition"))
		is_returning_player = true
		behavior_state_machine.current_state = behavior_state_machine.BehaviorState.RETURN
