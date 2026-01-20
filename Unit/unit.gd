extends Node2D

class_name Unit

@export var side: int = 0

# Movement range of the unit
@export var move_range: int = 2

# Health points of the unit
@export var health_points: int = 3

# Attack and defense power of the unit
@export var attack_power: int = 1
@export var defense_power: int = 1

# Current move points available, might change this to action points later
@onready var move_points: int = 0

func _ready():
	resetMovePoints()

func resetMovePoints():
	# Initialize move points
	move_points = move_range

func canAct() -> bool:
	return move_points > 0 and health_points > 0

# Get all tiles this unit can move to considering other units' positions
func getAllMoveableTiles(map: Map, units: Array) -> Array:
	# Get the tile the unit is currently on
	var tile = map.getTileAtPixel(position)
	if tile == null:
		return []

	# Get tiles in move range
	var tiles_in_range = map.getTilesInRange(tile, move_points)

	# Remove tiles occupied by other units (excluding self)
	for unit in units:
		if not is_instance_valid(unit):
			continue

		if unit == self:
			continue
		var unit_tile = map.getTileAtPixel(unit.position)
		if unit_tile != null and unit_tile in tiles_in_range:
			tiles_in_range.erase(unit_tile)

	# Find paths to each tile and ensure they are reachable within move points
	var reachable_tiles = []
	for target_tile in tiles_in_range:
		var path = map.getPathBetweenTiles(tile, target_tile, units)
		if path.size() - 1 <= move_points:
			reachable_tiles.append(target_tile)

	return reachable_tiles

# Move the unit to a specific tile if within move points
func moveToTile(map: Map, tile: Tile, units: Array) -> bool:
	# Get all moveable tiles
	var moveable_tiles = getAllMoveableTiles(map, units)

	# Check if the target tile is in range
	if tile not in moveable_tiles:
		return false

	# Decrease move points
	var distance = map.distanceBetweenTiles(map.getTileAtPixel(position).getLocation(), tile.getLocation())
	move_points -= distance
	
	# Move the unit to the tile's center position
	position = tile.getCenterOfTile()
	
	return true

# Set the unit's color
func setColor(color: Color):
	var sprite = $Sprite2D
	sprite.modulate = color

# Highlight tiles within the unit's move range
func highlightMoveRange(map: Map):
	var tile = map.getTileAtPixel(position)
	if tile == null:
		return

	var tiles_in_range = map.getTilesInRange(tile, move_range)
	map.highlightTilesInList(tiles_in_range, Color(0, 1, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight in green


# Highlight moveable tiles considering other units' positions
func highlightMoveableTiles(map: Map, units: Array):
	# Get the tile the unit is currently on
	var tile = map.getTileAtPixel(position)
	if tile == null:
		return

	# Get tiles in move range
	var moveable_tiles = getAllMoveableTiles(map, units)

	# Highlight the remaining tiles
	map.highlightTilesInList(moveable_tiles, Color(0, 1, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight in green

# Highlight attackable units within attack range
func highlightAttackableUnits(map: Map, units: Array):
	# Highlight units on those tiles
	for unit in units:
		var unit_tile = map.getTileAtPixel(unit.position)
		if unit_tile != null:
			map.highlightTile(unit_tile, Color(1, 0, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight tile in red

# Check if this unit can attack another unit
func canAttackUnit(target_unit: Unit, map: Map) -> bool:
	var can_attack = true

	# Check if the target unit is valid and this unit can act
	can_attack = can_attack and target_unit != null and self.canAct()

	# Check if target unit not self and is on opposing side
	can_attack = can_attack and self != target_unit and self.side != target_unit.side

	# Check if target unit is on a neighboring tile
	can_attack = can_attack and map.areTilesNeighbors(map.getTileAtPixel(self.position), map.getTileAtPixel(target_unit.position))

	return can_attack

# Attack another unit
# Might want to move this to the main script later
func attackUnit(target_unit: Unit):
	# empty move points
	move_points = 0

	# Roll to see if attack hits 
	var attack_roll = randi_range(1, 6) + attack_power
	var defense_roll = randi_range(1, 6) + target_unit.defense_power

	if attack_roll < defense_roll:
		# Attack missed
		return

	# Simple attack logic: reduce target's health by attacker's attack power minus target's defense power
	var damage = 1
	target_unit.health_points -= damage

	# If health gets to 1, pull back unit, don't implement right now

	# Ensure health doesn't go below zero
	if target_unit.health_points < 0:
		target_unit.health_points = 0

	if target_unit.health_points == 0:
		# Target unit is defeated, remove it from the game
		target_unit.queue_free()
