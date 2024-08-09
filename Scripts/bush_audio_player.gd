class_name BushAudioPlayer
extends Node3D

@export var enter_sound:AudioStream
@export var exit_sound:AudioStream
@export var bus:StringName

var _audio_stream_player:AudioStreamPlayer3D

func _ready():
	_audio_stream_player = AudioStreamPlayer3D.new()
	_audio_stream_player.bus = bus
	add_child(_audio_stream_player)

func _on_area_3d_area_entered(area):
	_audio_stream_player.stream = enter_sound
	_audio_stream_player.play()

func _on_area_3d_area_exited(area):
	_audio_stream_player.stream = exit_sound
	_audio_stream_player.play()
