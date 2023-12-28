@tool
extends Node3D
@onready var ObjectContainer:Node3D = $Objects

@export var Enabled:bool
@export var PlaceItems:bool
@export var ItemToPlace:PackedScene
@export var spawnNoise:Texture2D

@export_category("Spawn Properties")
@export_range (0, 4000, 1) var MinHeight:=0
@export_range (0, 4000, 1) var MaxHeight:=4000
@export_range (0, 0.25, 0.01) var SpawnChance:=0.01

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
		
	_place_items()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlaceItems:
		PlaceItems = false
		_place_items()
	pass
	
func _place_items():
	if !Enabled and Engine.is_editor_hint():
		return
	if ItemToPlace == null:
		return;
	
	_clear_children()
	_load_height_map()
	_spawn_objects()
	
func _load_height_map():
	heightMap = Image.new()
	heightMap.load("res://Terrain/Height.exr")
	heightMap.convert(Image.FORMAT_RF)
	
func _clear_children():
	for n in ObjectContainer.get_children():
		ObjectContainer.remove_child(n)
		n.queue_free()

func _spawn_objects():
	for y in heightMap.get_height():
		for x in heightMap.get_width():
			var height = heightMap.get_pixel(x,y).r * 4000
			
			if SpawnChance > randf() and height < MaxHeight and height > MinHeight:
				_place(x,y,height)

func _place(x,y,h):
	var item = ItemToPlace.instantiate()
	ObjectContainer.add_child(item)
	var scaleX = 1 + (randf_range(-1,1) * scaleVariance)
	var scaleY = clamp(1 + (randf_range(-1,1) * scaleVariance), minItemHeight, maxItemHeight)
	var scaleZ = 1 + (randf_range(-1,1) * scaleVariance)
	
	item.scale = Vector3(scaleX,scaleY,scaleZ)
	var height = h - randf_range(0,depthOffset)
	item.position = Vector3(x*2,height,y*2)
