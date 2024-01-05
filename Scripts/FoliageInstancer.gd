@tool
extends Node3D

@onready var MMInstance:MultiMeshInstance3D = $InstancerMM

@export var heightMap:Texture2D
@export_category("SpawnSettings")
@export var meshToSpawn:Mesh
@export var spawnAmount:int = 20000
@export var sizeX:float = 100.0
@export var sizeZ:float = 100.0
@export var minHeight:float = 10.0
@export var maxHeight:float = 100.0

@export_category("Masks")
enum MaskChannel {R, G, B}
@export var objectPlacementMask:Texture2D
@export_range(0,1) var spawnThreshold:float = 0.0
@export var maskChannel:MaskChannel = MaskChannel.R
@export var avoidMaskChannel:MaskChannel = MaskChannel.G

var heightMapImage:Image
var spawnMaskImage:Image

# Called when the node enters the scene tree for the first time.
func _ready():
	heightMapImage = heightMap.get_image()
	spawnMaskImage = objectPlacementMask.get_image()
	
	MMInstance.multimesh = MultiMesh.new()
	MMInstance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	MMInstance.multimesh.use_colors = false
	MMInstance.multimesh.use_custom_data = false
	MMInstance.multimesh.mesh = meshToSpawn
	
	MMInstance.multimesh.instance_count = spawnAmount
	MMInstance.multimesh.visible_instance_count = -1
	
	for i in MMInstance.multimesh.instance_count:
		var pos = _get_valid_pos()
		var scale = randf_range(0.75,1.25)
		var transform = Transform3D(Basis(Vector3.UP, randf_range(0, PI * 2)), pos)
		MMInstance.multimesh.set_instance_transform(i,transform)

func _get_valid_pos() -> Vector3:
	var pos = Vector3.ZERO
	var isValid = false
	while (!isValid):
		var x = randf_range(0, sizeX)
		var z = randf_range(0, sizeZ)
		var imagePos = _convert_to_image_coord(x,z)
		var maskColor:Color = spawnMaskImage.get_pixel(imagePos.x, imagePos.y)
		var spawnValue = _get_value_for_channel(maskColor, maskChannel)
		if spawnValue <= spawnThreshold:
			continue
		var avoidValue = _get_value_for_channel(maskColor, avoidMaskChannel)
		if avoidValue > 0.0:
			continue
			
		var y = heightMapImage.get_pixel(imagePos.x, imagePos.y).r * 4000
		if y < maxHeight and y > minHeight:
			isValid = true
			pos = Vector3(x,y,z)
	return pos
	
func _convert_to_image_coord(x:float, z:float) -> Vector2:
	# origin is at -1024,-1024
	var localPos = position + Vector3(x, 0, z)
	var terrainPos = localPos + Vector3(1024, 0, 1024)
	var imagePos = Vector2(floor(terrainPos.x / 2), floor(terrainPos.z / 2))
	return imagePos

func _get_value_for_channel(color:Color, mask:MaskChannel) -> float:
	var result:float
	match(mask):
		MaskChannel.R:
			result = color.r
		MaskChannel.G:
			result = color.g
		MaskChannel.B:
			result = color.b
		_:
			result = 0.0
	return result
