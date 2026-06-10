extends Node3D

@onready var tangram :Tangram = %Tangram

@onready var save_path :TextEdit = %SavePath
@onready var file_name :TextEdit = %FileName
@onready var solution_check :RichTextLabel = %SolutionCheck


func _ready() -> void:
	tangram.solution_checked.connect(_on_solution_checked)
	
	$Sprite3D.load_screenshot(ResourceLoader.load("user://screenshots/screenshot_2026-05-22_153312.tres"))


func _on_solution_checked(solution :TangramSolutionStat) -> void:
	if solution != null:
		solution_check.text = solution.name
		tangram.animate_solution()
	else:
		solution_check.text = "NONE"


func save_solution() -> void:
	var solution :TangramSolutionStat = tangram.current_solution
	solution.compute_center_of_mass()
	solution.apply_center_of_mass()
	solution.name = file_name.text
	ResourceSaver.save(solution, save_path.text + file_name.text + ".tres")


func load_solution() -> void:
	var solution = ResourceLoader.load(save_path.text + file_name.text + ".tres")
	tangram.load_solution(solution)


func _on_button_pressed() -> void:
	save_solution()


func _on_button_2_pressed() -> void:
	load_solution()
