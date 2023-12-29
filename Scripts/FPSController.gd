class_name Player
extends CharacterBody3D

@export var movementSpeed := 200.0
@export var rotationSpeed := 100.0
@export var sprintModification : float = 1.0
var sprintDrainModifier : float = 2.0
var maxSprintDuration = 5.0 * sprintDrainModifier
var sprintDuration : float:
	set = _set_sprint_duration
var staminaRefill : float = 0.0:
	set = _set_stamina_refill
var isSprinting : bool = false:
	set = _set_is_sprinting
var cooldownStarted : bool = false

@onready var camera := $Camera3D
@onready var ui : UI = $UI
@onready var sack:MeshInstance3D=$Camera3D/SackMesh
@onready var debugRayHelper:DebugRayHelper = get_node("/root/DebugRayHelper")

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
	
	if isSprinting and sprintDuration > 0.0:
		sprintDuration -= delta * sprintDrainModifier
		sprintModification = 2
	elif cooldownStarted:
		staminaRefill += delta
		sprintModification = 1
	else:
		sprintModification = 1
	
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
		if sprintDuration > 0:
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
	
func _rotate_player(rot:Vector2) -> void:
	rotation.y -= rot.x / rotationSpeed
	camera.rotate_x(-rot.y / rotationSpeed)
	camera.rotation.x = clampf(camera.rotation.x, minPitch, maxPitch)

func _start_capture(pos:Node3D):
	isCaptured = true
	holdPos = pos
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

func _end_capture():
	isCaptured = false
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
