extends Node

var main_game_path: String = "res://main.tscn"
var start_menu_path: String = "res://Menu/StartMenu.tscn"

var side1_ai : bool = true
var side2_ai : bool = false

var unit_number: int = 6

# Resets settings to default values
func resetSettings() -> void:
    side1_ai = true
    side2_ai = false
    unit_number = 6