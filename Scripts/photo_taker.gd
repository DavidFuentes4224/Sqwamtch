extends Node3D
signal take_photo(texture:ImageTexture)
signal camera_ready
signal before_take_photo()

@export var film_asset:PackedScene
@export var spawnPos:Node3D
@onready var camera:Camera3D = get_tree().get_first_node_in_group("CameraView")

@export_category("Settings")
@export var photo_countdown:float = 4.0
@onready var _can_take_photo:bool = true:
	set(value):
		if (value == true):
			camera_ready.emit()
		_can_take_photo = value

func _input(event):
	if event.is_action_pressed("Take_Picture") and _can_take_photo:
		SaveScreen()

func SaveScreen() -> void:
	_can_take_photo = false
	before_take_photo.emit()
	
	# wait until frame finished drawing for light
	await get_tree().create_timer(0.1).timeout
	var img:Image = camera.get_viewport().get_texture().get_image()
	var texture:ImageTexture = ImageTexture.create_from_image(img)
	take_photo.emit(texture)
	await get_tree().create_timer(photo_countdown).timeout
	_can_take_photo = true
