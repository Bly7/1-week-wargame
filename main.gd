extends Node2D

@onready var map: Map = $Map

# Side information
@export var side1_color: Color = Color(1, 0, 0) # Red
@export var side2_color: Color = Color(0, 0, 1) # Blue

# AI Information
@export var side1_ai: bool = true
@export var side2_ai: bool = false

@onready var ai: AI = $AI

# Current side turn
var current_side: int = 1

# Unit scene to instantiate
@export var unit_scene: PackedScene = null


# List of all units on the map
var units: Array = []

@export var units_per_side: int = 4

# Current turn number
var turn_number: int = 1


# Behind the Scenes variables
var update_timer: float = 0.0
var update_interval: float = 0.1
var game_over: bool = false
var winning_side: int = 0

# UI References
@onready var ui_unit_info: Control = $CanvasLayer/UiUnitInfo
@onready var ui_end_turn: Control = $CanvasLayer/UiEndTurn
@onready var ui_game_over: Control = $CanvasLayer/UiGameOver

# Input handling

# Currently selected unit
var selected_unit: Unit = null


func _ready():
	# Set up the map
	map.setMapSize(Vector2(9, 9))
	map.placeTiles()

	# Start the game
	startGame()


func _input(event: InputEvent) -> void:

	# Ignore the following input if the game is over
	if game_over:
		return

	# Handle player input
	if (current_side == 1 and not side1_ai) or (current_side == 2 and not side2_ai):
		handlePlayerInput(event)

func _process(delta: float) -> void:

	# Ignore following updates if the game is over
	if game_over:
		return

	# Handle AI turn
	if (current_side == 1 and side1_ai) or (current_side == 2 and side2_ai):
		# Make AI moves
		ai.makeMoves(units, map, current_side)

		# End the turn after AI moves
		endTurn()

	# Update timer for periodic updates
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = update_interval
		updateState(delta)

# Update game state periodically
func updateState(delta: float) -> void:
	# Update units array to only include valid units
	for unit in units:
		if not is_instance_valid(unit):
			units.erase(unit)

	# Check for end of turn conditions
	var side_1_units = false
	var side_2_units = false
	for unit in units:
		if not is_instance_valid(unit):
			continue

		if unit.side == 1:
			side_1_units = true
		elif unit.side == 2:
			side_2_units = true

	if not side_1_units:
		winning_side = 2
		game_over = true
	elif not side_2_units:
		winning_side = 1
		game_over = true

	if game_over:
		# Show game over UI
		ui_game_over.setWinnerText("Side " + str(winning_side) + " Wins!")
		ui_game_over.setVisibility(true)
		ui_game_over.bindRestartButton(startGame)

# Handle player input
func handlePlayerInput(event: InputEvent) -> void:
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
				var can_attack = selected_unit != null and selected_unit.canAttackUnit(unit, map)  
				# If clicking on an enemy unit while having a selected unit, attack
				if can_attack:
					# Attack the unit
					selected_unit.attackUnit(unit)
				
					# Deselect previous unit
					ui_unit_info.setVisibility(false)
					map.resetAllTileHighlights()
					return

				# Select the unit and update UI
				selected_unit = unit
				ui_unit_info.updateUnitInfo(selected_unit)
				ui_unit_info.setVisibility(true)
				
				# Reset all tile highlights
				map.resetAllTileHighlights()

				# Highlight tiles in unit's move range
				if unit.side == current_side:
					unit.highlightMoveableTiles(map, units)
					var attackable_units = getAttackableNeighborUnits(unit)
					unit.highlightAttackableUnits(map, attackable_units)

				# Highlight the selected unit's tile
				map.highlightTile(tile, Color(1, 1, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight in yellow
				
			else:
				# Deselect any selected unit and hide UI
				if selected_unit != null:
					if selected_unit.canAct() and selected_unit.side == current_side and tile != null:
						# If a unit is selected, try to move it to the clicked tile		
						selected_unit.moveToTile(map, tile, units)

					# After moving, deselect the unit and hide UI
					selected_unit = null
					ui_unit_info.setVisibility(false)
					map.resetAllTileHighlights()
					

		# Right mouse button click
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			pass



func startGame() -> void:
	# Reset game state variables
	current_side = 1
	turn_number = 1
	game_over = false
	winning_side = 0

	# Set up units on the map
	setUpUnits()

	# Set up UI
	ui_unit_info.setVisibility(false)

	ui_end_turn.bindSignals(endTurn)
	ui_end_turn.setPlayerName("Side " + str(current_side))
	ui_end_turn.setTurnNumber(turn_number)

	ui_game_over.setVisibility(false)


func endTurn() -> void:
	# Advance to the next side's turn
	current_side += 1
	if current_side > 2:
		current_side = 1
		turn_number += 1

	# Reset move points for all units of the current side
	for unit in units:
		if not is_instance_valid(unit):
			continue
		
		if unit.side == current_side:
			unit.resetMovePoints()

	# Deselect any selected unit and hide UI
	selected_unit = null
	ui_unit_info.setVisibility(false)
	map.resetAllTileHighlights()

	# Update end turn UI
	ui_end_turn.setPlayerName("Side " + str(current_side))
	ui_end_turn.setTurnNumber(turn_number)

func setUpUnits():
	# clear existing units
	for unit in units:
		if is_instance_valid(unit):
			unit.queue_free()
	units.clear()

	# Side 1 units

	# Lay them across the top row
	var unit_locations = []
	for x in range(units_per_side):
		var new_location = Vector2(randi_range(0, map.getWidth() - 1), 0)

		while new_location in unit_locations:
			new_location = Vector2(randi_range(0, map.getWidth() - 1), 0)

		var unit = spawnUnitAtGrid(1, new_location)
		unit_locations.append(new_location)
		units.append(unit)

	# Side 2 Units
	
	# Lay them across the bottom row
	unit_locations.clear()
	for x in range(units_per_side):
		var new_location = Vector2(randi_range(0, map.getWidth() - 1), map.getHeight() - 1)

		while new_location in unit_locations:
			new_location = Vector2(randi_range(0, map.getWidth() - 1), map.getHeight() - 1)
		
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

# Get the unit at a specific tile
func getUnitAtTile(tile: Tile) -> Unit:
	for unit in units:
		var unit_tile = map.getTileAtPixel(unit.position)
		if unit_tile == tile:
			return unit

	return null

# Get all units located within a list of tiles
func getAllUnitsInTileList(tiles: Array) -> Array:
	var found_units = []

	for tile in tiles:
		var unit = getUnitAtTile(tile)
		if unit != null:
			found_units.append(unit)

	return found_units

# Get all attackable neighbor units for a given unit
func getAttackableNeighborUnits(unit: Unit) -> Array:
	# List to hold attackable units
	var attackable_units = []

	# Get neighboring tiles and units from those tiles
	var neighbor_tiles = map.getNeighborTiles(map.getTileAtPixel(unit.position))
	var neighbor_units = getAllUnitsInTileList(neighbor_tiles)
	
	# Filter for enemy units
	for neighbor_unit in neighbor_units:
		if neighbor_unit.side != unit.side:
			attackable_units.append(neighbor_unit)

	return attackable_units
