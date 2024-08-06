extends CharacterBody3D

#movement
@export var walkSpeed := 2.0
@export var runSpeed := 6.0
@onready var movementSpeed := walkSpeed
@export var acceleration := 4.0

#vision
@export var searchRadius:float = 20.0
@export var sightDistance:float = 20.0
@export var sightAngle:float = deg_to_rad(75.0)
@onready var eyes:Node3D = get_tree().get_first_node_in_group("EnemyEyes")

#options
@export var DrawDebugRays:bool = false

#references
@onready var navAgent := $NavigationAgent3D
@onready var mesh := $Sqwamtch
@onready var animTree:AnimationTree = get_tree().get_first_node_in_group("EnemyAnimTree")
@onready var behaviorStateMachine : BehaviorStateMachine = $StateMachine
@onready var debugRayHelper = get_node("/root/DebugRayHelper")
@onready var VisionPoller:Poller = $RayTimer
@onready var Idletimer:Timer = $IdleTimer
@export var Player : Player

var readyToNav := false
var lookingForPlayer:bool = false
var lastSeenPos:Vector3
var isAttacking := false
var isReturningPlayer := false
var playerSpawn:Vector3

func _ready():
	navAgent.path_desired_distance = 0.5
	navAgent.target_desired_distance = 0.5
	call_deferred("_actor_setup")
	
func _actor_setup() -> void:
	await get_tree().physics_frame
	playerSpawn = get_tree().get_first_node_in_group("Spawn").position
	
	readyToNav = true
	_set_nav_target_from_state(behaviorStateMachine.get_state())

func _physics_process(delta):
	if !readyToNav:
		return

	var dir = Vector3()
	dir = navAgent.get_next_path_position() - self.global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * movementSpeed, acceleration * delta)
	if (movementSpeed > 0):
		_face_player(velocity)
	_process_animations()
	move_and_slide()
	var dist = global_position.distance_squared_to(Player.global_position)
	VisionPoller.update_rate(dist)
	if dist < 10 and !isAttacking and !isReturningPlayer:
		_try_attack()

func _try_attack() ->void:
	isAttacking = true
		# sometimes the seek gets set to -1.0, always set it 0.8 instead
	animTree.set("parameters/AttackSeek/seek_request", 0.8)
	animTree.set("parameters/AttackShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(2.0).timeout
	isAttacking = false
	
func _face_player(targetVel:Vector3):
	mesh.look_at(transform.origin - targetVel, Vector3.UP)
	
func _check_can_see_player() -> bool:
	if isReturningPlayer:
		return false
	var spaceState = get_world_3d().direct_space_state
	var dir = Player.global_position - eyes.global_position
	var hitEnd = dir.normalized() * sightDistance
	var query = PhysicsRayQueryParameters3D.create(eyes.global_position, eyes.global_position + hitEnd)
	query.collide_with_areas = true
	var result = spaceState.intersect_ray(query)
	var forward = eyes.get_global_transform().basis.z
	var canSeePlayer:bool = !result.is_empty() && result.collider != null && result.collider.is_in_group("Player") && forward.angle_to(dir) < sightAngle
	if DrawDebugRays:
		debugRayHelper.draw_ray(eyes.global_position, eyes.global_position + (forward.rotated(Vector3.UP, sightAngle) * sightDistance), Color(1,1,1))
		debugRayHelper.draw_ray(eyes.global_position, eyes.global_position + (forward.rotated(Vector3.UP, -sightAngle) * sightDistance), Color(1,1,1))
		debugRayHelper.draw_ray(eyes.global_position, eyes.global_position + hitEnd, Color(0,1,0) if canSeePlayer else Color(1,0,0))

	return canSeePlayer
	
func _process_animations() -> void:
	var animSpeed = 0.0
	match(behaviorStateMachine.currentState):
		behaviorStateMachine.BehaviorState.SEARCH:
			animSpeed = 0.2
		behaviorStateMachine.BehaviorState.CHASE, behaviorStateMachine.BehaviorState.INVESTIGATE, behaviorStateMachine.BehaviorState.RETURN:
			animSpeed = 1
		behaviorStateMachine.BehaviorState.IDLE:
			animSpeed = 0
	animTree.set("parameters/Locomotion/blend_position", animSpeed)

func _get_random_position_near_player() -> Vector3:
	var currentPlayerPos = Player.global_position
	var targetPos = currentPlayerPos + (Vector3.FORWARD * randf_range(-searchRadius, searchRadius)) + (Vector3.LEFT * randf_range(-searchRadius, searchRadius))
	return targetPos

func _set_nav_target_from_state(state : BehaviorStateMachine.BehaviorState) -> void:
	navAgent.path_desired_distance = 0.5
	match (behaviorStateMachine.get_state()):
		BehaviorStateMachine.BehaviorState.SEARCH:
			navAgent.target_position = _get_random_position_near_player()
		BehaviorStateMachine.BehaviorState.CHASE:
			navAgent.target_position = Player.global_position
		BehaviorStateMachine.BehaviorState.INVESTIGATE:
			navAgent.target_position = lastSeenPos if lookingForPlayer else _get_random_position_near_player()
		BehaviorStateMachine.BehaviorState.RETURN:
			navAgent.target_position = playerSpawn
			navAgent.path_desired_distance = 20.0

# called when finished getting to last known position or random position
func _on_navigation_agent_3d_navigation_finished():
	# finished looking at last known location, stay for a while, then move on
	if behaviorStateMachine.currentState == BehaviorStateMachine.BehaviorState.INVESTIGATE:
		lookingForPlayer = false
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.IDLE
		Idletimer.start()
	elif behaviorStateMachine.currentState == BehaviorStateMachine.BehaviorState.RETURN:
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.IDLE
		Idletimer.start()
		Player.get_thrown(position, playerSpawn)
		isReturningPlayer = false
	else:
		# nav target is set as a result of state being set. Not ideal
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.SEARCH

func _on_ray_timer_timeout():
	if _check_can_see_player():
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.CHASE
		lastSeenPos = Player.global_position
		lookingForPlayer = true
	elif isReturningPlayer:
		pass
	elif lookingForPlayer:
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.INVESTIGATE

func _on_state_machine_state_updated(newState):
	#behaviorStateMachine.print_state()
	_set_nav_target_from_state(newState)
	_set_walk_speed_from_state(newState)
	
func _set_walk_speed_from_state(state:BehaviorStateMachine.BehaviorState) -> void:
	match(state):
		BehaviorStateMachine.BehaviorState.SEARCH:
			movementSpeed = walkSpeed
		BehaviorStateMachine.BehaviorState.INVESTIGATE, BehaviorStateMachine.BehaviorState.CHASE, BehaviorStateMachine.BehaviorState.RETURN:
			movementSpeed = runSpeed
		BehaviorStateMachine.BehaviorState.IDLE:
			movementSpeed = 0.0


func _on_idle_timer_timeout():
	if !isReturningPlayer:
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.SEARCH

func _on_capture_area_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as Player
		player._start_capture(get_tree().get_first_node_in_group("HoldPosition"))
		isReturningPlayer = true
		behaviorStateMachine.currentState = BehaviorStateMachine.BehaviorState.RETURN
