extends Node3D

@onready var cell_manager: CellManager = $CellManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_camera_change_brush_radius(radius_change: float) -> void:
	cell_manager.change_brush_radius(radius_change)

func _on_camera_change_height(height_change: float) -> void:
	cell_manager.change_height(height_change)

func _on_camera_move_brush_cursor(brush_cursor_pos: Vector3) -> void:
	cell_manager.move_brush_cursor(brush_cursor_pos)

func _on_camera_load_signal() -> void:
	cell_manager.load_from_file()

func _on_camera_save_signal() -> void:
	cell_manager.save_to_file()
