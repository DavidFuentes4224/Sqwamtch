@tool
class_name LakeTerrain
extends MeshInstance3D
## Saves the scene to a dedicate file. Used for storing the results of terrain generation.

@export var pack_scene: bool = false
@export var build_name: = "BuiltLake"

func _process(_delta):
	if pack_scene:
		pack_scene = false
		_pack_scene()


func _pack_scene():
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK:
		var error = ResourceSaver.save(scene, "res://Terrain/%s.tscn" % build_name)
		if error != OK:
			push_error("An error occured while saving the scene to disk.")
