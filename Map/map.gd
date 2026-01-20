extends Node2D

class_name Map

var tile_map = []
var map_size = Vector2(7, 7)

var tile_size = 64

@export var tile_scene: PackedScene = null;

func _ready():
	pass # Replace with function body.

# Get map dimensions
func getWidth() -> int:
	return int(map_size.x)
func getHeight() -> int:
	return int(map_size.y)

# Set the size of the map and place tiles accordingly
func setMapSize(size: Vector2):
	map_size = size

# Place hex tiles in a grid
func placeTiles():
	# Clear existing tiles
	for child in get_children():
		child.queue_free()

	# Create new tiles
	for x in range(map_size.x):
		tile_map.append([])
		for y in range(map_size.y):
			var tile_instance = tile_scene.instantiate()
			var tile_location = Vector2(x, y)

			tile_instance.position = gridToPixel(tile_location)
			tile_instance.setLocation(tile_location)
			
			add_child(tile_instance)
			tile_map[x].append(tile_instance)

# Highlight a specific tile with a given color
func highlightTile(tile: Tile, highlight_color: Color):
	var sprite = tile.get_node("Sprite2D") as Sprite2D
	sprite.modulate = highlight_color

# Highlight multiple tiles in a list with a given color
func highlightTilesInList(tiles: Array, highlight_color: Color):
	for tile in tiles:
		highlightTile(tile, highlight_color)

# Highlight a tile at a specific grid position
func highlightTileAtGrid(grid_pos: Vector2, highlight_color: Color):
	var tile = getTileAtGrid(grid_pos)
	if tile != null:
		highlightTile(tile, highlight_color)

# Reset a tile to normal color
func resetTileHighlight(tile: Tile):
	highlightTile(tile, Color(1, 1, 1))

# Reset a tile at a specific grid position to normal color
func resetTileHighlightAtGrid(grid_pos: Vector2):
	var tile = getTileAtGrid(grid_pos)
	if tile != null:
		resetTileHighlight(tile)

# Reset all tiles to normal color
func resetAllTileHighlights():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile = tile_map[x][y]
			resetTileHighlight(tile)

# Get neighboring tiles for a given grid position
func getNeighborTiles(center_tile: Tile) -> Array:
	var neighbors = getTilesInRange(center_tile, 1)

	# Remove the center tile from the list
	for tile in neighbors:
		if tile == center_tile:
			neighbors.erase(tile)

	return neighbors


# Check if two tiles are neighbors
func areTilesNeighbors(tile1: Tile, tile2: Tile) -> bool:
	var neighbors = getNeighborTiles(tile1)
	return tile2 in neighbors

# Get the tile at a specific grid position
func getTileAtGrid(grid_pos: Vector2):
	if grid_pos.x < 0 or grid_pos.x >= map_size.x:
		return null
	if grid_pos.y < 0 or grid_pos.y >= map_size.y:
		return null
	return tile_map[grid_pos.x][grid_pos.y]

# Get the tile at a specific pixel position
func getTileAtPixel(pixel_pos: Vector2):
	var grid_pos = pixelToGrid(pixel_pos)
	return getTileAtGrid(grid_pos)

# Calculate distance between two tiles in grid coordinates (hexagonal distance)
func distanceBetweenTiles(grid_pos1: Vector2, grid_pos2: Vector2) -> int:
	# Convert offset coordinates to cube coordinates (odd-q system)
	var q1 = int(grid_pos1.x)
	var r1 = int(grid_pos1.y) - (int(grid_pos1.x) - (int(grid_pos1.x) & 1)) / 2
	var s1 = -q1 - r1
	
	var q2 = int(grid_pos2.x)
	var r2 = int(grid_pos2.y) - (int(grid_pos2.x) - (int(grid_pos2.x) & 1)) / 2
	var s2 = -q2 - r2
	
	# Calculate hexagonal distance
	var distance = (abs(q1 - q2) + abs(r1 - r2) + abs(s1 - s2)) / 2
	
	return distance

# Get all tiles within a certain range from a center tile
func getTilesInRange(center_tile: Tile, range: int) -> Array:
	var tiles_in_range = []

	var center_pos = center_tile.getLocation()

	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile = getTileAtGrid(Vector2(x, y))
			var distance = distanceBetweenTiles(center_pos, tile.getLocation())
			if distance <= range:
				tiles_in_range.append(tile)

	return tiles_in_range

# Convert grid coordinates to pixel coordinates for hex tiles
func gridToPixel(grid_pos: Vector2) -> Vector2:
	var pox_x = grid_pos.x * tile_size * 3/4
	var pox_y = grid_pos.y * tile_size * sqrt(3)/2

	if int(grid_pos.x) % 2 == 1:
		pox_y += tile_size * sqrt(3)/4

	return Vector2(pox_x, pox_y)

# Convert pixel coordinates to grid coordinates for hex tiles
func pixelToGrid(pixel_pos: Vector2) -> Vector2:
	# Approximate grid position
	var approx_x = pixel_pos.x / (tile_size * 3/4)
	var approx_y = pixel_pos.y / (tile_size * sqrt(3)/2)
	
	# Adjust for odd column offset
	if int(round(approx_x)) % 2 == 1:
		approx_y = (pixel_pos.y - tile_size * sqrt(3)/4) / (tile_size * sqrt(3)/2)
	
	# Get candidate grid positions
	var candidates = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			var test_x = floor(approx_x) + dx
			var test_y = floor(approx_y) + dy
			candidates.append(Vector2(test_x, test_y))
	
	# Find the closest candidate by comparing to tile centers
	var best_candidate = Vector2(round(approx_x), round(approx_y))
	var best_center = gridToPixel(best_candidate) + Vector2(tile_size / 2, tile_size / 2)
	var best_distance = pixel_pos.distance_to(best_center)
	
	for candidate in candidates:
		var candidate_pixel = gridToPixel(candidate)
		var candidate_center = candidate_pixel + Vector2(tile_size / 2, tile_size / 2)
		var distance = pixel_pos.distance_to(candidate_center)
		if distance < best_distance:
			best_distance = distance
			best_candidate = candidate
	
	return best_candidate
