extends Control

var just_closed: bool = false

func openInstructions() -> void:
	self.visible = true
	just_closed = false

func closeInstructions() -> void:
	self.visible = false
	just_closed = true


func getJustClosed() -> bool:
	var output = just_closed
	just_closed = false
	return output

func _on_close_button_pressed() -> void:
	closeInstructions()
