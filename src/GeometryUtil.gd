extends Object 

class_name GeometryUtil

static func get_corner_coords_from_offset(offset: Vector2i, width: int, height: int) -> Vector2i:
	if offset.x > 0 and offset.y > 0:
		return Vector2i(0, 0)
	elif offset.x < 0 and offset.y < 0:
		return Vector2i(width, height)
	elif offset.x > 0 and offset.y < 0:
		return Vector2i(0, height)
	elif offset.x < 0 and offset.y > 0:
		return Vector2i(width-1, 0)
	else:
		print_debug("Unsupported offset for corner coords: ", offset)
		return Vector2i(0, 0)