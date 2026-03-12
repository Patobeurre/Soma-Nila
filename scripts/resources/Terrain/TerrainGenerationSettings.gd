extends Resource
class_name TerrainGenerationSettings


@export var seed :int = 0
@export var useRandomSeed :bool = false

@export var terrainSize :Vector3 = Vector3(20, 20, 20)
@export var tile_scale :Vector3 = Vector3(20, 20, 20)
@export var terrain_scale :Vector3 = Vector3(20, 20, 20)
@export var noiseParams :FastNoiseLite = FastNoiseLite.new()
@export var density :float = 0.02

@export var tileGenSettings :TileGenerationSettings = TileGenerationSettings.new()
@export var terrainSettingStats :TerrainSettingStats = TerrainSettingStats.new()

var rng :RandomNumberGenerator = RandomNumberGenerator.new()
var noiseImage :Image = Image.new()


func init(new_seed :int = -1):
	seed = new_seed
	useRandomSeed = (seed < 0)
	tileGenSettings.init(new_seed)
	initialize_rng()


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
	var noise = noiseParams
	var noiseTexture = NoiseTexture2D.new()
	noise.seed = rng.seed
	noiseTexture.noise = noise
	await noiseTexture.changed
	noiseImage = noiseTexture.get_image()
	noiseImage.convert(Image.FORMAT_L8)
	return noiseImage


func compute_all_positions() -> Array:
	var all_positions :Array = []
	
	for x :int in range(0, terrainSize.x):
		for y :int in range(0, terrainSize.z):
			if rng.randf() < density:
				var value :Color = noiseImage.get_pixel(x, y)
				var new_val = convert_color_to_value(value)
				var global_pos = Vector3(x * terrain_scale.x, new_val, y * terrain_scale.z)
				var positions = tileGenSettings.get_random_walk_positions()
				for p in positions:
					all_positions.append(global_pos + p * tile_scale)
	
	return Utils.get_unique_array(all_positions)


func convert_color_to_value(color :Color) -> float:
	var s = (color.r-0.5) * 2 * terrain_scale.y
	var q = tile_scale.y * round(s / tile_scale.y)
	return max(-terrain_scale.y, min(terrain_scale.y, q))


func adjust_params_by_ability_weights(weights :Array[AbilityWeights]) -> void:
	var weight_sum :AbilityWeights = AbilityWeights.new()
	
	for w in weights:
		weight_sum.add(w)
	
	#var far :int = Utils.get_closest_factor(weight_sum.pointFar, 4)
	var far :int = ceil(weight_sum.pointFar) * 4
	tileGenSettings.nbIter += weight_sum.pointSpread
	terrain_scale += Vector3(far, weight_sum.pointUp, far)
	
	#terrainSize += Vector3(weight_sum.pointFar, weight_sum.pointUp, weight_sum.pointFar)
	#terrain_scale += Vector3(0, weight_sum.pointUp, 0)
