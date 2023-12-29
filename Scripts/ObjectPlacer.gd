@tool
extends Node3D
@onready var ObjectContainer:Node3D = $Objects

@export var ItemsPlaced:bool
@export var PlaceItems:bool
@export var ItemToPlace:PackedScene
@export var spawnNoise:Texture2D

@export_category("Spawn Settings")
@export var useHeightMap:bool=true
@export var SizeX:=100
@export var SizeZ:=100
@export_range(0, 1000) var Amount:= 50
@export_range (0, 4000, 1) var MinHeight:=0
@export_range (0, 4000, 1) var MaxHeight:=4000

@export_category("Spawn Variance")
@export var scaleVariance:float = 1.0
@export var minItemHeight:float = 0.75
@export var maxItemHeight:float = 1.25
@export var depthOffset:float = 3.0

var heightMap:Image

# Called when the node enters the scene tree for the first time.
func _ready():
	if (ItemToPlace == null):
		return
	if !ItemsPlaced and Engine.is_editor_hint():
		_place_items()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlaceItems:
		PlaceItems = false
		_place_items()
	pass
	
func _place_items():
	if ItemToPlace == null:
		return;
	
	_clear_children()
	_load_height_map()
	_spawn_objects()
	ItemsPlaced = true
	
func _load_height_map():
	heightMap = Image.new()
	heightMap.load("res://Terrain/Height.exr")
	heightMap.convert(Image.FORMAT_RF)
	
func _clear_children():
	for n in ObjectContainer.get_children():
		ObjectContainer.remove_child(n)
		n.queue_free()

func _spawn_objects():
	for t in Amount:
		_place_object(t)

func _place_object(index):
	var item = ItemToPlace.instantiate()
	ObjectContainer.add_child(item)
	item.name = "Tree %d" % index
	
	# Vary scale
	var scaleX = 1 + (randf_range(-1,1) * scaleVariance)
	var scaleY = clamp(1 + (randf_range(-1,1) * scaleVariance), minItemHeight, maxItemHeight)
	var scaleZ = 1 + (randf_range(-1,1) * scaleVariance)
	item.scale = Vector3(scaleX,scaleY,scaleZ)
	
	#Randomize Position
	var spawnPos = _get_spawn_location()
	item.position = spawnPos
	item.set_owner(ObjectContainer.get_owner())
	
func _get_spawn_location() -> Vector3:
	var valid = false
	var spawn = Vector3.ZERO
	if !useHeightMap:
		var x = randf_range(0, SizeX)
		var z = randf_range(0, SizeZ)
		var y = 0
		spawn = Vector3(x,y,z)
		return spawn
		
	while(!valid):
		var x = randf_range(0, SizeX)
		var z = randf_range(0, SizeZ)
		var y = _get_height_at_coord(x,z)
		y -= randf_range(0,depthOffset)
		if y < MaxHeight and y > MinHeight:
			valid = true
			spawn = Vector3(x,y,z)
	return spawn
	
func _get_height_at_coord(x:float,z:float) -> float:
	var localPos = position + Vector3(x, 0, z)
	var terrainPos = localPos + Vector3(1024, 0, 1024)
	var imagePos = Vector2(floor(terrainPos.x / 2), floor(terrainPos.z / 2))
	return heightMap.get_pixel(imagePos.x, imagePos.y).r * 4000
