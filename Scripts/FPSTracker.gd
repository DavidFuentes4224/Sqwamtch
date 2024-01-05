extends Node
@onready var label:Label = $Panel/FPSLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = "FPS: %d" % Engine.get_frames_per_second()
	pass
