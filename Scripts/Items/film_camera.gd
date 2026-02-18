class_name FilmCamera
extends Node3D
## Responsible for behavior of the camera itself (audio + visuals)

@export_category("Sounds")
@export var take_picture: AudioStream
@export var reset_camera: AudioStream

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var ready_light: Sprite3D = $CameraReadyLight
@onready var light: SpotLight3D = $Flash

func _ready():
	ready_light.modulate = Color.GREEN	


func on_photo_taken(_texture: ImageTexture):
	audio_player.stream = take_picture
	audio_player.play()
	ready_light.modulate = Color.RED
	
	
func on_camera_reset():
	audio_player.stream = reset_camera
	audio_player.play()
	ready_light.modulate = Color.GREEN


func _on_photo_taker_before_take_photo():
	light.light_energy = 3.0
	var tween = get_tree().create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.5)
