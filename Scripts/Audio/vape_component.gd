class_name VapeComponent
extends Node3D
## Captures input, enables flashlight, starts particle effects, and sends signal for vaping state.

signal vaping_state_changed(_is_vaping:bool) 

@export var vape_cloud : GPUParticles3D
@export var vape_end_pos : Vector3
@export var vape_end_rot : Vector3

var vape_time : float = 0.0
var _is_vaping : bool = true:
	set = _set_is_vaping

@onready var vapeStartRot : Vector3 = self.rotation
@onready var vapeLight : SpotLight3D = $VapeLight
@onready var vapeStartPos : Vector3 = self.position

	
func _ready():
	_is_vaping = false
	vape_cloud.emitting = false

func _physics_process(delta):
	if _is_vaping:
		vape_time += delta
	else:
		vape_time = 0.0
	
func _input(event: InputEvent):
	if event.is_action_pressed("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "position", vape_end_pos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(self, "rotation", vape_end_rot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		_is_vaping = true
	elif event.is_action_released("Vape"):
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "position", vapeStartPos, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		tween.tween_property(self, "rotation", vapeStartRot, 0.2).set_trans(Tween.TRANS_SINE).from_current()
		_is_vaping = false
	
func _set_is_vaping(value: bool):
	_is_vaping = value
	_set_flashlight(_is_vaping)
	if !_is_vaping:
		_puff()
	
	vaping_state_changed.emit(_is_vaping)
	
func _set_flashlight(is_on: bool):
	vapeLight.light_energy = 1 if is_on else 0
	
func _puff():
	vape_cloud.restart()
	vape_cloud.amount = clampi(vape_time * 20.0, 1, 1000)
	vape_cloud.emitting = true
