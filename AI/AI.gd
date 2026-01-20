extends Node

class_name AI

var end_turn_callable: Callable

var time_per_move: float = 0.1  # Time delay between moves
var time_remaining: float = 0.0

var units_left_to_move: Array = []

func _ready() -> void:
	pass

func setEndTurnCallable(callable: Callable) -> void:
	end_turn_callable = callable

# Get all units belonging to a specific side
func getUnits(units: Array, side: int) -> Array:
	var side_units: Array = []
	
	for unit in units:
		if not is_instance_valid(unit):
			continue

		if unit.side == side:
			side_units.append(unit)

	return side_units

# Get all units not belonging to a specific side
func getUnitsOfOtherSide(units: Array, side: int) -> Array:
	var other_side_units: Array = []
	for unit in units:
		if not is_instance_valid(unit):
			continue

		if unit.side != side:
			other_side_units.append(unit)

	return other_side_units

# Make moves for all units of a specific side
func makeMoves(delta: float, units: Array, map: Node2D, side: int) -> void:
	if units_left_to_move.is_empty():
		# Initialize the list of units to move
		units_left_to_move = getUnits(units, side)

	if time_remaining > 0.0:
		time_remaining -= delta
		return

	# Reset time remaining for next move
	time_remaining = time_per_move
	
	# Get enemy units
	var enemy_units = getUnitsOfOtherSide(units, side)

	var current_unit = units_left_to_move.pop_front()
	if is_instance_valid(current_unit):
		moveUnit(current_unit, enemy_units, units, map, side)

	# Check if all units have moved
	if not units_left_to_move.is_empty():
		return
	
	# All units have moved, end the turn
	if end_turn_callable != null:
		end_turn_callable.call()
	else:
		print("AI: end_turn_callable is null!")

# Move/Attack with a single unit based on simple AI logic
func moveUnit(unit: Node2D, enemy_units: Array, units: Array, map: Node2D, side: int) -> void:
	# Simple AI: Move each unit randomly to an adjacent tile if possible
		var current_tile = map.getTileAtPixel(unit.position)
		if current_tile == null:
			return

		# get closest enemy unit
		var closest_enemy = null
		var closest_distance = INF
		for enemy in enemy_units:
			var distance = unit.position.distance_to(enemy.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

		# plan path to closest enemy
		var path = []
		if closest_enemy != null:
			var enemy_tile = map.getTileAtPixel(closest_enemy.position)
			path = map.getPathBetweenTiles(current_tile, enemy_tile, units)

		# Move along the path if possible
		for next_tile in path:
			var moved = unit.moveToTile(map, next_tile, units)
			if not moved:
				break  # Stop if we can't move further

		# Attack unit from adjacent tile if possible
		if closest_enemy != null:
			# attack if in range
			if unit.canAttackUnit(closest_enemy, map):
				unit.attackUnit(closest_enemy)
