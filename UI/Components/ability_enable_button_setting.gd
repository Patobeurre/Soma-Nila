extends PanelContainer
class_name AbilityEnableButton


@export var abilityRes :StateRes

@onready var iconButton :TextureButton = $TextureButton
@onready var darkMask :PanelContainer = $DarkMask

signal btn_ability_pressed(StateRes)


func init(res :StateRes):
	abilityRes = res
	iconButton.texture_normal = abilityRes.icon


func update(excludedAbilities :Array):
	darkMask.visible = excludedAbilities.has(abilityRes)


func _on_texture_button_pressed() -> void:
	btn_ability_pressed.emit(abilityRes)
