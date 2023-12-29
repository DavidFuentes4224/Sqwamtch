class_name UI
extends CanvasLayer

@onready var staminaBar : ProgressBar = $Stamina/ProgressBarStamina
@onready var staminaRefilBar : ProgressBar = $Stamina/ProgressBarStaminaRefill
@onready var itemsInfo:Label = $Items/ItemsInfo

func set_max_sprint_value(value:float) -> void:
	staminaBar.max_value = value
	staminaRefilBar.max_value = value

func update_sprint_value(value:float) -> void:
	staminaBar.value = value
	
func update_stamina_refill_value(value:float) -> void:
	staminaRefilBar.value = value
	
func update_items_count(value:int, max:int) -> void:
	itemsInfo.text = "Items: %d/%d" % [value,max]

func reset_refill_bar() -> void:
	staminaRefilBar.value = 0.0
