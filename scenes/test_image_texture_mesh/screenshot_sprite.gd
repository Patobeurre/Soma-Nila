extends Sprite3D
class_name PhotoDocument


@export var image :CompressedTexture2D = CompressedTexture2D.new()

@export var desired_height = 1.0

@export var region_width :float = 1300
@export var region_height :float = 1000


func _ready() -> void:
	load_texture(ImageTexture.create_from_image(image.get_image()))


func load_texture(image_texture :ImageTexture) -> void:

	if not image_texture: return

	var texture_height = image_texture.get_height()

	var atlas_texture :AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = image_texture
	atlas_texture.region = Rect2(400, 0, region_width, region_height)

	texture = atlas_texture

	pixel_size = desired_height / texture_height


func load_screenshot(screenshot :ScreenshotRes) -> void:

	var image_texture = screenshot.texture
	load_texture(image_texture)
