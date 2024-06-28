extends CanvasLayer

@onready var audioPlayer:AudioStreamPlayer2D = $AudioPlayer

var mainScene = load("res://Nodes/Levels/Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(mainScene)
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_play_button_mouse_entered():
	_play_hover_sound()
	
func _on_quit_button_mouse_entered():
	_play_hover_sound()

func _play_hover_sound() -> void:
	audioPlayer.play()
