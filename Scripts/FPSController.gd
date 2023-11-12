extends CharacterBody3D

@onready var vapeStartPos : Vector3 = $Camera3D/VapePen.position
@export var vapeEndPos : Vector3

@onready var vapeStartRot : Vector3 = $Camera3D/VapePen.rotation
@export var vapeEndRot : Vector3

@onready var vape := $Camera3D/VapePen
@onready var vapeLight : SpotLight3D = $Camera3D/VapePen/VapeLight

@export var movementSpeed := 100.0
@export var rotationSpeed := 100.0
@onready var camera := $Camera3D

@onready var vapeCloud := $Camera3D/CloudParticles

var inputVector : Vector2

var minPitch : float = deg_to_rad(-80)
var maxPitch : float = deg_to_rad(90)

var vapeTime : float = 0
var isPuffin : bool = false

func _process(delta):
	inputVector = Input.get_vector("Move_Left","Move_Right","Move_Forward","Move_Backward")
	if isPuffin:
		vapeTime += delta
	else:
		vapeTime = 0
	
func _physics_process(delta):
	var vel = (inputVector.x * transform.basis.x) + (inputVector.y * transform.basis.z)

	velocity = vel.normalized() * movementSpeed * delta
	
	if !is_on_floor():
		velocity.y -= 9.8
	else:
		velocity.y = 0
	
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion:
		_rotate_player(event.relative)
	
	if event.is_action_pressed("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(vape, "position", vapeEndPos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(vape, "rotation", vapeEndRot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		_set_flashlight(true)
	elif event.is_action_released("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(vape, "position", vapeStartPos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(vape, "rotation", vapeStartRot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		_set_flashlight(false)
	
	
func _set_flashlight(isOn:bool) -> void:
	vapeLight.light_energy = 1 if isOn else 0
	isPuffin = isOn
	if !isOn:
		_puff()
	
func _puff() -> void:
	vapeCloud.restart()
	vapeCloud.amount = clampi(vapeTime * 20, 0, 75)
	vapeCloud.emitting = true
	
func _rotate_player(rot:Vector2) -> void:
	rotation.y -= rot.x / rotationSpeed
	camera.rotate_x(-rot.y / rotationSpeed)
	camera.rotation.x = clampf(camera.rotation.x, minPitch, maxPitch)
