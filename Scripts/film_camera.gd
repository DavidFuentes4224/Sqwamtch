extends Node3D

@export_category("Sounds")
@export var take_picture:AudioStream
@export var reset_camera:AudioStream

@onready var AudioPlayer:AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var ready_light:Sprite3D = $CameraReadyLight
@onready var light:SpotLight3D = $Flash

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_light.modulate = Color.GREEN	

func on_photo_taken(_texture:ImageTexture):
	AudioPlayer.stream = take_picture
	AudioPlayer.play()
	ready_light.modulate = Color.RED
	
func on_camera_reset():
	AudioPlayer.stream = reset_camera
	AudioPlayer.play()
	ready_light.modulate = Color.GREEN

func _on_photo_taker_before_take_photo():
	light.light_energy = 3.0
	var tween = get_tree().create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.5)
