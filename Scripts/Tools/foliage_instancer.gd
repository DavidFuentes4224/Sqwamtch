@tool
class_name FoliageInstancer
extends Node3D
## Reads in height map data, and scatters foliages accordingly.

enum MaskChannel {R, G, B}

@export var height_map: Texture2D
@export_category("SpawnSettings")
@export var mesh_to_spawn: Mesh
@export var spawn_amount: int = 20000
@export var size_x: float = 100.0
@export var size_z: float = 100.0
@export var min_height: float = 10.0
@export var max_height: float = 100.0

@export_category("Masks")
@export var object_placement_mask: Texture2D
@export_range(0,1) var spawn_threshold: float = 0.0
@export var mask_channel: MaskChannel = MaskChannel.R
@export var avoid_mask_channel: MaskChannel = MaskChannel.G

var height_map_image:Image
var spawn_mask_image:Image

@onready var mm_instance:MultiMeshInstance3D = $InstancerMM

func _ready():
	height_map_image = height_map.get_image()
	spawn_mask_image = object_placement_mask.get_image()
	
	mm_instance.multimesh = MultiMesh.new()
	mm_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mm_instance.multimesh.use_colors = false
	mm_instance.multimesh.use_custom_data = false
	mm_instance.multimesh.mesh = mesh_to_spawn
	
	mm_instance.multimesh.instance_count = spawn_amount
	mm_instance.multimesh.visible_instance_count = -1
	
	for i in mm_instance.multimesh.instance_count:
		var pos = _get_valid_pos()
		var new_transform = Transform3D(Basis(Vector3.UP, randf_range(0, PI * 2)), pos)
		mm_instance.multimesh.set_instance_transform(i, new_transform)


func _get_valid_pos() -> Vector3:
	var pos = Vector3.ZERO
	var is_valid = false
	while not is_valid:
		var x: float = randf_range(0, size_x)
		var z: float = randf_range(0, size_z)
		var image_pos = _convert_to_image_coord(x,z)
		var mask_color: Color = spawn_mask_image.get_pixel(image_pos.x, image_pos.y)
		var spawnValue = _get_value_for_channel(mask_color, mask_channel)
		if spawnValue <= spawn_threshold:
			continue
		var avoidValue = _get_value_for_channel(mask_color, avoid_mask_channel)
		if avoidValue > 0.0:
			continue
			
		var y = height_map_image.get_pixel(image_pos.x, image_pos.y).r * 4000
		if y < max_height and y > min_height:
			is_valid = true
			pos = Vector3(x,y,z)
	return pos
	
func _convert_to_image_coord(x: float, z: float) -> Vector2:
	# origin is at -1024,-1024
	var local_pos = position + Vector3(x, 0, z)
	var terrain_pos = local_pos + Vector3(1024, 0, 1024)
	var image_pos = Vector2(floor(terrain_pos.x / 2), floor(terrain_pos.z / 2))
	return image_pos


func _get_value_for_channel(color: Color, mask: MaskChannel) -> float:
	var result: float
	match mask:
		MaskChannel.R:
			result = color.r
		MaskChannel.G:
			result = color.g
		MaskChannel.B:
			result = color.b
		_:
			result = 0.0
	return result
