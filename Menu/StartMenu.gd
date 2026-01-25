extends Control


func _ready():
	GlobalSettings.resetSettings()
	pass # Replace with function body.


# Changes scene to main game scene
func startGame():
	if GlobalSettings.main_game_path == "":
		push_error("Main game scene location is not set in MainMenuScene.gd")
		return
	
	get_tree().change_scene_to_file(GlobalSettings.main_game_path)

# button signal functions

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_instructions_button_pressed() -> void:
	pass # Replace with function body.

func _on_start_game_button_pressed() -> void:
	startGame()

func _on_side_2ai_button_item_selected(index: int) -> void:
	GlobalSettings.side2_ai = index == 1

func _on_side_1ai_button_item_selected(index: int) -> void:
	GlobalSettings.side1_ai = index == 1

func _on_unit_number_spin_box_value_changed(value: float) -> void:
	GlobalSettings.unit_number = int(value)