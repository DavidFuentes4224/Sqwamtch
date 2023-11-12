@tool
extends Node3D
@onready var heightMap:Image
@export var width:float
@export var height:float
@onready var generatedMesh:MeshInstance3D = $GeneratedMesh 
#Size of unit sampled in meters
@export var meshRes:int = 2
@export var ShouldGenerate = false
var heightData = {}
var st = SurfaceTool.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_mesh()
	pass # Replace with function body.
	
func _process(delta):
	if ShouldGenerate:
		ShouldGenerate = false
		_generate_mesh()

func _generate_mesh():
	heightMap = Image.new()
	heightMap.load("res://Terrain/Height.exr")
	heightMap.convert(Image.FORMAT_RF)
	
	#get world space offset
	#texture starts at 0,0; but transform basis is at 1000,1000
	var startingX:float = clamp(global_position.x + 1000, 0, 2000)
	var startingY:float = clamp(global_position.y + 1000, 0, 2000)
	
	# 1px of data cover 2m of space
	var meshToImageRatio = 2
	var generatingX = true
	var generatingY = true
	
	for y in range(startingY, clamp(startingY + height,0, heightMap.get_height())):
		if y % meshRes == 0:
			for x in range(startingX, clamp(startingX + width, 0, heightMap.get_width())):
				if x % meshRes == 0:
					#sample texture
					heightData[Vector2(x,y)] = heightMap.get_pixel(x,y).r * 4000
			
	#for y in range(startingY, clamp(startingY + height,0, heightMap.get_height())):
		#for x in range(startingX, clamp(startingX + width, 0, heightMap.get_width())):
			#_createQuad(x,y)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_uv(Vector2(0, 0))
	# Call last for each vertex, adds the above attributes.
	st.add_vertex(Vector3(-1, -1, 0))

	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(-1, 1, 0))

	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 1, 0))
	
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	generatedMesh.mesh = mesh
			
func _createQuad(x,y):
	var vert1
	var vert2
	var vert3
	var side1
	var side2
	var normal
	vert1 = Vector3(x, heightData[Vector2(x,y)],-y)
	vert2 = Vector3(x, heightData[Vector2(x,y+meshRes)],-y-meshRes)
	vert3 = Vector3(x, heightData[Vector2(x+meshRes,y)],-y-meshRes)
	
