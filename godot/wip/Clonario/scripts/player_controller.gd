class_name PlayerController
extends Controller

var direction := Vector2.ZERO
var dir_stop := 50.0
var speed := 6000.0

func get_movement() -> Vector2:
	return direction

func get_mouse_direction() -> Vector2:
	var world_mouse = get_viewport().get_camera_2d().get_global_mouse_position()
	
	return world_mouse


func _process(delta: float) -> void:
	direction = DisplayServer.mouse_get_position()
	var mouse_global = get_viewport().get_mouse_position()

	print(direction)
	
	if direction.length() < dir_stop:
		direction = direction.lerp(Vector2.ZERO, 0.1)
	else:
		direction = direction.normalized()
		direction = direction.lerp(direction * speed * delta, 0.1)