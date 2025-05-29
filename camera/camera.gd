extends Node3D

@export var rotation_speed: float = 0.01
@export var camera_speed: float = 1.0

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
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera.position.z = clamp(camera.position.z - 0.1, 0.1, 10.0)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera.position.z = clamp(camera.position.z + 0.1, 0.1, 10.0)
