extends Control

@onready var end_turn_button: Button = $VBoxContainer/HBoxContainer/Button
@onready var player_name_text: Label = $VBoxContainer/Label
@onready var turn_text: Label = $VBoxContainer/Label2

func _ready():
	pass # Replace with function body.

# Bind the end turn button to the provided function
func bindSignals(end_turn_function: Callable) -> void:
	# if end_turn_button is already connected, disconnect first
	if end_turn_button.is_connected("pressed", end_turn_function):
		return

	end_turn_button.connect("pressed", end_turn_function)

func setPlayerName(player_name: String) -> void:
	player_name_text.text = "Player: " + player_name

func setTurnNumber(turn_number: int) -> void:
	turn_text.text = "Turn: " + str(turn_number)

func hideEndTurnButton() -> void:
	end_turn_button.visible = false

func showEndTurnButton() -> void:
	end_turn_button.visible = true

func _on_exit_game_button_pressed() -> void:
	if GlobalSettings.start_menu_path == "":
		push_error("Start menu scene location is not set in MainMenuScene.gd")
		return
	
	get_tree().change_scene_to_file(GlobalSettings.start_menu_path)