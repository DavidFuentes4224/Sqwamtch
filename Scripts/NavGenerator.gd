@tool
extends Node3D
@onready var heightMap:Image
@onready var generatedMesh:MeshInstance3D = $GeneratedMesh 
#Size of unit sampled in meters
@export_category("MeshSettings")
@export var cellSpacing:int = 2
@export var zSize = 20
@export var xSize = 20
@export var meshScale:float = 1.0
@export var ShouldGenerate = false
var heightData = {}
var st:SurfaceTool

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_mesh()
	pass # Replace with function body.
	
func _process(delta):
	if ShouldGenerate:
		ShouldGenerate = false
		_generate_mesh()

func _generate_mesh():
	# image is 1024x1024
	heightMap = Image.new()
	heightMap.load("res://Terrain/Height.exr")
	heightMap.convert(Image.FORMAT_RF)
	
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var offset = Vector2(position.x - 1024, position.z - 1024)
	
	# interate through vertex points
	for z in range(zSize):
		for x in range(xSize):
			var localPos = position
			var terrainPos = position - Vector3(1024,0,1024)
			create_quad(x,z)
			
	$GeneratedMesh.mesh = st.commit()
			
func create_quad(x,z):
	var bottomLeft = Vector3(x * cellSpacing,0, z * cellSpacing)
	bottomLeft.y = get_height_from_world_pos(bottomLeft)
	
	var bottomRight = Vector3(bottomLeft.x + cellSpacing, 0 ,bottomLeft.z)
	bottomRight.y = get_height_from_world_pos(bottomRight)
	
	var topRight = Vector3(bottomLeft.x + cellSpacing, 0,bottomLeft.z + cellSpacing)
	topRight.y = get_height_from_world_pos(topRight)
	
	var topLeft = Vector3(bottomLeft.x, 0 , bottomLeft.z + cellSpacing)
	topLeft.y = get_height_from_world_pos(topLeft)
	
	#triangle 1
	st.add_vertex(bottomLeft)
	st.add_vertex(bottomRight)
	st.add_vertex(topRight)
	#triangle 2
	st.add_vertex(topRight)
	st.add_vertex(topLeft)
	st.add_vertex(bottomLeft)
	
func get_height_from_world_pos(pos:Vector3) -> float:
	#convert from local to terrain space
	#terrain is 2048x2048, with origin at center
	var x = clamp(pos.x-1024,0,2048)
	var z = clamp(pos.z-1024,0,2048)
	var terrainPos = Vector3(x, 0, z)
	#convert to pixel coordinates
	#1px is 2m
	var u = floor(x/2)
	var v = floor(z/2)
	var height = heightMap.get_pixel(x,z).r * 4000
	print("height at %d,%d is %f" % [u,v,height])
	return height
	
func draw_sphere(pos:Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere
