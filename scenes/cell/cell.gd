extends MeshInstance3D

class_name Cell

@export var is_changed = false
@onready var collision_shape = $Area3D/CollisionShape3D

func generate_flat_image() -> void:
	var flat_image = Image.create_empty(mesh.subdivide_width + 2, mesh.subdivide_depth + 2, false, Image.FORMAT_RF)
	var texture = ImageTexture.create_from_image(flat_image)
	set_displacement_texture(texture)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_flat_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_changed:
		var heightmap_texture: Texture = get_displacement_texture()
		set_collision_shape_texture(heightmap_texture)
		is_changed = false

func set_brush_radius(brush_radius: float) -> void:
	material_override.set("shader_parameter/brush_radius", brush_radius)

func set_brush_position(brush_position: Vector2) -> void:
	material_override.set("shader_parameter/brush_position", brush_position)

func get_displacement_texture() -> Texture:
	var heightmap_texture: Texture = material_override.get("shader_parameter/displacement_texture")
	if heightmap_texture == null:
		generate_flat_image()
		heightmap_texture = material_override.get("shader_parameter/displacement_texture")
	return heightmap_texture

func set_collision_shape_texture(texture: Texture) -> void:
	var heightmap_image: Image = texture.get_image()
	heightmap_image.convert(Image.FORMAT_RF)
	var height_map_shape: HeightMapShape3D = collision_shape.shape
	height_map_shape.update_map_data_from_image(heightmap_image, 0.0, 10.0)

func set_displacement_texture(texture: Texture) -> void:
	if texture is ImageTexture:
		material_override.set("shader_parameter/displacement_texture", texture)
		set_collision_shape_texture(texture)
		
	else:
		push_error("set_displacement_texture expects an ImageTexture.")
	is_changed = true