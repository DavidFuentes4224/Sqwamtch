class_name VapeComponent
extends Node3D

@onready var vapeStartPos : Vector3 = self.position
@export var vapeEndPos : Vector3
@onready var vapeStartRot : Vector3 = self.rotation
@export var vapeEndRot : Vector3
@onready var vapeLight : SpotLight3D = $VapeLight
@export var vapeCloud : GPUParticles3D

signal vapingStateChanged(isVaping:bool) 

var vapeTime : float = 0.0

var isVaping : bool = true:
	set = set_is_vaping
	
func _ready():
	isVaping = false
	vapeCloud.emitting = false

func _physics_process(delta):
	if isVaping:
		vapeTime += delta
	else:
		vapeTime = 0.0
	
func _input(event):
	if event.is_action_pressed("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "position", vapeEndPos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(self, "rotation", vapeEndRot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		set_is_vaping(true)
	elif event.is_action_released("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "position", vapeStartPos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(self, "rotation", vapeStartRot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		set_is_vaping(false)
	
func set_is_vaping(value:bool):
	isVaping = value
	_set_flashlight(isVaping)
	if !isVaping:
		_puff()
	
	vapingStateChanged.emit(isVaping)
	
func _set_flashlight(isOn:bool) -> void:
	vapeLight.light_energy = 1 if isOn else 0
	
func _puff() -> void:
	vapeCloud.restart()
	vapeCloud.amount = clampi(vapeTime * 20.0, 1, 1000)
	vapeCloud.emitting = true
