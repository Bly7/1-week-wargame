extends Node2D

class_name Tile

var tile_location = Vector2.ZERO

var tile_size = 64

var tile_blocked: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	resetTileColor()

# Reset the tile color based on its blocked status
func resetTileColor():
	if tile_blocked:
		sprite.modulate = Color(0.5, 0.5, 0.5)
		return

	sprite.modulate = Color(1, 1, 1)

# Highlight the tile with a specific color
func highlightTile(highlight_color: Color):
	if tile_blocked:
		sprite.modulate = highlight_color.lerp(Color(0.5, 0.5, 0.5), 0.5)
		return

	sprite.modulate = highlight_color

func setBlocked(is_blocked: bool):
	tile_blocked = is_blocked
	resetTileColor()

func getBlocked() -> bool:
	return tile_blocked

# Set the grid location of the tile
func setLocation(location: Vector2):
	tile_location = location

# Get the grid location of the tile
func getLocation() -> Vector2:
	return tile_location

# Get the center position of the tile in pixel coordinates
func getCenterOfTile() -> Vector2:
	return position + Vector2(tile_size / 2, tile_size / 2)