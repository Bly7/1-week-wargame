extends Node2D

class_name Unit

@export var side: int = 0

# Movement range of the unit
@export var move_range: int = 2

# Health points of the unit
@export var health_points: int = 3

# Attack and defense power of the unit
@export var attack_power: float = 1
var current_attack_power: int = int(attack_power)
@export var defense_power: float = 1
var current_defense_power: int = int(defense_power)

# Current move points available, might change this to action points later
@onready var move_points: int = 0

# Current move path for visualization
var move_path: Array = []

# Graphical Objects
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_label: Label = $AttackLabel
@onready var defense_label: Label = $DefenseLabel
@onready var health_label: Label = $HealthLabel
@onready var unmoved_label: Label = $UnmovedLabel

# Audio Objects
@onready var move_sound: AudioStreamPlayer = $MoveSound
@onready var successful_attack_sound: AudioStreamPlayer = $SuccessfulAttackSound
@onready var failed_attack_sound: AudioStreamPlayer = $FailedAttackSound

func _ready():
	resetMovePoints()
	updateStats()
	updateGraphics()

func resetMovePoints():
	# Initialize move points
	move_points = move_range

	# Reset move path
	move_path.clear()

	# Update graphics
	updateGraphics()

func updateStats():
	current_attack_power = attack_power * health_points
	current_defense_power = defense_power * health_points

	updateGraphics()

func updateGraphics():
	# Update the Attack and Defense labels
	attack_label.text = str(current_attack_power)
	defense_label.text = str(current_defense_power)

	# Update the Health label with dots representing health points
	var health_dots = ""
	for dot in range(health_points):
		health_dots += "."
		
	health_label.text = health_dots

	# Update the Unmoved label visibility
	unmoved_label.visible = hasMoved() == false and canAct()

# Check if the unit can act (has move points and health)
func canAct() -> bool:
	return move_points > 0 and health_points > 0

# Check if the unit has moved this turn
func hasMoved() -> bool:
	return move_points < move_range
	#return move_path.size() > 0

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
		# Only add if a valid path exists and is within move range
		if path.size() > 0 and path.size() - 1 <= move_points:
			reachable_tiles.append(target_tile)

	return reachable_tiles

# Move the unit to a specific tile if within move points
func moveToTile(map: Map, tile: Tile, units: Array) -> bool:
	# test if the tile is the same tile the unit is currently on
	var current_tile = map.getTileAtPixel(position)
	if current_tile == tile:
		return false

	# Get all moveable tiles
	var moveable_tiles = getAllMoveableTiles(map, units)

	# Check if the target tile is in range
	if tile not in moveable_tiles:
		return false

	# Decrease move points
	var distance = map.distanceBetweenTiles(map.getTileAtPixel(position).getLocation(), tile.getLocation())
	move_points -= distance

	# Update the move path for visualization
	var path = map.getPathBetweenTiles(map.getTileAtPixel(position), tile, units)
	for path_tile in path:
		move_path.append(path_tile)
	
	# Move the unit to the tile's center position
	position = tile.getCenterOfTile()

	# Update graphics
	updateGraphics()

	# Play Sound Effect (if any)
	move_sound.play()
	
	return true

# Get the tile the unit is currently on
func getCurrentTile(map: Map) -> Tile:
	return map.getTileAtPixel(position)

# Set the unit's color
func setColor(color: Color):
	if sprite == null:
		sprite = $Sprite2D

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
	# if the unit cannot act, return
	if not canAct():
		return

	# Highlight units on those tiles
	for unit in units:
		# Skip invalid units
		if not is_instance_valid(unit):
			continue
		
		
		var unit_tile = map.getTileAtPixel(unit.position)
		if unit_tile != null:
			map.highlightTile(unit_tile, Color(1, 0, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight tile in red

# Set the move path for visualization
func getMovePath() -> Array:
	return move_path

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

func applyDamage(damage: int) -> bool:
	health_points -= damage
	if health_points < 0:
		health_points = 0

	# Update graphics and stats
	updateGraphics()
	updateStats()

	if health_points <= 0:
		# Target unit is defeated, remove it from the game
		queue_free()
		return true
	
	return false

func roll() -> int:
	return randi_range(1, 6)
	#return randi_range(1, 10)

# Attack another unit
# Might want to move this to the main script later
func attackUnit(target_unit: Unit, map: Map, is_counterattack: bool = false) -> bool:
	# if the unit hasn't moved this turn, give attack bonus
	var attack_bonus = 0
	'''
	if hasMoved() == false:
		attack_bonus = 1'''
	

	# if the target unit hasn't moved this turn, give defense bonus
	var defense_bonus = 0
	if target_unit.hasMoved() == false:
		defense_bonus = 1

	# empty move points
	move_points = 0

	# Roll to see if attack hits 
	var attack_roll = roll() + current_attack_power + attack_bonus
	var defense_roll = target_unit.roll() + target_unit.current_defense_power + defense_bonus

	if attack_roll < defense_roll:
		# Play Sound Effect (if any)
		failed_attack_sound.play()

		# counterattack logic
		if target_unit.hasMoved() == false and is_counterattack == false:
			# Target unit gets a counterattack if it hasn't moved
			var counterattack_result = target_unit.attackUnit(self, map, true)

			# I need a sound for counterattack

			return false
			
		
		# Attack missed
		return false

	# Update graphics
	updateGraphics()
	updateStats()

	# Simple attack logic: reduce target's health by attacker's attack power minus target's defense power
	var damage = 1
	var target_tile = target_unit.getCurrentTile(map)
	var destroyed = target_unit.applyDamage(damage)

	# If the target unit is destroyed, move into its tile, unless it's a counterattack
	if destroyed and not is_counterattack:
		# Update the move path for visualization
		move_path.append(getCurrentTile(map))
		move_path.append(target_tile)

		# Move the unit to the target tile's center position
		position = target_tile.getCenterOfTile()

	# Play Sound Effect (if any)
	successful_attack_sound.play()

	# Attack successful
	return true