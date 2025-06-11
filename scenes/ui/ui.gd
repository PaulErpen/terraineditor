extends Control

signal on_save_file_selected(path: String)
signal on_load_file_selected(path: String)

@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var load_file_dialog: FileDialog = $LoadFileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_file_menu_id_pressed(id: int) -> void:
	if id == 0:
		load_file_dialog.visible = true
	elif id == 1:
		save_file_dialog.visible = true


func _on_save_file_dialog_file_selected(path: String) -> void:
	on_save_file_selected.emit(path)


func _on_load_file_dialog_file_selected(path: String) -> void:
	on_load_file_selected.emit(path)
