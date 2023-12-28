@tool
extends MeshInstance3D
@export var PackScene:bool=false
@export var BuildName:="BuiltLake"

func _process(delta):
	if PackScene:
		PackScene = false
		_pack_scene()

func _pack_scene():
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK:
		var error = ResourceSaver.save(scene, "res://Terrain/%s.tscn" % BuildName)
		if error != OK:
			push_error("An error occured while saving the scene to disk.")
