class_name SimpleFootstepPlayer
extends Node3D

@export var footsteps:Array[AudioStream]
var _audio_stream_player:AudioStreamPlayer3D

func _ready():
	_audio_stream_player = AudioStreamPlayer3D.new()
	add_child(_audio_stream_player)

func play_footstep():
	var step:AudioStream = footsteps.pick_random()
	_audio_stream_player.stream = step
	_audio_stream_player.play()
