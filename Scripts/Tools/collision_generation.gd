@tool
class_name CollisionGenerator
extends CollisionShape3D
## Reads in height map data to generate collision for terrain.

@export var collision_decimation: int = 2
@export var should_generate: bool = false

func _ready():
	_create_collision()

func _process(_delta):
	if should_generate:
		should_generate = false
		_create_collision()

func _create_collision():
	var height_map = Image.new()
	height_map.load("res://Terrain/Height.exr")
	height_map.convert(Image.FORMAT_RF)
	var new_width: int = floor(height_map.get_width() as float / (collision_decimation + 1) as float)
	var new_height: int = floor(height_map.get_height() as float / (collision_decimation + 1) as float)
	height_map.resize(new_width, new_height)
	
	var height_shape = HeightMapShape3D.new()
	height_shape.map_width = height_map.get_width()
	height_shape.map_depth = height_map.get_height()
	var data: PackedFloat32Array = []
	for y in height_map.get_height():
		for x in height_map.get_width():
			data.push_back(height_map.get_pixel(x,y).r * 4000)
	
	height_shape.map_data = data
	shape = height_shape
