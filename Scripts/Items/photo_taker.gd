class_name PhotoTaker
extends Node3D
## Captures input to take photos if possible.

signal take_photo(texture: ImageTexture)
signal camera_ready
signal before_take_photo

@export var film_asset: PackedScene
@export_category("Settings")
@export var photo_countdown: float = 4.0

@onready var _can_take_photo: bool = true:
	set(value):
		if (value == true):
			camera_ready.emit()
		_can_take_photo = value
@onready var camera: Camera3D = get_tree().get_first_node_in_group("CameraView")

func _input(event):
	if event.is_action_pressed("Take_Picture") and _can_take_photo:
		save_screen()


func save_screen():
	_can_take_photo = false
	before_take_photo.emit()
	
	# wait until frame finished drawing for light
	await get_tree().process_frame
	var img: Image = camera.get_viewport().get_texture().get_image()
	var texture: ImageTexture = ImageTexture.create_from_image(img)
	take_photo.emit(texture)
	await get_tree().create_timer(photo_countdown).timeout
	_can_take_photo = true
