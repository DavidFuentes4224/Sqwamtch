class_name PolaroidFilm
extends Node3D
## Facilites updating the image of a visual film photo.

@onready var img_mesh: MeshInstance3D = $PictureBackMesh/PictureMesh

func set_picture(texture: ImageTexture):
	img_mesh.get_surface_override_material(0).set("albedo_texture", texture)
