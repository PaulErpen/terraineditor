extends Node3D

var handle_scene = preload("res://create_new_handle/create_new_handle.tscn")
var cell_scene = preload("res://cell/cell.tscn")
var brush_image: Image = preload("res://brush/brush.png").get_image()
var brush_size: float = 0.06

@onready var cells = {0: {0: $Cell}}
@onready var bursh_cursor = $BrushCursor
@onready var cell_size: Vector2i = $Cell.mesh.size
var displacement_image_bounds: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	brush_image.convert(Image.FORMAT_RF)
	spawn_handles()
	var some_cell = cells[0][0]
	var displacement_image = get_displacement_image(some_cell)
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
func _process(delta: float) -> void:
	pass

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
	stich_seams(cell_position)

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
	elif abs(offset.x) == abs(offset.y):
		var pixel_color: Color = neighbor_heightmap.get_pixelv(Vector2i(
			0 if offset.x < 0 else neighbor_heightmap.get_width() - 1, 
			0 if offset.y < 0 else neighbor_heightmap.get_height() - 1))
		collected_heights.append({
			"position": Vector2i(0 if offset.x > 0 else neighbor_heightmap.get_width() - 1, 0 if offset.y > 0 else neighbor_heightmap.get_height() - 1),
			"height": pixel_color.r
		})
	else:
		print_debug("Unsupported offset for seam stitching: ", offset)
	
	return collected_heights


func stich_seams(cell_position: Vector2i) -> void:
	var collected_heights = []
	
	for neighbor in get_possible_neighbors(cell_position):
		if cell_exists(neighbor.x, neighbor.y):
			var current_neighbor: MeshInstance3D = cells[neighbor.x][neighbor.y]
			var current_heightmap_texture: Image = get_displacement_image(current_neighbor)

			var offset: Vector2i = Vector2i(
				neighbor.x - cell_position.x,
				neighbor.y - cell_position.y
			)
			var neighbor_heights = collect_pixels_from_neighbor_seam(current_heightmap_texture, offset)
			for height_data in neighbor_heights:
				if height_data.height != 0:
					collected_heights.append(height_data)
	
	if collected_heights.size() > 0:
		var current_cell: Node3D = cells[cell_position.x][cell_position.y]
		var displacement_image: Image = get_displacement_image(current_cell)
		
		for height_data in collected_heights:
			displacement_image.set_pixelv(height_data.position, Color(height_data.height, height_data.height, height_data.height))
		
		var new_texture = ImageTexture.create_from_image(displacement_image)
		current_cell.material_override.set("shader_parameter/displacement_texture", new_texture)
		current_cell.is_changed = true

func _on_move_brush_curser(brush_cursor_position: Vector3) -> void:
	bursh_cursor.position = brush_cursor_position

func get_cell_index_from_position(position: Vector3) -> Vector2i:
	var x_index = int((abs(position.x) + cell_size.x * 0.5) / cell_size.x * sign(position.x))
	var y_index = int((abs(position.z) + cell_size.y * 0.5) / cell_size.y * sign(position.z))
	return Vector2i(x_index, y_index)

func paint_on_texture(cell_index: Vector2i, current_brush: Image, brush_position: Vector2i, height: float) -> void:
	var current_cell: Node3D = cells[cell_index.x][cell_index.y]
	current_cell.is_changed = true
	var displacement_image: Image = get_displacement_image(current_cell)
	var current_height: float = displacement_image.get_pixelv(brush_position).r
	# print(brush_position)
	
	displacement_image.set_pixelv(
		brush_position,
		Color(current_height + height, current_height + height, current_height + height)
	)
	# displacement_image.blend_rect(
	# 	current_brush,
	# 	Rect2i(
	# 		0, 0, current_brush.get_width(), current_brush.get_height()
	# 	),
	# 	brush_position
	# )
	var new_texture = ImageTexture.create_from_image(displacement_image)
	current_cell.material_override.set("shader_parameter/displacement_texture", new_texture)

func prepare_brush() -> Image:
	var current_brush: Image = brush_image.duplicate()
	current_brush.resize(
		int(brush_image.get_width() * brush_size),
		int(brush_image.get_height() * brush_size)
	)
	# print(height_change / 100.0)
	# brush_image.adjust_bcs(height_change, 1.0, 1.0)
	return current_brush

func get_displacement_image(cell: Node3D) -> Image:
	var displacement_texure: Texture2D = cell.material_override.get("shader_parameter/displacement_texture")
	var displacement_image: Image = displacement_texure.get_image()
	return displacement_image

func brush_position_intersects_with_neighbor(current_cell_index: Vector2i, brush_position: Vector2i, neighbor: Vector2i) -> bool:
	var offset: Vector2i = Vector2i(
		neighbor.x - current_cell_index.x,
		neighbor.y - current_cell_index.y
	)
	
	var x_position = brush_position.x - offset.x * (displacement_image_bounds.x - 1)
	if offset.x != 0 and (x_position == 0 or x_position == displacement_image_bounds.x - 1):
		return true
		
	var y_position = brush_position.y - offset.y * (displacement_image_bounds.y - 1)
	if offset.y != 0 and (y_position == 0 or y_position == displacement_image_bounds.y - 1):
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

func _on_change_height(height_change: float) -> void:
	var current_brush: Image = prepare_brush()

	var cell_index: Vector2i = get_cell_index_from_position(bursh_cursor.position)

	var brush_position: Vector2i = Vector2i(
		round((bursh_cursor.position.x + cell_size.x * 0.5) / cell_size.x * (displacement_image_bounds.x - 1)) - cell_index.x * (displacement_image_bounds.x - 1),
		round((bursh_cursor.position.z + cell_size.y * 0.5) / cell_size.y * (displacement_image_bounds.y - 1)) - cell_index.y * (displacement_image_bounds.y - 1)
	)
	
	var height: float = abs(height_change) / 50.0 * -1 * sign(height_change)
	print(height)

	paint_on_texture(cell_index, current_brush, brush_position, height)

	for neighbor in get_possible_neighbors(cell_index):
		if cell_exists(neighbor.x, neighbor.y):
			if brush_position_intersects_with_neighbor(cell_index, brush_position, neighbor):
				paint_on_texture(
					neighbor,
					current_brush,
					Vector2i(
						brush_position.x - (neighbor.x - cell_index.x) * (displacement_image_bounds.x - 1),
						brush_position.y - (neighbor.y - cell_index.y) * (displacement_image_bounds.y - 1)
					),
					height
				)
