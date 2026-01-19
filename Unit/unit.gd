extends Node2D

class_name Unit

@export var side: int = 0

@export var move_range: int = 2
@onready var move_points: int = 0

func _ready():
	reset()

func reset():
	# Initialize move points
	move_points = move_range

# Move the unit to a specific tile if within move points
func moveToTile(map: Map, tile: Tile) -> bool:
	var tiles_in_range = map.getTileInRange(map.getTileAtPixel(position), move_points)

	if tile in tiles_in_range:
		# Decrease move points
		var distance = map.distanceBetweenTiles(map.getTileAtPixel(position).getLocation(), tile.getLocation())
		move_points -= distance
		
		# Move the unit to the tile's center position
		position = tile.getCenterOfTile()
		
		return true
	
	return false

# Set the unit's color
func setColor(color: Color):
	var sprite = $Sprite2D
	sprite.modulate = color

# Highlight tiles within the unit's move range
func highlightMoveRange(map: Map):
	var tile = map.getTileAtPixel(position)
	if tile == null:
		return

	var tiles_in_range = map.getTileInRange(tile, move_range)
	map.highlightTilesInList(tiles_in_range, Color(0, 1, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight in green

# Highlight moveable tiles considering other units' positions
func highlightMoveableTiles(map: Map, units: Array):
	# Get the tile the unit is currently on
	var tile = map.getTileAtPixel(position)
	if tile == null:
		return

	# Get tiles in move range
	var tiles_in_range = map.getTileInRange(tile, move_points)

	# Remove tiles occupied by other units
	for unit in units:
		var unit_tile = map.getTileAtPixel(unit.position)
		if unit_tile != null and unit_tile in tiles_in_range:
			tiles_in_range.erase(unit_tile)

	# Highlight the remaining tiles
	map.highlightTilesInList(tiles_in_range, Color(0, 1, 0).lerp(Color(1, 1, 1), 0.5)) # Highlight in green