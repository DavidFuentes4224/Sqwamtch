@tool
class_name ObjectPlacer
extends Node3D
## Reads height data to place various objects.

enum MaskChannel {R, G, B}

@export var items_placed: bool
@export var place_items: bool
# look into making this an array of objects to place
@export_category("Item Settings")
@export var item_to_place: PackedScene
@export var item_name_template: String = "SpawnedObject"

@export_category("Masks")
@export var object_placement_mask: Texture2D
@export_range(0,1) var spawn_threshold: float = 0.0
@export var mask_channel: MaskChannel = MaskChannel.R
@export var use_avoid_mask: bool = true
@export var avoid_mask_channel: MaskChannel = MaskChannel.G

@export_category("Spawn Settings")
@export var use_height_map: bool=true
@export var size_x: = 100
@export var size_z: = 100
@export_range(0, 1000) var amount:= 50
@export_range (0, 4000, 1) var min_height:=0
@export_range (0, 4000, 1) var max_height:=4000

@export_category("Spawn Variance")
@export var scale_variance: float = 1.0
@export var min_item_height: float = 0.75
@export var max_item_height: float = 1.25
@export var depth_offset: float = 3.0

var height_map: Image

@onready var object_container: Node3D = $Objects


func _ready():
	if (item_to_place == null):
		return
	if !items_placed and Engine.is_editor_hint():
		_place_items()


func _process(_delta):
	if place_items:
		place_items = false
		_place_items()


func _place_items():
	if item_to_place == null:
		return;
	
	_clear_children()
	_load_height_map()
	_spawn_objects()
	items_placed = true


func _load_height_map():
	height_map = Image.new()
	height_map.load("res://Terrain/Height.exr")
	height_map.convert(Image.FORMAT_RF)


func _clear_children():
	for n in object_container.get_children():
		object_container.remove_child(n)
		n.queue_free()


func _spawn_objects():
	for t in amount:
		_place_object(t)


func _place_object(index):
	var item = item_to_place.instantiate()
	object_container.add_child(item)
	item.name = "%s %d" % [item_name_template, index]
	
	# Vary scale
	var obj_scale_x = 1 + (randf_range(-1,1) * scale_variance)
	var obj_scale_y = clamp(1 + (randf_range(-1,1) * scale_variance), min_item_height, max_item_height)
	var obj_scale_z = 1 + (randf_range(-1,1) * scale_variance)
	item.scale = Vector3(obj_scale_x,obj_scale_y,obj_scale_z)
	
	#Randomize Position
	var spawn_pos = _get_spawn_location()
	item.position = spawn_pos
	item.set_owner(object_container.get_owner())


func _get_spawn_location() -> Vector3:
	var valid = false
	var spawn = Vector3.ZERO
	if not use_height_map:
		var x = randf_range(0, size_x)
		var z = randf_range(0, size_z)
		var y = 0
		spawn = Vector3(x,y,z)
		return spawn
		
	var spawnMask: Image = null
	if object_placement_mask != null:
		spawnMask = object_placement_mask.get_image()
		
	while not valid:
		var x = randf_range(0, size_x)
		var z = randf_range(0, size_z)
		if spawnMask != null:
			var image_pos = _convert_to_image_coord(x,z)
			var maskColor:Color = spawnMask.get_pixel(image_pos.x,image_pos.y)
			var spawnValue = _get_value_for_channel(maskColor, mask_channel)
			if spawnValue <= spawn_threshold:
				continue;
			if use_avoid_mask:
				var avoidValue = _get_value_for_channel(maskColor, avoid_mask_channel)
				if avoidValue > 0.0:
					continue;

		var y = _get_height_at_coord(x,z)
		y -= randf_range(0,depth_offset)
		if y < max_height and y > min_height:
			valid = true
			spawn = Vector3(x,y,z)
	return spawn


func _get_value_for_channel(color: Color, mask: MaskChannel) -> float:
	var result: float
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


func _convert_to_image_coord(x: float, z: float) -> Vector2:
	# origin is at -1024,-1024
	var local_pos = position + Vector3(x, 0, z)
	var terrain_pos = local_pos + Vector3(1024, 0, 1024)
	var image_pos = Vector2(floor(terrain_pos.x / 2), floor(terrain_pos.z / 2))
	return image_pos


func _get_height_at_coord(x: float, z: float) -> float:
	var image_pos = _convert_to_image_coord(x,z)
	return height_map.get_pixel(image_pos.x, image_pos.y).r * 4000
