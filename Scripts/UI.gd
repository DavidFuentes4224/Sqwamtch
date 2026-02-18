class_name UI
extends CanvasLayer
## Binding layer for UI elements.

@onready var stamina_bar: ProgressBar = $Stamina/ProgressBarStamina
@onready var stamina_refil_bar: ProgressBar = $Stamina/ProgressBarStaminaRefill
@onready var items_info: Label = $Items/ItemsInfo
@onready var current_photo: int = 0

func set_max_sprint_value(value: float):
	stamina_bar.max_value = value
	stamina_refil_bar.max_value = value

func update_sprint_value(value: float):
	stamina_bar.value = value
	
func update_stamina_refill_value(value: float):
	stamina_refil_bar.value = value
	
func update_items_count(value: int, maxCount: int):
	items_info.text = "Items: %d/%d" % [value,maxCount]

func reset_refill_bar():
	stamina_refil_bar.value = 0.0

func update_photo_ui(texture: ImageTexture):
	if (current_photo == $Photos.get_child_count()):
		return
		
	var text_rect:TextureRect = $Photos.get_child(current_photo)
	text_rect.texture = texture
	var overlay: ColorRect = text_rect.get_child(0)
	overlay.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color", Color.TRANSPARENT, 10.0)
	current_photo += 1
