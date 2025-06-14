extends VBoxContainer

signal change_brush_type(brush_type: Brush.BrushType)

@onready var brush_popup: PanelContainer = $BrushPopup
@onready var current_brush: TextureButton = $CurrentBrush

@onready var linear_brush: TextureButton = $BrushPopup/VBoxContainer/LinearBrush
@onready var round_brush: TextureButton = $BrushPopup/VBoxContainer/RoundBrush
@onready var gaussian_brush: TextureButton = $BrushPopup/VBoxContainer/GaussianBrush

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_current_brush_button_up() -> void:
	brush_popup.visible = !brush_popup.visible

func switch_active_texture(next_brush: TextureButton) -> void:
	current_brush.texture_normal = next_brush.texture_normal
	current_brush.texture_pressed = next_brush.texture_pressed
	current_brush.texture_hover = next_brush.texture_hover

func _on_linear_brush_button_up() -> void:
	brush_popup.visible = false
	switch_active_texture(linear_brush)
	change_brush_type.emit(Brush.BrushType.Linear)


func _on_round_brush_button_up() -> void:
	brush_popup.visible = false
	switch_active_texture(round_brush)
	change_brush_type.emit(Brush.BrushType.Round)


func _on_gaussian_brush_button_up() -> void:
	brush_popup.visible = false
	switch_active_texture(gaussian_brush)
	change_brush_type.emit(Brush.BrushType.Gaussian)
