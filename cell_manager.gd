extends Node3D

var handle_scene = preload("res://create_new_handle/create_new_handle.tscn")
var cell_scene = preload("res://cell/cell.tscn")

@onready var cells = { 0 : { 0: $Cell } }

func neighbor_exists(x: int, y: int) -> bool:
	if x in cells and cells[x] != null:
		if y in cells[x] and cells[x][y] != null:
			return true
	return false

func spawn_handles_for_cell(current_cell: Node3D, x: int, y: int):
	for neighbor in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if not neighbor_exists(x + neighbor.x, y + neighbor.y):
			var handle_instance: Node3D = handle_scene.instantiate()
			handle_instance.transform.origin = Vector3(neighbor.x, 0, neighbor.y)
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
	new_cell.transform.origin = Vector3(cell_position.x * 2, 0.0, cell_position.y * 2)
	cells[cell_position.x][cell_position.y] = new_cell
	add_child(new_cell)
	spawn_handles_for_cell(new_cell, cell_position.x, cell_position.y)
	clean_handles(cell_position.x, cell_position.y)
