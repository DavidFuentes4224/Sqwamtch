extends Node
@onready var audioPlayer : AudioStreamPlayer2D = $AudioStreamPlayer2D
@export_category("Sound Settings")
@export var coughThreshold : float = 3.0
@export_category("Sounds")
@export var vapeInhale : AudioStreamMP3
@export var vapeExhale : AudioStreamMP3
@export var cough : AudioStreamMP3

var audioTween : Tween
var inhaleTime : float
var _isVaping : bool

func _process(delta):
	if _isVaping:
		inhaleTime += delta
	else:
		inhaleTime = 0.0

func _on_vape_pen_vaping_state_changed(isVaping):
	_isVaping = isVaping
	_reset_audio()
	
	if !_isVaping:
		audioTween = get_tree().create_tween()
		audioTween.tween_property(audioPlayer, "volume_db", -30.0, inhaleTime * 0.5).set_trans(Tween.TRANS_LINEAR).from(1.0)

func _reset_audio() -> void:
	if audioTween:
		audioTween.kill()
	audioPlayer.stream = _get_audio_stream()
	audioPlayer.volume_db = 0.0
	audioPlayer.play()
	
func _get_audio_stream() -> AudioStreamMP3:
	if _isVaping:
		return vapeInhale
	elif inhaleTime < coughThreshold:
		return vapeExhale
	else:
		return cough
