extends Node3D

class_name CellManager

@export var brush_radius: float = 3.0

var handle_scene = preload("res://scenes/create_new_handle/create_new_handle.tscn")
var cell_scene = preload("res://scenes/cell/cell.tscn")

var cells = {}
@onready var brush_cursor = $BrushCursor
var cell_size: Vector2i
var displacement_image_bounds: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var center_cell = cell_scene.instantiate()
	cells[0] = {
		0: center_cell
	}
	add_child(center_cell)
	cell_size = center_cell.mesh.size
	spawn_handles()
	var displacement_image = get_displacement_image(center_cell)
	displacement_image_bounds = Vector2i(
		displacement_image.get_width(),
		displacement_image.get_height()
	)

func cell_exists(x: int, y: int) -> bool:
	if cells.has(x) and cells[x] != null:
		if cells[x].has(y) and cells[x][y] != null:
			return true
	return false

func spawn_handles_for_cell(current_cell: Node3D, x: int, y: int):
	for neighbor in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if not cell_exists(x + neighbor.x, y + neighbor.y):
			var handle_instance: Node3D = handle_scene.instantiate()
			handle_instance.transform.origin = Vector3(neighbor.x * cell_size.x / 2.0, 0, neighbor.y * cell_size.y / 2.0)
			handle_instance.transform = handle_instance.transform.looking_at(-Vector3(neighbor.x, 0, neighbor.y))
			current_cell.add_child(handle_instance)
			handle_instance.cell_position = Vector2i(x + neighbor.x, y + neighbor.y)

func clean_handles(x: int, y: int):
	for neighbor in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if cell_exists(x + neighbor.x, y + neighbor.y):
			var neighbor_cell: Node3D = cells[x + neighbor.x][y + neighbor.y]
			for child in neighbor_cell.get_children():
				if child.is_in_group("create_new_handle"):
					if child.cell_position.x == x and child.cell_position.y == y:
						child.queue_free()

func spawn_handles():
	for x in cells.keys():
		for y in cells[x].keys():
			var current_cell: Node3D = cells[x][y]
			spawn_handles_for_cell(current_cell, x, y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for x in cells.keys():
		for y in cells[x].keys():
			var current_cell: Cell = cells[x][y]
			
			current_cell.set_brush_radius(brush_radius)
			var brush_pos: Vector2 = Vector2(compute_brush_position_int(Vector2i(x, y))) / Vector2(displacement_image_bounds.x - 1, displacement_image_bounds.y - 1)
			current_cell.set_brush_position(brush_pos)

func _on_create_new_cell(cell_position: Vector2i) -> void:
	if cell_position.x not in cells:
		cells[cell_position.x] = {}
	if cell_position.y in cells[cell_position.x]:
		print_debug("Cell already exists at position: ", cell_position)
	var new_cell: Node3D = cell_scene.instantiate()
	new_cell.transform.origin = Vector3(cell_position.x * cell_size.x, 0.0, cell_position.y * cell_size.y)
	cells[cell_position.x][cell_position.y] = new_cell
	add_child(new_cell)
	spawn_handles_for_cell(new_cell, cell_position.x, cell_position.y)
	clean_handles(cell_position.x, cell_position.y)
	stitch_seams(cell_position)

func stitch_seams(cell_position: Vector2i) -> void:
	var collected_heights = []
	
	for neighbor in get_possible_neighbors(cell_position):
		if cell_exists(neighbor.x, neighbor.y):
			var current_neighbor: MeshInstance3D = cells[neighbor.x][neighbor.y]
			var current_heightmap_texture: Image = get_displacement_image(current_neighbor)

			var offset: Vector2i = Vector2i(
				neighbor.x - cell_position.x,
				neighbor.y - cell_position.y
			)
			var neighbor_heights = HeightPixel.collect_pixels_from_neighbor_seam(current_heightmap_texture, offset)
			for height_data in neighbor_heights:
				if height_data.height != 0:
					collected_heights.append(height_data)
	
	if collected_heights.size() > 0:
		var current_cell: Cell = cells[cell_position.x][cell_position.y]
		var displacement_image: Image = get_displacement_image(current_cell)
		
		for height_data in collected_heights:
			displacement_image.set_pixelv(height_data.position, Color(height_data.height, height_data.height, height_data.height))
		
		var new_texture: ImageTexture = ImageTexture.create_from_image(displacement_image)
		current_cell.set_displacement_texture(new_texture)
		current_cell.is_changed = true

func _on_move_brush_curser(brush_cursor_position: Vector3) -> void:
	brush_cursor.position = brush_cursor_position

func get_cell_index_from_position(_position: Vector3) -> Vector2i:
	var x_index = int((abs(_position.x) + cell_size.x * 0.5) / cell_size.x * sign(_position.x))
	var y_index = int((abs(_position.z) + cell_size.y * 0.5) / cell_size.y * sign(_position.z))
	return Vector2i(x_index, y_index)

func get_rect_by_radius(brush_position: Vector2i) -> InclusiveRect:
	var cell_rect = InclusiveRect.create(
		Vector2(0, 0),
		Vector2(displacement_image_bounds.x - 1, displacement_image_bounds.y - 1)
	)
	var brush_rect = InclusiveRect.create(
		Vector2(brush_position.x - brush_radius, brush_position.y - brush_radius),
		Vector2(brush_radius * 2, brush_radius * 2)
	)
	return cell_rect.intersection(brush_rect)

func paint_on_texture(cell_index: Vector2i, brush_position: Vector2i, height: float) -> void:
	var current_cell: Cell = cells[cell_index.x][cell_index.y]
	current_cell.is_changed = true
	var displacement_image: Image = get_displacement_image(current_cell)

	var rect: InclusiveRect = get_rect_by_radius(brush_position)

	for x in range(floor(rect.position.x), ceil(rect.position.x + rect.size.x) + 1):
		for y in range(floor(rect.position.y), ceil(rect.position.y + rect.size.y) + 1):
			if x < 0 or x >= displacement_image_bounds.x or y < 0 or y >= displacement_image_bounds.y:
				continue
			var current_height: float = displacement_image.get_pixelv(Vector2i(x, y)).r
			var influence: float = max(0.01, 1.0 - (Vector2(x, y).distance_to(brush_position) / brush_radius))
			var new_height: float = current_height + height * influence
			displacement_image.set_pixelv(Vector2i(x, y), Color(new_height, new_height, new_height))

	var new_texture: ImageTexture = ImageTexture.create_from_image(displacement_image)
	current_cell.set_displacement_texture(new_texture)

func get_displacement_image(cell: Cell) -> Image:
	var displacement_texure: Texture = cell.get_displacement_texture()
	var displacement_image: Image = displacement_texure.get_image()
	return displacement_image

func get_closest_point_by_offset(brush_position: Vector2i, offset: Vector2i) -> Vector2:
	if offset.x == 0:
		return Vector2(brush_position.x, 0 if offset.y < 0 else displacement_image_bounds.y - 1)
	elif offset.y == 0:
		return Vector2(0 if offset.x < 0 else displacement_image_bounds.x - 1, brush_position.y)
	elif offset.x != 0 and offset.y != 0:
		var corner_coords = GeometryUtil.get_corner_coords_from_offset(offset, displacement_image_bounds.x - 1, displacement_image_bounds.y - 1)
		return Vector2(displacement_image_bounds.x - 1 - corner_coords.x, displacement_image_bounds.y - 1 - corner_coords.y)
	else:
		print_debug("Unsupported offset for closest point calculation: ", offset)
		return Vector2(0, 0)

func brush_position_intersects_with_neighbor(current_cell_index: Vector2i, brush_position: Vector2i, neighbor: Vector2i) -> bool:
	var offset: Vector2i = Vector2i(
		neighbor.x - current_cell_index.x,
		neighbor.y - current_cell_index.y
	)
	var closest_point: Vector2 = get_closest_point_by_offset(brush_position, offset)

	var distance: float = closest_point.distance_to(brush_position)

	if distance <= brush_radius:
		return true

	return false

	
func get_possible_neighbors(cell_index: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(cell_index.x + 1, cell_index.y),
		Vector2i(cell_index.x - 1, cell_index.y),
		Vector2i(cell_index.x, cell_index.y + 1),
		Vector2i(cell_index.x, cell_index.y - 1),
		Vector2i(cell_index.x + 1, cell_index.y + 1),
		Vector2i(cell_index.x - 1, cell_index.y - 1),
		Vector2i(cell_index.x + 1, cell_index.y - 1),
		Vector2i(cell_index.x - 1, cell_index.y + 1)
	]

func compute_brush_position_int(cell_index: Vector2i) -> Vector2i:
	return Vector2i(
		round((brush_cursor.position.x + cell_size.x * 0.5) / cell_size.x * (displacement_image_bounds.x - 1)) - cell_index.x * (displacement_image_bounds.x - 1),
		round((brush_cursor.position.z + cell_size.y * 0.5) / cell_size.y * (displacement_image_bounds.y - 1)) - cell_index.y * (displacement_image_bounds.y - 1)
	)

func move_brush_cursor(brush_cursor_pos: Vector3) -> void:
	brush_cursor.position = brush_cursor_pos

func change_brush_radius(radius_change) -> void:
	brush_radius = clamp(brush_radius + radius_change, 0.1, displacement_image_bounds.x - 1)

func change_height(height_change: float) -> void:
	var cell_index: Vector2i = get_cell_index_from_position(brush_cursor.position)

	var brush_position: Vector2i = compute_brush_position_int(cell_index)
	
	print(brush_position)
	
	var height: float = abs(height_change) / 50.0 * -1 * sign(height_change)

	paint_on_texture(cell_index, brush_position, height)

	var neighbors = get_possible_neighbors(cell_index)

	for neighbor in neighbors:
		if cell_exists(neighbor.x, neighbor.y):
			if brush_position_intersects_with_neighbor(cell_index, brush_position, neighbor):
				paint_on_texture(
					neighbor,
					Vector2i(
						brush_position.x - (neighbor.x - cell_index.x) * (displacement_image_bounds.x - 1),
						brush_position.y - (neighbor.y - cell_index.y) * (displacement_image_bounds.y - 1)
					),
					height
				)

	stitch_seams(cell_index)

	for neighbor in neighbors:
		if cell_exists(neighbor.x, neighbor.y):
			stitch_seams(neighbor)

func save_to_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	for x in cells.keys():
		for y in cells[x].keys():
			var current_cell: Cell = cells[x][y]
			var displacement_texture: ImageTexture = current_cell.get_displacement_texture()

			file.store_32(x)
			file.store_32(y)
			var image = displacement_texture.get_image()
			image.convert(Image.FORMAT_RF)
			var data: PackedByteArray = image.get_data()
			file.store_buffer(data)
			
			assert(data.size() == (current_cell.get_texture_bounds().x * current_cell.get_texture_bounds().y * 4))
			
	
	file.close()

func load_from_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	for x in cells.keys():
		for y in cells[x].keys():
			var current_cell: Cell = cells[x][y]
			current_cell.queue_free()
	cells = {}

	while file.get_position() < file.get_length():
		var x: int = file.get_32()
		var y: int = file.get_32()

		if not cell_exists(x, y):
			_on_create_new_cell(Vector2i(x, y))
		
		var current_cell: Cell = cells[x][y]
		
		var texture_bounds = current_cell.get_texture_bounds()
		var data: PackedByteArray = file.get_buffer(texture_bounds.x * texture_bounds.y * 4) # 4 bytes per pixel (RF format)
		
		
		var displacement_image: Image = Image.create_from_data(
			texture_bounds.x,
			texture_bounds.y,
			false,
			Image.FORMAT_RF,
			data
		)
		
		var new_texture: ImageTexture = ImageTexture.create_from_image(displacement_image)
		current_cell.set_displacement_texture(new_texture)
