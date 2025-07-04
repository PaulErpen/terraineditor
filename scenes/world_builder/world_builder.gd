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


func _on_ui_on_load_file_selected(path: String) -> void:
	cell_manager.load_from_file(path)


func _on_ui_on_save_file_selected(path: String) -> void:
	cell_manager.save_to_file(path)

func _on_ui_change_brush_type(brush_type: Brush.BrushType) -> void:
	cell_manager.brush_type = brush_type
