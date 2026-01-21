extends Control

@onready var name_text: Label = $VBoxContainer/NameText
@onready var move_points_text: Label = $VBoxContainer/MovePointsText
@onready var health_points_text: Label = $VBoxContainer/HealthPointsText
@onready var attack_power_text: Label = $VBoxContainer/AttackPowerText
@onready var defense_power_text: Label = $VBoxContainer/DefensePowerText

func updateUnitInfo(unit: Unit) -> void:
	# Set Name
	name_text.text = unit.name + " (Side " + str(unit.side) + ")"
	# Set Move Points
	move_points_text.text = "Action Points: " + str(unit.move_points) + " / " + str(unit.move_range)
	# Set Health Points
	health_points_text.text = "Health Points: " + str(unit.health_points)
	# Set Attack Power
	attack_power_text.text = "Attack Power: " + str(unit.current_attack_power)
	# Set Defense Power
	defense_power_text.text = "Defense Power: " + str(unit.current_defense_power)

func setVisibility(new_visiblility: bool) -> void:
	self.visible = new_visiblility
