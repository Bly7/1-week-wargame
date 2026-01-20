extends Control

@onready var winnerLabel: Label = $MarginContainer/VBoxContainer/WinnerLabel
@onready var restartButton: Button = $MarginContainer/VBoxContainer/MarginContainer/RestartButton

func _ready() -> void:
	pass

# Sets the winner text on the game over screen
func setWinnerText(text: String) -> void:
	winnerLabel.text = text

# Binds the restart button to a callback function
func bindRestartButton(callback: Callable) -> void:
	restartButton.pressed.connect(callback)

# Sets the visibility of the game over screen
func setVisibility(new_visibility: bool) -> void:
	self.visible = new_visibility