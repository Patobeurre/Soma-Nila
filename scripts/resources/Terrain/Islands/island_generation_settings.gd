extends Resource
class_name IslandGenerationSettings


@export var seed :int = 0
@export var useRandomSeed :bool = false

@export var terrainSize :Vector3 = Vector3(20, 20, 20)
@export var tile_scale :Vector3 = Vector3(20, 20, 20)
@export var terrain_scale :Vector3 = Vector3(20, 20, 20)
@export var main_noise :FastNoiseLite = FastNoiseLite.new()
@export var island_noise :FastNoiseLite = FastNoiseLite.new()
@export var color_treshold :float = 0.5
@export var island_back_curve :CurveTexture
@export var density :float = 0.02

@export var tileGenSettings :TileGenerationSettings = TileGenerationSettings.new()

var rng :RandomNumberGenerator = RandomNumberGenerator.new()
var noiseImage :Image = Image.new()

@export var positions_matrix :Matrix3D = Matrix3D.new()



func init(new_seed :int = -1):
	seed = new_seed
	useRandomSeed = (seed < 0)
	tileGenSettings.init(new_seed)
	initialize_rng()
	positions_matrix.initialize_with(terrainSize, 0)


func initialize_rng() -> void:
	if useRandomSeed:
		rng.randomize()
		rng.seed = randi() % 10000000
	else:
		rng.seed = seed
	tileGenSettings.initialize_rng()


func change_seed() -> void:
	var new_seed = rng.randi() % 10000000
	init(new_seed)


func generate_noise_texture() -> Image:
	var noise = main_noise
	var noiseTexture = NoiseTexture2D.new()
	noise.seed = rng.seed
	noiseTexture.noise = noise
	await noiseTexture.changed
	noiseImage = noiseTexture.get_image()
	noiseImage.convert(Image.FORMAT_L8)
	return noiseImage


func compute_all_positions() -> void:

	for x :int in range(terrainSize.x):
		for y :int in range(terrainSize.z):
			if rng.randf() < density:
				var value :Color = noiseImage.get_pixel(x, y)
				if value.r < color_treshold:
					var new_val = convert_color_to_value(value)
					var global_pos = Vector3(x, 10, y)
					var positions = generate_positions_by_value(value.r)
					for p in positions:
						positions_matrix.set_value((global_pos + p), 1)
	
	#positions_matrix.save()


func generate_positions_by_value(value) -> Array:
	var nb_blocs = (int) ((island_back_curve.curve.sample(value) * 3) + island_back_curve.curve.sample(value) * rng.randf() * 3)
	var positions = []
	nb_blocs = max(1, nb_blocs)
	for i in range(nb_blocs):
		positions.append(Vector3(0, -i, 0))
	return positions


func convert_color_to_value(color :Color) -> float:
	var s = (color.r-0.5) * 2 * terrain_scale.y
	var q = tile_scale.y * round(s / tile_scale.y)
	return max(-terrain_scale.y, min(terrain_scale.y, q))
