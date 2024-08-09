class_name Player
extends CharacterBody3D

@export var movementSpeed := 200.0
@export var rotationSpeed := 100.0
@export var sprintModification : float = 1.0
@export var max_distance_between_steps:float = 100.0
@onready var distance_between_steps:float = max_distance_between_steps
var sprintDrainModifier : float = 2.0
var maxSprintDuration = 5.0 * sprintDrainModifier
var sprintDuration : float:
	set = _set_sprint_duration
var staminaRefill : float = 0.0:
	set = _set_stamina_refill
var isSprinting : bool = false:
	set = _set_is_sprinting
var cooldownStarted : bool = false
var is_crouching:bool = false:
	set = _set_is_crouching

@onready var film_camera:Node3D = get_tree().get_first_node_in_group("FilmCamera")

@onready var camera := $Camera3D
@onready var ui : UI = $UI
@onready var sack:MeshInstance3D=$Camera3D/Holder/SackMesh
@onready var debugRayHelper:DebugRayHelper = get_node("/root/DebugRayHelper")
@onready var filmCameraPos:Node3D = $Camera3D/Holder/FilmCameraSocket
@onready var cameraBobber = $Camera3D/Holder
@onready var footstep_player = $SimpleFootstepPlayer

var items:int:
	set = _set_items

var maxItems:int
	
signal player_captured

var inputVector : Vector2

var minPitch : float = deg_to_rad(-80)
var maxPitch : float = deg_to_rad(90)
@onready var isCaptured:bool=false
@onready var holdPos:Node3D
var thrownVeloctiy:Vector3

var distance_travelled:float=0.0:
	set = _set_distance_travelled

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ui.set_max_sprint_value(maxSprintDuration)
	staminaRefill = 0
	sprintDuration = maxSprintDuration
	maxItems = get_tree().get_nodes_in_group("Pickup").size()
	items = 0
	
func _process(delta):
	inputVector = Input.get_vector("Move_Left","Move_Right","Move_Forward","Move_Backward")
	if isCaptured:
		inputVector = Vector2.ZERO
		position = holdPos.global_position
	
	if is_crouching:
		sprintModification = 0.5
	elif isSprinting and sprintDuration > 0.0:
		sprintDuration -= delta * sprintDrainModifier
		sprintModification = 2
	else:
		sprintModification = 1

	if cooldownStarted:
		staminaRefill += delta

	if (film_camera != null):
		film_camera.position = filmCameraPos.global_position
		film_camera.rotation = filmCameraPos.global_rotation
	
func _physics_process(delta):
	#no need to process physics when captured
	if isCaptured:
		return
		
	var vel = (inputVector.x * transform.basis.x) + (inputVector.y * transform.basis.z)
	velocity = thrownVeloctiy + vel.normalized() * movementSpeed  * sprintModification * delta
	if !is_on_floor():
		velocity.y -= 9.8
	else:
		velocity.y = 0
		thrownVeloctiy = Vector3.ZERO
	
	var bob_amount = 0.1
	var vel_length = velocity.length()
	if (vel_length > 0.1):
		if (is_crouching):
			bob_amount = 0.7
		elif (isSprinting):
			bob_amount = 2.0
		else:
			bob_amount = 1.0
		distance_travelled += vel_length
	else:
		distance_travelled = 0.0
	cameraBobber.set_speed(bob_amount)
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion:
		_rotate_player(event.relative)
	if event.is_action_pressed("Sprint"):
		isSprinting = true
	elif event.is_action_released("Sprint"):
		isSprinting = false
	elif event.is_action("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("Crouch"):
		is_crouching = true
	elif event.is_action_released("Crouch"):
		is_crouching = false
	
func pick_up_item(pickup:Pickup) -> void:
	items += 1

func get_thrown(start:Vector3, end:Vector3):
	# get direction to be thrown
	var dir = (end - start).normalized()
	var launchForce = 36
	var launghInfluence = Vector3(dir.x, 0, dir.z).length()
	var launchDir = Vector3(dir.x, launghInfluence * 4, dir.z)
	launchDir *= launchForce
	debugRayHelper.draw_ray(start,start + launchDir, Color(1,0,1))
	velocity = launchDir
	# remember thrown velocity for physics process
	thrownVeloctiy = Vector3(launchDir.x,0,launchDir.z)
	move_and_slide()
	_end_capture()
	
func _set_is_sprinting(spriting:bool) -> void:
	isSprinting = spriting
	if isSprinting:
		ui.reset_refill_bar()
	else:
		if sprintDuration > 0 and !is_crouching:
			staminaRefill = sprintDuration
		cooldownStarted = true
	
func _set_stamina_refill(amount:float) -> void:
	staminaRefill = amount
	if staminaRefill >= maxSprintDuration:
		sprintDuration = maxSprintDuration
		staminaRefill = 0
		cooldownStarted = false
	ui.update_stamina_refill_value(staminaRefill)
	
func _set_sprint_duration(amount:float) -> void:
	sprintDuration = amount
	if sprintDuration <= 0:
		sprintDuration = 0
		staminaRefill = 0
		isSprinting = false
	ui.update_sprint_value(sprintDuration)
	
func _set_items(amount:int) -> void:
	items = amount
	ui.update_items_count(items, maxItems)
	
func _set_is_crouching(value:bool) ->void:
	if (value != is_crouching):
		var tween = get_tree().create_tween()
		var collision:CollisionShape3D = $PlayerCollision
		tween.tween_property(collision, "shape:height", 0.6 if value else 2.0, 0.2).set_trans(Tween.TRANS_SINE).from_current()
	is_crouching = value
	distance_between_steps = max_distance_between_steps * 0.7 if is_crouching else max_distance_between_steps
	
func _rotate_player(rot:Vector2) -> void:
	rotation.y -= rot.x / rotationSpeed
	camera.rotate_x(-rot.y / rotationSpeed)
	camera.rotation.x = clampf(camera.rotation.x, minPitch, maxPitch)

func _start_capture(pos:Node3D):
	isCaptured = true
	player_captured.emit()
	items = 0
	holdPos = pos
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

func _end_capture():
	isCaptured = false
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 1.0, 0.2).set_trans(Tween.TRANS_SINE)

func _on_photo_taker_take_photo(texture:ImageTexture):
	ui.update_photo_ui(texture)

func _set_distance_travelled(distance:float):
	if (distance_travelled != 0.0 and distance == 0.0):
		footstep_player.play_footstep()
	distance_travelled = distance
	if (distance_travelled > distance_between_steps):
		footstep_player.play_footstep()
		distance_travelled = 0.0
