extends Node2D

@onready var map: Map = $Map

# Side information
@export var side1_color: Color = Color(1, 0, 0) # Red
@export var side2_color: Color = Color(0, 0, 1) # Blue

# Current side turn
var current_side: int = 0

# Unit scene to instantiate
@export var unit_scene: PackedScene = null


# List of all units on the map
var units: Array = []


# UI References
@onready var ui_unit_info: Control = $CanvasLayer/UiUnitInfo

# Input handling

# Currently selected unit
var selected_unit: Unit = null


func _ready():
	# Set up the map
	map.setMapSize(Vector2(7, 7))
	map.placeTiles()

	# Set up units on the map
	setUpUnits()

func _input(event: InputEvent) -> void:
	# Handle mouse clicks for unit selection
	if event is InputEventMouseButton:
		# Left mouse button click
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var local_pos = map.to_local(mouse_pos)

			# Handle Unit selection/deselection
			var unit = getUnitAtPixel(local_pos)
			var tile = map.getTileAtPixel(local_pos)

			if unit != null:
				# Select the unit and update UI
				selected_unit = unit
				ui_unit_info.updateUnitInfo(selected_unit)
				ui_unit_info.setVisibility(true)

				# Highlight tiles in unit's move range
				map.resetAllTileHighlights()
				unit.highlightMoveableTiles(map, units)
			else:
				# Deselect any selected unit and hide UI
				if selected_unit != null:
					# If a unit is selected, try to move it to the clicked tile		
					selected_unit.moveToTile(map, tile)

					# After moving, deselect the unit and hide UI
					selected_unit = null
					ui_unit_info.setVisibility(false)
					map.resetAllTileHighlights()
					

		# Right mouse button click
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			pass



func setUpUnits():
	# Side 1 units

	# Lay them across the top row
	var unit_locations = []
	for x in range(4):
		var new_location = Vector2(randi_range(0, 6), 0)

		while new_location in unit_locations:
			new_location = Vector2(randi_range(0, 6), 0)

		var unit = spawnUnitAtGrid(1, new_location)
		unit_locations.append(new_location)
		units.append(unit)

	# Side 2 Units
	
	# Lay them across the bottom row
	unit_locations.clear()
	for x in range(4):
		var new_location = Vector2(randi_range(0, 6), 6)

		while new_location in unit_locations:
			new_location = Vector2(randi_range(0, 6), 6)
		
		var unit = spawnUnitAtGrid(2, new_location)
		unit_locations.append(new_location)
		units.append(unit)

	# Name the units
	for i in range(units.size()):
		units[i].name = "Unit " + str(i + 1)

# Spawn a unit at a specific grid position for a given side
func spawnUnitAtGrid(side: int, grid_pos: Vector2):
	# Instantiate the unit
	var unit_instance = unit_scene.instantiate() as Unit

	# Configure the unit
	unit_instance.side = side
	if side == 1:
		unit_instance.setColor(side1_color)
	else:
		unit_instance.setColor(side2_color)

	# Place the unit on the map
	var tile = map.getTileAtGrid(grid_pos)
	if tile == null:
		print("Invalid grid position for spawning unit: ", grid_pos)
		return

	unit_instance.position = tile.getCenterOfTile()

	# Add the unit to the scene
	add_child(unit_instance)

	return unit_instance

# Get the unit at a specific pixel position
func getUnitAtPixel(pixel_pos: Vector2) -> Unit:
	# Get the tile at the pixel position
	var tile = map.getTileAtPixel(pixel_pos)
	if tile == null:
		return null

	# Check for a unit on that tile
	for unit in units:
		if unit.position.distance_to(tile.getCenterOfTile()) < 1.0:
			return unit

	return null
