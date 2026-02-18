class_name FPSTracker
extends Node
## Tracks the FPS!

@onready var label: Label = $Panel/FPSLabel

func _process(_delta):
	label.text = "FPS: %d" % Engine.get_frames_per_second()
