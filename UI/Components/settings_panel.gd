extends PanelContainer


var resolution_values :Array = [
	"1280x720",
	"1680x1050",
	"1920x1080",
	"3840x2160"
]
var defaultResolutionIdx = 2

var msaa_values :Dictionary = {
	Viewport.MSAA_DISABLED : "None",
	Viewport.MSAA_2X : "x2",
	Viewport.MSAA_4X : "x4",
	Viewport.MSAA_8X : "x8"
}

var language_values :Array = ["en", "fr_FR"]

var custom_properties :Array[Dictionary] = [
	{ 
		"name": "custom/speedrun_mode",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Activate speedrun mode"
	},
]


func _ready() -> void:
	_fill_msaa_options()
	_fill_resolution_options()
	_fill_language_options()
	_init_mouse_sensitivity()
	_init_camera_fov()
	_init_custom_settings()

	update_fullscreen()
	update_speedrun_mode()
	update_volume_sliders()


# Anti-aliasing

@onready var msaa_options = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer/VBoxContainer/AntialiasingContainer/Dropdown_AntiAliasing

func _fill_msaa_options() -> void:
	var current_msaa_value = ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d")
	
	for key in msaa_values.keys():
		msaa_options.add_item(msaa_values[key])
		if current_msaa_value == key:
			msaa_options.select(msaa_options.item_count-1)

func _on_dropdown_anti_aliasing_item_selected(index: int) -> void:
	if not msaa_values.has(index):
		return
	
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", msaa_values.keys()[index])
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", msaa_values.keys()[index])
	RenderingServer.viewport_set_msaa_3d(get_tree().get_root().get_viewport_rid(), msaa_values.keys()[index])
	RenderingServer.viewport_set_msaa_2d(get_tree().get_root().get_viewport_rid(), msaa_values.keys()[index])


## Fullscreen

@onready var cb_fullscreen: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer/VBoxContainer/FullscreenContainer/CB_Fullscreen

func update_fullscreen() -> void:
	var window_mode = ProjectSettings.get_setting("display/window/size/mode")
	cb_fullscreen.button_pressed = (window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_cb_fullscreen_toggled(toggled_on: bool) -> void:
	var window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_MAXIMIZED
	
	ProjectSettings.set_setting("display/window/size/mode", window_mode)
	DisplayServer.window_set_mode(window_mode)


## Resolution options

@onready var resolution_options: OptionButton = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer/VBoxContainer/ResolutionContainer/Dropdown_Resolution

func _fill_resolution_options() -> void:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var current_resolution = str(width) + "x" + str(height)
	
	for value in resolution_values:
		resolution_options.add_item(value)
		if current_resolution == value:
			resolution_options.select(resolution_options.item_count-1)

func _on_dropdown_resolution_item_selected(index: int) -> void:
	var selected_resolution: String = resolution_options.get_item_text(index)
	var resolution_parts: Array = selected_resolution.split("x")
	var width: int = int(resolution_parts[0])
	var height: int = int(resolution_parts[1])

	get_window().content_scale_size = Vector2(width, height)
	
	ProjectSettings.set_setting("display/window/size/viewport_width", width)
	ProjectSettings.set_setting("display/window/size/viewport_height", height)


## Language options

@onready var language_options: OptionButton = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/ResolutionContainer/Dropdown_Languages

func _fill_language_options() -> void:
	var current_language_value = TranslationServer.get_locale()
	
	for lang in language_values:
		language_options.add_item(TranslationServer.get_locale_name(lang))
		if current_language_value == lang:
			language_options.select(language_options.item_count-1)

func _on_dropdown_languages_item_selected(index: int) -> void:
	ProjectSettings.set_setting("internationalization/locale/fallback", language_values[index])
	TranslationServer.set_locale(language_values[index])


# Volume

@onready var master_slider :Slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/MasterVolumeContainer/MasterHSlider
@onready var music_slider :Slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/MusicVolumeContainer/MusicHSlider
@onready var sfx_slider :Slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/SFXVolumeContainer/SFXHSlider

var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

func _on_master_h_slider_value_changed(value :float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	_save_bus_layout()

func _on_music_h_slider_value_changed(value :float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	_save_bus_layout()

func _on_sfxh_slider_value_changed(value :float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	_save_bus_layout()

func _on_sfxh_slider_drag_ended(value_changed:bool) -> void:
	AudioBus.play_sfx("BTN_OK")

func update_volume_sliders() -> void:
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

func _save_bus_layout() -> void:
	var default_bus_layout :AudioBusLayout = load("res://default_bus_layout.tres")
	default_bus_layout = AudioServer.generate_bus_layout()
	ResourceSaver.save(default_bus_layout, "res://default_bus_layout.tres")


# Mouse sensitivity

@onready var sensitivity_slider :HSlider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/MouseSensitivityContainer/MouseSensitivityHSlider
@onready var sensitivity_value :RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/MouseSensitivityContainer/MouseSensitivityValue

func _on_mouse_sensitivity_h_slider_value_changed(value :float) -> void:
	var sensitivity :float = clampf(value, 0.1, 2.0)
	ProjectSettings.set_setting("display/mouse_cursor/mouse_sensitivity", Vector2(sensitivity, sensitivity))
	_update_sensitivity_value()

func _init_mouse_sensitivity():
	sensitivity_slider.value = ProjectSettings.get_setting("display/mouse_cursor/mouse_sensitivity").x
	_update_sensitivity_value()

func _update_sensitivity_value():
	sensitivity_value.text = str(ProjectSettings.get_setting("display/mouse_cursor/mouse_sensitivity").x * 100).pad_decimals(0)


# Camera FOV

@onready var fov_slider :HSlider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/CameraFOVContainer2/CameraFOVHSlider
@onready var fov_value :RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/CameraFOVContainer2/CameraFOVValue

func _on_camera_fovh_slider_value_changed(value :float) -> void:
	var fov :float = clampf(value, 50, 120)
	ProjectSettings.set_setting("rendering/camera/depth_of_field/fov", fov)
	_update_camera_fov_value()

func _init_camera_fov():
	fov_slider.value = ProjectSettings.get_setting("rendering/camera/depth_of_field/fov")
	_update_camera_fov_value()

func _update_camera_fov_value():
	fov_value.text = str(ProjectSettings.get_setting("rendering/camera/depth_of_field/fov")).pad_decimals(0)


# Custom Settings

func _init_custom_settings() -> void:
	for custom_prop in custom_properties:
		if !ProjectSettings.has_setting(custom_prop.name):
			ProjectSettings.add_property_info(custom_prop)


@onready var cb_speedrunmode :CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer3/VBoxContainer/SpeedrunModeContainer/CB_SpeedrunMode

func update_speedrun_mode() -> void:
	var toggled :bool = ProjectSettings.get_setting("custom/speedrun_mode")
	cb_speedrunmode.button_pressed = (toggled)

func _on_cb_speedrun_mode_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("custom/speedrun_mode", toggled_on)
