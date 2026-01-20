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

# Get a path between two tiles using A* pathfinding
# AI Generated function
func getPathBetweenTiles(start_tile: Tile, end_tile: Tile, units: Array) -> Array:
	if start_tile == null or end_tile == null:
		return []
	
	# If end tile is blocked, no path exists
	if end_tile.tile_blocked:
		return []
	
	# If start and end are the same, return path with just the start tile
	if start_tile == end_tile:
		return [start_tile]
	
	# Initialize data structures for A*
	var open_set = [start_tile]  # Tiles to be evaluated
	var closed_set = []  # Tiles already evaluated
	var came_from = {}  # Map to reconstruct path
	var g_score = {}  # Cost from start to each tile
	var f_score = {}  # Estimated total cost from start to end through each tile
	
	# Initialize scores
	g_score[start_tile] = 0
	f_score[start_tile] = distanceBetweenTiles(start_tile.getLocation(), end_tile.getLocation())
	
	while open_set.size() > 0:
		# Find tile in open_set with lowest f_score
		var current = open_set[0]
		var lowest_f = f_score.get(current, INF)
		for tile in open_set:
			var tile_f = f_score.get(tile, INF)
			if tile_f < lowest_f:
				current = tile
				lowest_f = tile_f
		
		# If we reached the goal, reconstruct and return the path
		if current == end_tile:
			return _reconstructPath(came_from, current)
		
		# Move current from open to closed set
		open_set.erase(current)
		closed_set.append(current)
		
		# Check all neighbors
		var neighbors = getNeighborTiles(current)
		for neighbor in neighbors:
			# Skip if already evaluated or blocked
			if neighbor in closed_set or neighbor.tile_blocked:
				continue
			
			# Check if tile is occupied by a unit (only allow if it's the end tile)
			var is_occupied = false
			for unit in units:
				if not is_instance_valid(unit):
					continue

				var unit_tile = getTileAtPixel(unit.position)
				if unit_tile == neighbor and neighbor != end_tile:
					is_occupied = true
					break
			
			if is_occupied:
				continue
			
			# Calculate tentative g_score (cost from start to neighbor through current)
			var tentative_g_score = g_score.get(current, INF) + 1
			
			# Add neighbor to open set if not already there
			if neighbor not in open_set:
				open_set.append(neighbor)
			elif tentative_g_score >= g_score.get(neighbor, INF):
				# This is not a better path
				continue
			
			# This is the best path so far, record it
			came_from[neighbor] = current
			g_score[neighbor] = tentative_g_score
			f_score[neighbor] = tentative_g_score + distanceBetweenTiles(neighbor.getLocation(), end_tile.getLocation())
	
	# No path found
	return []

# Helper function to reconstruct the path from A*
# AI Generated function
func _reconstructPath(came_from: Dictionary, current: Tile) -> Array:
	var path = [current]
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)
	return path
