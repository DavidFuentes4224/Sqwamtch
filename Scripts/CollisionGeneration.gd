@tool
extends CollisionShape3D
@export var collision_decimation:int = 2
@export var should_generate:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_collision()
	pass # Replace with function body.

func _process(delta):
	if should_generate:
		should_generate = false
		_create_collision()

func _create_collision():
	var heightMap = Image.new()
	heightMap.load("res://Terrain/Height.exr")
	heightMap.convert(Image.FORMAT_RF)
	heightMap.resize(heightMap.get_width() / (collision_decimation+1), heightMap.get_height() / (collision_decimation+1))
	
	var heightShape = HeightMapShape3D.new()
	heightShape.map_width = heightMap.get_width()
	heightShape.map_depth = heightMap.get_height()
	var data:PackedFloat32Array = []
	for y in heightMap.get_height():
		for x in heightMap.get_width():
			data.push_back(heightMap.get_pixel(x,y).r * 4000)
		
	heightShape.map_data = data
	shape = heightShape
