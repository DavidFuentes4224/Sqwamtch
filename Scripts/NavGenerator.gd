@tool
extends Node3D
@onready var heightMap:Image
@onready var generatedMesh:MeshInstance3D = $GeneratedMesh 
#Size of unit sampled in meters
@export_category("MeshSettings")
@export var cellSpacing:int = 20
@export var zSize = 20
@export var xSize = 20
@export var meshScale:float = 1.0
@export var ShouldGenerate = false
var heightData = {}
var st:SurfaceTool

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
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
	
	clear_spheres()
	
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var offset = Vector2(position.x - 1024, position.z - 1024)
	
	# interate through vertex points
	for z in range(zSize):
		for x in range(xSize):
			create_quad(x,z)
			
	$GeneratedMesh.mesh = st.commit()
			
func create_quad(x,z):
	var startingOffset = Vector3(x * cellSpacing, 0 , z * cellSpacing)
	
	var bottomLeft = startingOffset
	bottomLeft.y = get_height_from_vertex_coord(x, z)
	
	# move spacing 1 unit to the right
	var bottomRight = startingOffset + (Vector3.RIGHT * cellSpacing)
	bottomRight.y = get_height_from_vertex_coord(x+1, z)
	
	var topRight = startingOffset + (Vector3.RIGHT * cellSpacing) + (Vector3.BACK * cellSpacing)
	topRight.y = get_height_from_vertex_coord(x+1, z+1)
	
	var topLeft = startingOffset + (Vector3.BACK * cellSpacing)
	topLeft.y = get_height_from_vertex_coord(x, z+1)
	
	#triangle 1
	st.add_vertex(bottomLeft)
	st.add_vertex(bottomRight)
	st.add_vertex(topRight)
	#triangle 2
	st.add_vertex(topRight)
	st.add_vertex(topLeft)
	st.add_vertex(bottomLeft)
	
func get_height_from_vertex_coord(x,z) -> float:
	var localPos = position + Vector3(x * cellSpacing, 0, z * cellSpacing)
	var terrainPos = localPos + Vector3(1024, 0, 1024)
	var imagePos = Vector2(floor(terrainPos.x / 2), floor(terrainPos.z / 2))
	return heightMap.get_pixel(imagePos.x, imagePos.y).r * 4000
	
func draw_sphere(pos:Vector3):
	var ins = MeshInstance3D.new()
	ins.add_to_group("Debug")
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere
	
func clear_spheres():
	var spheres = get_children()
	for sphere in spheres:
		if sphere.is_in_group("Debug"):
			remove_child(sphere)
			sphere.queue_free()
