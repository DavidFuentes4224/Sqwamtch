extends Node3D
class_name PolaroidFilm

@onready var ImgMesh:MeshInstance3D = $PictureBackMesh/PictureMesh

func SetPicture(texture:ImageTexture):
	ImgMesh.get_surface_override_material(0).set("albedo_texture", texture)
