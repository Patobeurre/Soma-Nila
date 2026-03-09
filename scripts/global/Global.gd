extends Node


var game_controller :GameController

var main_level_res :MainLevelRes = MainLevelRes.new()
var current_level_stats :LevelStats = LevelStats.new()

var puzzle_level_res :PuzzleLevelRes = PuzzleLevelRes.new()

var player_global_pos :Vector3 = Vector3.ZERO
var player_camera_orientation :Vector3 = Vector3.ZERO


const SECRET_LEVEL_SEED :int = 153269

var all_conversation_seeds :Array = [1628, 881544, 3679593, 153269]

