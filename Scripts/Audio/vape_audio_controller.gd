extends Node
## Plays a corresponding sound when vape state changes.

@export_category("Sound Settings")
@export var coughThreshold: float = 3.0
@export_category("Sounds")
@export var vapeInhale: AudioStreamMP3
@export var vapeExhale: AudioStreamMP3
@export var cough: AudioStreamMP3

var _audio_tween: Tween
var _inhale_time: float
var _is_vaping: bool

@onready var _audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _process(delta:float):
	if _is_vaping:
		_inhale_time += delta
	else:
		_inhale_time = 0.0
		

# Connects to vaping_state_changed signal on vape_component.
func _on_vape_pen_vaping_state_changed(isVaping:bool):
	_is_vaping = isVaping
	_reset_audio()
	
	if !_is_vaping:
		_audio_tween = get_tree().create_tween()
		_audio_tween.tween_property(_audio_player, "volume_db", -30.0, _inhale_time * 0.5).set_trans(Tween.TRANS_LINEAR).from(1.0)


func _reset_audio():
	if _audio_tween:
		_audio_tween.kill()
	_audio_player.stream = _get_audio_stream()
	_audio_player.volume_db = 0.0
	_audio_player.play()
	
	
func _get_audio_stream() -> AudioStreamMP3:
	if _is_vaping:
		return vapeInhale
	elif _inhale_time < coughThreshold:
		return vapeExhale
	else:
		return cough
