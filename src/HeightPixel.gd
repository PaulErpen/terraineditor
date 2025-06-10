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
			var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x, 0 if offset.y > 0 else neighbor_heightmap.get_height() - 1))
			collected_heights.append(
				HeightPixel.create(
					Vector2i(x, 0 if offset.y < 0 else neighbor_heightmap.get_height() - 1),
					pixel_color.r))
	elif offset.y == 0:
		for y in range(neighbor_heightmap.get_height()):
			var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(0 if offset.x > 0 else neighbor_heightmap.get_width() - 1, y))
			collected_heights.append(HeightPixel.create(
				Vector2i(0 if offset.x < 0 else neighbor_heightmap.get_width() - 1, y),
				pixel_color.r))
	elif offset.x != 0 and offset.y != 0:
		var corner_coords = GeometryUtil.get_corner_coords_from_offset(offset, neighbor_heightmap.get_width() - 1, neighbor_heightmap.get_height() - 1)
		var pixel_color: Color = neighbor_heightmap.get_pixelv(corner_coords)
		collected_heights.append(
			HeightPixel.create(
				Vector2i(neighbor_heightmap.get_width() - 1 - corner_coords.x, neighbor_heightmap.get_height() - 1 - corner_coords.y),
				pixel_color.r))
	else:
		print_debug("Unsupported offset for seam stitching: ", offset)
	
	return collected_heights