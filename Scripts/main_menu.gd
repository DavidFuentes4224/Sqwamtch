class_name MainMenu
extends CanvasLayer
## Handles main menu interaction and sound.

var main_scene = load("res://Nodes/Levels/Main.tscn")

@onready var audio_player:AudioStreamPlayer2D = $AudioPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(main_scene)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_mouse_entered():
	_play_hover_sound()


func _on_quit_button_mouse_entered():
	_play_hover_sound()


func _play_hover_sound():
	audio_player.play()
