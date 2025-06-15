extends Object

class_name HeightPixel

var position: Vector2i
var height: float

static func create(_position: Vector2i, _height: float) -> HeightPixel:
	var instance = HeightPixel.new()
	instance.position = _position
	instance.height = _height
	return instance

static func collect_pixels_from_neighbor_seam(neighbor_heightmap: Image, offset: Vector2i) -> Array[HeightPixel]:
	var collected_heights: Array[HeightPixel] = []

	if offset.x == 0:
		for x in range(neighbor_heightmap.get_width()):
			for y in [0, 1]:
				var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x, y if offset.y > 0 else neighbor_heightmap.get_height() - 1 - y))
				collected_heights.append(
					HeightPixel.create(
						Vector2i(x, y if offset.y < 0 else neighbor_heightmap.get_height() - 1 - y),
						pixel_color.r))
	elif offset.y == 0:
		for y in range(neighbor_heightmap.get_height()):
			for x in [0, 1]:
				var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x if offset.x > 0 else neighbor_heightmap.get_width() - 1 - x, y))
				collected_heights.append(HeightPixel.create(
					Vector2i(x if offset.x < 0 else neighbor_heightmap.get_width() - 1 - x, y),
					pixel_color.r))
	elif offset.x != 0 and offset.y != 0:
		for x in [0, 1]:
			for y in [0, 1]:
				var corner_coords = GeometryUtil.get_corner_coords_from_offset(offset, neighbor_heightmap.get_width() - 1, neighbor_heightmap.get_height() - 1)

				corner_coords.x = corner_coords.x + (x if corner_coords.x == 0 else -x)
				corner_coords.y = corner_coords.y + (y if corner_coords.y == 0 else -y)

				var pixel_color: Color = neighbor_heightmap.get_pixelv(corner_coords)
				collected_heights.append(
					HeightPixel.create(
						Vector2i(neighbor_heightmap.get_width() - 1 - corner_coords.x, neighbor_heightmap.get_height() - 1 - corner_coords.y),
						pixel_color.r))
	else:
		print_debug("Unsupported offset for seam stitching: ", offset)
	
	return collected_heights
