class_name PlayerController
extends Controller

var direction := Vector2.ZERO
var dir_stop := 150.0

var move_speed := 4000.0

func get_movement() -> Vector2:
	return direction

func die() -> void:
	get_tree().reload_current_scene()

# Returns a normalized vector pointing from the center of the screen to the mouse position
func get_mouse_direction() -> Vector2:
	#var mouse_global := DisplayServer.mouse_get_position() as Vector2
	var mouse_vp := get_viewport().get_mouse_position()
	var screen_center := get_viewport().get_visible_rect().size / 2
	var dir := mouse_vp - screen_center
	
	return dir


func _process(delta: float) -> void:
	
	var dir := get_mouse_direction()

	if dir.length() < dir_stop:
		# FIXME: Not stopping
		direction = direction.lerp(Vector2.ZERO, 0.1)
		#print("Stopping")
	else:
		direction = direction.lerp(dir.normalized() * move_speed * delta, 0.1)
