extends Node

class_name AI

func _ready() -> void:
	pass

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
func makeMoves(units: Array, map: Node2D, side: int) -> void:
	# Get units for both sides
	var my_units = getUnits(units, side)
	var enemy_units = getUnitsOfOtherSide(units, side)

	for unit in my_units:
		# Simple AI: Move each unit randomly to an adjacent tile if possible
		var current_tile = map.getTileAtPixel(unit.position)
		if current_tile == null:
			continue

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
