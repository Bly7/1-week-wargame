extends Node2D

class_name Tile

var tile_location = Vector2.ZERO

var tile_size = 64

func _ready():
    pass # Replace with function body.

# Set the grid location of the tile
func setLocation(location: Vector2):
    tile_location = location

# Get the grid location of the tile
func getLocation() -> Vector2:
    return tile_location

# Get the center position of the tile in pixel coordinates
func getCenterOfTile() -> Vector2:
    return position + Vector2(tile_size / 2, tile_size / 2)