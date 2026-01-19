extends Control

@onready var end_turn_button: Button = $VBoxContainer/HBoxContainer/Button
@onready var player_name_text: Label = $VBoxContainer/Label
@onready var turn_text: Label = $VBoxContainer/Label2

func _ready():
    pass # Replace with function body.

# Bind the end turn button to the provided function
func bindSignals(end_turn_function: Callable) -> void:
    end_turn_button.connect("pressed", end_turn_function)

func setPlayerName(name: String) -> void:
    player_name_text.text = "Player: " + name

func setTurnNumber(turn_number: int) -> void:
    turn_text.text = "Turn: " + str(turn_number)