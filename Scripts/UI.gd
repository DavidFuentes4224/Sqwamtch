class_name UI
extends CanvasLayer

@onready var staminaBar : ProgressBar = $Stamina/ProgressBarStamina
@onready var staminaRefilBar : ProgressBar = $Stamina/ProgressBarStaminaRefill
@onready var itemsInfo:Label = $Items/ItemsInfo
@onready var current_photo:int = 0

func set_max_sprint_value(value:float) -> void:
	staminaBar.max_value = value
	staminaRefilBar.max_value = value

func update_sprint_value(value:float) -> void:
	staminaBar.value = value
	
func update_stamina_refill_value(value:float) -> void:
	staminaRefilBar.value = value
	
func update_items_count(value:int, maxCount:int) -> void:
	itemsInfo.text = "Items: %d/%d" % [value,maxCount]

func reset_refill_bar() -> void:
	staminaRefilBar.value = 0.0

func update_photo_ui(texture:ImageTexture):
	if (current_photo == $Photos.get_child_count()):
		return
		
	var text_rect:TextureRect = $Photos.get_child(current_photo)
	text_rect.texture = texture
	var overlay:ColorRect = text_rect.get_child(0)
	overlay.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color", Color.TRANSPARENT, 1.0)
	current_photo += 1
