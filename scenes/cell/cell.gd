@tool
extends MeshInstance3D

@export var is_changed = true
@onready var collision_shape = $Area3D/CollisionShape3D

func generate_flat_image() -> void:
	var flat_image = Image.create_empty(mesh.subdivide_width + 2, mesh.subdivide_depth + 2, false, Image.FORMAT_RF)
	var texture = ImageTexture.create_from_image(flat_image)
	material_override.set("shader_parameter/displacement_texture", texture)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_flat_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_changed:
		var heightmap_texture: Texture = material_override.get("shader_parameter/displacement_texture")
		if heightmap_texture == null:
			generate_flat_image()
			heightmap_texture = material_override.get("shader_parameter/displacement_texture")
		var heightmap_image: Image = heightmap_texture.get_image()
		heightmap_image.convert(Image.FORMAT_RF)
		var height_map_shape: HeightMapShape3D = collision_shape.shape
		height_map_shape.update_map_data_from_image(heightmap_image, 0.0, 10.0)
		is_changed = false
