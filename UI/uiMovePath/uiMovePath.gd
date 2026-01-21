extends Control

@onready var line = $Line2D

func _ready():
	pass # Replace with function body.

func clearPath():
	# Clear existing points
	line.clear_points()

func setPath(tile_path: Array):
	# Clear existing points
	clearPath()
	
	# Create new points
	for tile in tile_path:
		var tile_center = tile.getCenterOfTile()
		line.add_point(tile_center)