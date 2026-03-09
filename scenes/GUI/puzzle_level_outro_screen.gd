extends Control

@onready var levelNameTxt :RichTextLabel = %LevelNameText
@onready var timeTxt :RichTextLabel = %TimeTxt
@onready var usedAbilitiesContainer = %UsedAbilitiesContainer
@onready var noItemUsed = %NoItemUsed

@onready var bestTimeContainer = %BestTimeContainer
@onready var bestTimeTxt = %BestTimeTxt

@onready var whirl_background = $CenterContainer
@export var background_rotate_speed :float = 10.0
@export var startAnimationDelay :float = 1.0
@export var stepAnimationDelay :float = 0.5

@export var levelStats :LevelStats = LevelStats.new()

@onready var abilityStatScene :PackedScene = load("res://UI/Components/AbilityStatPanel.tscn")



func _ready() -> void:

	if Global.current_level_stats != null:
		levelStats = Global.current_level_stats
	
	display_stats(levelStats)

	var completed_level_stats :LevelStats = SaveManager.save_game_res.puzzle_levels.try_get_completed_level(levelStats.seed)
	if completed_level_stats != null:
		display_saved_game_content(completed_level_stats)
	
	SaveManager.save_game_res.puzzle_levels.save(levelStats)


func _process(delta: float) -> void:
	
	whirl_background.rotation_degrees += delta * background_rotate_speed
	
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		_on_btn_back_pressed()
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()


func display_stats(stats :LevelStats) -> void:
	levelNameTxt.text = tr(Global.puzzle_level_res.name)
	timeTxt.text = Utils.seconds2hhmmss(stats.completionTime, true)
	fill_used_abilities()


func display_saved_game_content(saved_level :LevelStats) -> void:
	bestTimeContainer.visible = true
	bestTimeTxt.text = Utils.seconds2hhmmss(saved_level.completionTime, true)
	var timeDiff :float = saved_level.completionTime - levelStats.completionTime
	var timeTextColor :String = "green" if timeDiff > 0 else "red"
	if timeDiff == 0 : timeTextColor = "white"
	timeTxt.text = BBCodeString.new(timeTxt.text).set_color(timeTextColor).get_text()



func fill_used_abilities() -> void:
	for ability in levelStats.used_abilities:
		if ability.amount_used > 0:
			var obj :AbilityStatPanel = abilityStatScene.instantiate()
			usedAbilitiesContainer.add_child(obj)
			obj.init(ability)
	
	if usedAbilitiesContainer.get_children().is_empty():
		noItemUsed.visible = true


func _on_button_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	#Global.game_controller.start_new_game()


func _on_btn_replay_pressed() -> void:
	AudioBus.play_sfx("BTN_REPLAY")
	Global.game_controller.start_puzzle_level(Global.puzzle_level_res)


func _on_btn_back_pressed() -> void:
	Global.game_controller.return_to_puzzles_menu()
