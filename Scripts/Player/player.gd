class_name Player
extends CharacterBody3D
## An overly busy class responsible for:
# player locomotion, inventory, being thrown, adjusting camera pos, input, updating UI

signal player_captured

@export var movement_speed:= 200.0
@export var rotation_speed:= 100.0
@export var sprint_modification: float = 1.0
@export var max_distance_between_steps: float = 100.0

var sprint_drain_modifier: float = 2.0
var max_sprint_duration: = 5.0 * sprint_drain_modifier
var sprint_duration: float:
	set = _set_sprint_duration
var stamina_refill: float = 0.0:
	set = _set_stamina_refill
var is_sprinting: bool = false:
	set = _set_is_sprinting
var cooldown_started: bool = false
var is_crouching: bool = false:
	set = _set_is_crouching
var items:int:
	set = _set_items
var max_items:int
var input_vector : Vector2
var min_pitch : float = deg_to_rad(-80)
var max_pitch : float = deg_to_rad(90)
var thrown_veloctiy:Vector3
var distance_travelled:float=0.0:
	set = _set_distance_travelled

@onready var film_camera: Node3D = get_tree().get_first_node_in_group("FilmCamera")
@onready var camera := $Camera3D
@onready var ui: UI = $UI
@onready var sack: MeshInstance3D=$Camera3D/Holder/SackMesh
@onready var debug_ray_helper: DebugRayHelper = get_node("/root/DebugRayHelper")
@onready var film_camera_pos: Node3D = $Camera3D/Holder/FilmCameraSocket
@onready var camera_bobber = $Camera3D/Holder
@onready var footstep_player = $SimpleFootstepPlayer
@onready var distance_between_steps: float = max_distance_between_steps
@onready var is_captured: bool=false
@onready var hold_pos: Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ui.set_max_sprint_value(max_sprint_duration)
	stamina_refill = 0
	sprint_duration = max_sprint_duration
	max_items = get_tree().get_nodes_in_group("Pickup").size()
	items = 0


func _process(delta):
	input_vector = Input.get_vector("Move_Left","Move_Right","Move_Forward","Move_Backward")
	if is_captured:
		input_vector = Vector2.ZERO
		position = hold_pos.global_position
	
	if is_crouching:
		sprint_modification = 0.5
	elif is_sprinting and sprint_duration > 0.0:
		sprint_duration -= delta * sprint_drain_modifier
		sprint_modification = 2
	else:
		sprint_modification = 1

	if cooldown_started:
		stamina_refill += delta

	if (film_camera != null):
		film_camera.position = film_camera_pos.global_position
		film_camera.rotation = film_camera_pos.global_rotation


func _physics_process(delta):
	#no need to process physics when captured
	if is_captured:
		return
	
	var vel = (input_vector.x * transform.basis.x) + (input_vector.y * transform.basis.z)
	velocity = thrown_veloctiy + vel.normalized() * movement_speed  * sprint_modification * delta
	if !is_on_floor():
		velocity.y -= 9.8
	else:
		velocity.y = 0
		thrown_veloctiy = Vector3.ZERO
	
	var bob_amount = 0.1
	var vel_length = velocity.length()
	if (vel_length > 0.1):
		if (is_crouching):
			bob_amount = 0.7
		elif (is_sprinting):
			bob_amount = 2.0
		else:
			bob_amount = 1.0
		distance_travelled += vel_length
	else:
		distance_travelled = 0.0
	camera_bobber.set_speed(bob_amount)
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		_rotate_player(event.relative)
	if event.is_action_pressed("Sprint"):
		is_sprinting = true
	elif event.is_action_released("Sprint"):
		is_sprinting = false
	elif event.is_action("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("Crouch"):
		is_crouching = true
	elif event.is_action_released("Crouch"):
		is_crouching = false


func pick_up_item(_pickup: Pickup):
	items += 1


func get_thrown(start: Vector3, end: Vector3):
	# get direction to be thrown
	var dir = (end - start).normalized()
	var launchForce = 36
	var launghInfluence = Vector3(dir.x, 0, dir.z).length()
	var launchDir = Vector3(dir.x, launghInfluence * 4, dir.z)
	launchDir *= launchForce
	debug_ray_helper.draw_ray(start,start + launchDir, Color(1,0,1))
	velocity = launchDir
	# remember thrown velocity for physics process
	thrown_veloctiy = Vector3(launchDir.x,0,launchDir.z)
	move_and_slide()
	_end_capture()


func _set_is_sprinting(spriting:bool) -> void:
	is_sprinting = spriting
	if is_sprinting:
		ui.reset_refill_bar()
	else:
		if sprint_duration > 0 and !is_crouching:
			stamina_refill = sprint_duration
		cooldown_started = true


func _set_stamina_refill(amount: float):
	stamina_refill = amount
	if stamina_refill >= max_sprint_duration:
		sprint_duration = max_sprint_duration
		stamina_refill = 0
		cooldown_started = false
	ui.update_stamina_refill_value(stamina_refill)


func _set_sprint_duration(amount: float):
	sprint_duration = amount
	if sprint_duration <= 0:
		sprint_duration = 0
		stamina_refill = 0
		is_sprinting = false
	ui.update_sprint_value(sprint_duration)


func _set_items(amount: int):
	items = amount
	ui.update_items_count(items, max_items)


func _set_is_crouching(value: bool):
	if (value != is_crouching):
		var tween = get_tree().create_tween()
		var collision:CollisionShape3D = $PlayerCollision
		tween.tween_property(collision, "shape:height", 0.6 if value else 2.0, 0.2).set_trans(Tween.TRANS_SINE).from_current()
	is_crouching = value
	distance_between_steps = max_distance_between_steps * 0.7 if is_crouching else max_distance_between_steps


func _rotate_player(rot: Vector2):
	rotation.y -= rot.x / rotation_speed
	camera.rotate_x(-rot.y / rotation_speed)
	camera.rotation.x = clampf(camera.rotation.x, min_pitch, max_pitch)


func _start_capture(pos: Node3D):
	is_captured = true
	player_captured.emit()
	items = 0
	hold_pos = pos
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE)


func _end_capture():
	is_captured = false
	var tween = get_tree().create_tween()
	tween.tween_property(sack, "position:y", 1.0, 0.2).set_trans(Tween.TRANS_SINE)


func _on_photo_taker_take_photo(texture: ImageTexture):
	ui.update_photo_ui(texture)


func _set_distance_travelled(distance: float):
	if (distance_travelled != 0.0 and distance == 0.0):
		footstep_player.play_footstep()
	distance_travelled = distance
	if (distance_travelled > distance_between_steps):
		footstep_player.play_footstep()
		distance_travelled = 0.0
