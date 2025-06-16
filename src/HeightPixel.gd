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
			for y in [0, 1, 2]:
				var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x, y if offset.y > 0 else neighbor_heightmap.get_height() - 3 + y))
				collected_heights.append(
					HeightPixel.create(
						Vector2i(x, y if offset.y < 0 else neighbor_heightmap.get_height() - 3 + y),
						pixel_color.r))
	elif offset.y == 0:
		for y in range(neighbor_heightmap.get_height()):
			for x in [0, 1, 2]:
				var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x if offset.x > 0 else neighbor_heightmap.get_width() - 3 + x, y))
				collected_heights.append(HeightPixel.create(
					Vector2i(x if offset.x < 0 else neighbor_heightmap.get_width() - 3 + x, y),
					pixel_color.r))
	elif offset.x != 0 and offset.y != 0:
		for x in [0, 1, 2]:
			for y in [0, 1, 2]:
				var corner_coords = GeometryUtil.get_corner_coords_from_offset(offset, neighbor_heightmap.get_width() - 1, neighbor_heightmap.get_height() - 1)

				corner_coords.x = (x if corner_coords.x == 0 else corner_coords.x - x)
				corner_coords.y = (y if corner_coords.y == 0 else corner_coords.y - y)

				var pixel_color: Color = neighbor_heightmap.get_pixelv(corner_coords)

				var opposing_coords = corner_coords - offset * Vector2i(neighbor_heightmap.get_width() - 3, neighbor_heightmap.get_height() - 3)

				collected_heights.append(
					HeightPixel.create(
						opposing_coords,
						pixel_color.r))
				
				print("Mapping ", corner_coords, " to ", opposing_coords)
	else:
		print_debug("Unsupported offset for seam stitching: ", offset)

	return collected_heights
