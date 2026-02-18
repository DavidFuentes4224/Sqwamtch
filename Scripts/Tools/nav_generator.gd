@tool
class_name NavGenerator
extends Node3D
## Generates a navigation mesh based on height map data.

#Size of unit sampled in meters
@export_category("MeshSettings")
@export var cell_spacing:int = 20
@export var z_size = 20
@export var x_size = 20
@export var should_generate = false

var surface_tool: SurfaceTool

@onready var height_map:Image
@onready var generated_mesh:MeshInstance3D = $GeneratedMesh 

func _ready():
	if Engine.is_editor_hint():
		_generate_mesh()


func _process(_delta):
	if should_generate:
		should_generate = false
		_generate_mesh()


func _generate_mesh():
	# image is 1024x1024
	height_map = Image.new()
	height_map.load("res://Terrain/Height.exr")
	height_map.convert(Image.FORMAT_RF)
	
	clear_spheres()
	
	surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# interate through vertex points
	for z in range(z_size):
		for x in range(x_size):
			create_quad(x,z)
			
	generated_mesh.mesh = surface_tool.commit()


func create_quad(x: int, z: int):
	var starting_offset = Vector3(x * cell_spacing, 0 , z * cell_spacing)
	
	var bottom_left = starting_offset
	bottom_left.y = get_height_from_vertex_coord(x, z)
	
	# move spacing 1 unit to the right
	var bottom_right = starting_offset + (Vector3.RIGHT * cell_spacing)
	bottom_right.y = get_height_from_vertex_coord(x+1, z)
	
	var top_right = starting_offset + (Vector3.RIGHT * cell_spacing) + (Vector3.BACK * cell_spacing)
	top_right.y = get_height_from_vertex_coord(x+1, z+1)
	
	var top_left = starting_offset + (Vector3.BACK * cell_spacing)
	top_left.y = get_height_from_vertex_coord(x, z+1)
	
	#triangle 1
	surface_tool.add_vertex(bottom_left)
	surface_tool.add_vertex(bottom_right)
	surface_tool.add_vertex(top_right)
	#triangle 2
	surface_tool.add_vertex(top_right)
	surface_tool.add_vertex(top_left)
	surface_tool.add_vertex(bottom_left)


func get_height_from_vertex_coord(x: int, z: int) -> float:
	var local_pos = position + Vector3(x * cell_spacing, 0, z * cell_spacing)
	var terrain_pos = local_pos + Vector3(1024, 0, 1024)
	var image_pos = Vector2(floor(terrain_pos.x / 2), floor(terrain_pos.z / 2))
	return height_map.get_pixel(image_pos.x, image_pos.y).r * 4000


func draw_sphere(pos:Vector3):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.add_to_group("Debug")
	add_child(mesh_instance)
	mesh_instance.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	mesh_instance.mesh = sphere


func clear_spheres():
	var spheres = get_children()
	for sphere in spheres:
		if sphere.is_in_group("Debug"):
			remove_child(sphere)
			sphere.queue_free()
