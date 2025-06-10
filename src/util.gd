extends Object

class_name Util

func collect_pixels_from_neighbor_seam(neighbor_heightmap: Image, offset: Vector2i) -> Array[Dictionary]:
	var collected_heights: Array[Dictionary] = []

	if offset.x == 0:
		for x in range(neighbor_heightmap.get_width()):
			var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(x, 0 if offset.y > 0 else neighbor_heightmap.get_height() - 1))
			collected_heights.append({
				"position": Vector2i(x, 0 if offset.y < 0 else neighbor_heightmap.get_height() - 1),
				"height": pixel_color.r
			})
	elif offset.y == 0:
		for y in range(neighbor_heightmap.get_height()):
			var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(0 if offset.x > 0 else neighbor_heightmap.get_width() - 1, y))
			collected_heights.append({
				"position": Vector2i(0 if offset.x < 0 else neighbor_heightmap.get_width() - 1, y),
				"height": pixel_color.r
			})
	elif offset.x != 0 and offset.y != 0:
		var corner_coords = GeometryUtil.get_corner_coords_from_offset(offset, neighbor_heightmap.get_width() - 1, neighbor_heightmap.get_height() - 1)
		var pixel_color: Color = neighbor_heightmap.get_pixelv(corner_coords)
		collected_heights.append({
			"position": Vector2i(neighbor_heightmap.get_width() - 1 - corner_coords.x, neighbor_heightmap.get_height() - 1 - corner_coords.y),
			"height": pixel_color.r
		})
	else:
		print_debug("Unsupported offset for seam stitching: ", offset)
	
	return collected_heights
