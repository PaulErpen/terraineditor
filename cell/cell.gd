@tool
extends MeshInstance3D

@export var is_changed = true
@onready var collision_shape = $Area3D/CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_changed:
		var heightmap_image: Image = material_override.get("shader_parameter/displacement_texture").get_image()
		heightmap_image.convert(Image.FORMAT_RF)
		heightmap_image.resize(17, 17)
		var height_map_shape: HeightMapShape3D = collision_shape.shape
		height_map_shape.update_map_data_from_image(heightmap_image, 0.0, 10.0)
		is_changed = false
