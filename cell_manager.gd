extends Node3D

var handle_scene = preload("res://create_new_handle/create_new_handle.tscn")
var cell_scene = preload("res://cell/cell.tscn")
var brush_image: Image = preload("res://brush/brush.png").get_image()
var brush_size: float = 0.03

@onready var cells = { 0 : { 0: $Cell } }
@onready var bursh_cursor = $BrushCursor
@onready var cell_size: Vector2i = $Cell.mesh.size

func neighbor_exists(x: int, y: int) -> bool:
	if x in cells and cells[x] != null:
		if y in cells[x] and cells[x][y] != null:
			return true
	return false

func spawn_handles_for_cell(current_cell: Node3D, x: int, y: int):
	for neighbor in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if not neighbor_exists(x + neighbor.x, y + neighbor.y):
			var handle_instance: Node3D = handle_scene.instantiate()
			handle_instance.transform.origin = Vector3(neighbor.x * cell_size.x / 2.0, 0, neighbor.y * cell_size.y / 2.0)
			handle_instance.transform = handle_instance.transform.looking_at( - Vector3(neighbor.x, 0, neighbor.y))
			current_cell.add_child(handle_instance)
			handle_instance.cell_position = Vector2i(x + neighbor.x, y + neighbor.y)

func clean_handles(x: int, y: int):
	for neighbor in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if neighbor_exists(x + neighbor.x, y + neighbor.y):
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	brush_image.convert(Image.FORMAT_RF)
	spawn_handles()

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

func _on_move_brush_curser(brush_cursor_position: Vector3) -> void:
	bursh_cursor.position = brush_cursor_position

func _on_change_height(height_change: float) -> void:
	var x_index = int((abs(bursh_cursor.position.x) + cell_size.x * 0.5) / cell_size.x * sign(bursh_cursor.position.x))
	var y_index = int((abs(bursh_cursor.position.z) + cell_size.y * 0.5) / cell_size.y * sign(bursh_cursor.position.z))
	var current_cell: Node3D = cells[x_index][y_index]
	current_cell.is_changed = true
	var displacement_texure: Texture2D = current_cell.material_override.get("shader_parameter/displacement_texture")
	var displacement_image: Image = displacement_texure.get_image()
	var current_bursh = brush_image.duplicate()
	current_bursh.resize(
		int(brush_image.get_width() * brush_size),
		int(brush_image.get_height() * brush_size)
	)
	# print(height_change / 100.0)
	# brush_image.adjust_bcs(height_change, 1.0, 1.0)
	var brush_vec = Vector2i(
			int((bursh_cursor.position.x + cell_size.x * 0.5) / cell_size.x * displacement_image.get_width() - current_bursh.get_width() * 0.5),
			int((bursh_cursor.position.z + cell_size.y * 0.5) / cell_size.y * displacement_image.get_height() - current_bursh.get_height() * 0.5)
		)
	print(brush_vec)
	displacement_image.blit_rect(
		current_bursh,
		Rect2i(
			0, 0, current_bursh.get_width(), current_bursh.get_height()
		),
		brush_vec
	)
	var new_texture = ImageTexture.create_from_image(displacement_image)
	current_cell.material_override.set("shader_parameter/displacement_texture", new_texture)
