extends Control

@onready var name_text: Label = $VBoxContainer/NameText
@onready var move_points_text: Label = $VBoxContainer/MovePointsText

func updateUnitInfo(unit: Unit) -> void:
	# Set Name
	name_text.text = unit.name + " (Side " + str(unit.side) + ")"
	# Set Move Points
	move_points_text.text = "Move Points: " + str(unit.move_points) + " / " + str(unit.move_range)


func setVisibility(new_visiblility: bool) -> void:
	self.visible = new_visiblility