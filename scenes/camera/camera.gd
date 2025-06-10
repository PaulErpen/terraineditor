extends Node3D

@export var rotation_speed: float = 0.01
@export var camera_speed: float = 10.0
@export var scroll_speed: float = 3.0
@export var scroll_max: float = 100.0

@onready var camera: Camera3D = $Gimbal/Camera3D
@onready var gimbal: Node3D = $Gimbal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement_direction: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		movement_direction -= basis.z
	if Input.is_action_pressed("backward"):
		movement_direction += basis.z
	if Input.is_action_pressed("left"):
		movement_direction -= basis.x
	if Input.is_action_pressed("right"):
		movement_direction += basis.x
	
	if movement_direction != Vector3.ZERO:
		movement_direction.y = 0
		movement_direction = movement_direction.normalized() * camera_speed
		transform.origin += movement_direction * delta


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			rotate_y(-event.relative.x * rotation_speed)
			gimbal.rotate_x(-event.relative.y * rotation_speed)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent_node_3d()._on_change_height(event.relative.y)
		elif Input.is_action_pressed("resize_brush"):
			var cell_manager = get_parent_node_3d()
			cell_manager.brush_radius = clamp(cell_manager.brush_radius + event.relative.y * 0.01, 0.1, cell_manager.displacement_image_bounds.x - 1)
		else:
			# cast a ray from the camera to the mouse position
			var from: Vector3 = camera.project_ray_origin(event.position)
			var to: Vector3 = from + camera.project_ray_normal(event.position) * 1000.0
			var space_state = get_world_3d().direct_space_state
			var ray_cast_params = PhysicsRayQueryParameters3D.create(
				from, to
			)
			ray_cast_params.set_collide_with_areas(true)
			ray_cast_params.set_collision_mask(2)
			var result = space_state.intersect_ray(ray_cast_params)
			if result:
				get_parent_node_3d()._on_move_brush_curser(result.position)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera.position.z = clamp(camera.position.z - scroll_speed, 0.1, scroll_max)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera.position.z = clamp(camera.position.z + scroll_speed, 0.1, scroll_max)
