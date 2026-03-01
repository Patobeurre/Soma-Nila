extends PanelContainer


@export var custom_level_res :MainLevelRes = MainLevelRes.new()

@onready var abilities_settings :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")
@onready var terrain_settings :TerrainGenerationSettings = load("res://scripts/resources/Terrain/GenerationSettings.tres")
@onready var noise_params :FastNoiseLite = load("res://scripts/resources/Terrain/SimplexNoise.tres")
@onready var tile_gen_settings :TileGenerationSettings = load("res://scripts/resources/Terrain/TileGenSettings.tres")

@onready var abilitiesContainer :GridContainer = $MarginContainer/VBoxContainer/VBoxContainer/AbilitiesContainer
@onready var seed_value :SpinBox = $MarginContainer/VBoxContainer/VBoxContainer/SeedValue/SB_SeedValue

@onready var abilityButtonScene :PackedScene = load("res://UI/Components/AbilityEnableButtonSetting.tscn")


func _ready() -> void:
	custom_level_res.isCustom = true
	custom_level_res.abilitiesSettings = abilities_settings.duplicate(true)
	custom_level_res.terrainSettings = terrain_settings.duplicate(true)
	custom_level_res.terrainSettings.noiseParams = noise_params.duplicate(true)
	custom_level_res.terrainSettings.tileGenSettings = tile_gen_settings.duplicate(true)
	fill_abilities_container()


func fill_abilities_container() -> void:
	for ability in custom_level_res.abilitiesSettings.all_abilities:
		var obj :AbilityEnableButton = abilityButtonScene.instantiate()
		abilitiesContainer.add_child(obj)
		obj.init(ability)
		obj.btn_ability_pressed.connect(_on_ability_toggled)


func _on_ability_toggled(ability :StateRes):
	var remaining_abilities :int = custom_level_res.abilitiesSettings.all_abilities.size() - custom_level_res.abilitiesSettings.excluded_abilities.size()
	
	if custom_level_res.abilitiesSettings.excluded_abilities.has(ability):
		var idx = custom_level_res.abilitiesSettings.excluded_abilities.find(ability)
		custom_level_res.abilitiesSettings.excluded_abilities.remove_at(idx)
		AudioBus.play_sfx("TOGGLE_ON")
	elif remaining_abilities > 1:
		custom_level_res.abilitiesSettings.excluded_abilities.append(ability)
		AudioBus.play_sfx("TOGGLE_OFF")
		
	update_abilities_container()


func update_abilities_container() -> void:
	for child in abilitiesContainer.get_children():
		child.update(custom_level_res.abilitiesSettings.excluded_abilities)


func fix_seed_value() -> void:
	custom_level_res.seed = seed_value.value


func _on_cb_rnd_seed_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioBus.play_sfx("TOGGLE_ON")
	else:
		AudioBus.play_sfx("TOGGLE_OFF")
	seed_value.editable = !toggled_on
	custom_level_res.useRandomSeed = toggled_on
	custom_level_res.seed = seed_value.value


func _on_sb_seed_value_value_changed(value: float) -> void:
	custom_level_res.seed = seed_value.value


func _on_cb_allow_duplicate_items_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioBus.play_sfx("TOGGLE_ON")
	else:
		AudioBus.play_sfx("TOGGLE_OFF")
	custom_level_res.abilitiesSettings.allowSameAbilities = toggled_on
