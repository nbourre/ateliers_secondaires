class_name Cell
extends CharacterBody2D

@export var controller : Controller
@export var speed := 6000.0
@export var spawn_free_radius := 500.0

var life := 10.0;
var start_scale : float
var radius : float
var radius_ratio : float

var sprite : Sprite2D

var is_overlapped : bool = false

var activation : Area2D
var direction := Vector2.ZERO

var no_controller_msg := true

var objects_in_activation_area := []

func _ready() -> void:
	sprite = $Circle
	start_scale = scale.x
	radius = sqrt(life / PI)
	radius_ratio = start_scale / radius

	activation = $Activation


func grow(value : float) -> void:
	life += value;
	radius = sqrt(life / PI)
	scale.x = radius * radius_ratio
	scale.y = scale.x

	print("Life : " + str(life))

func get_no_spawn_radius() -> float:
	return spawn_free_radius

func _physics_process(delta: float) -> void:
	overlap_monitoring()

	if controller != null:
		direction = controller.get_movement()
		
		if direction.length() > 0:
			velocity = velocity.lerp(direction.normalized() * speed * delta, 0.1)
		else:
			velocity = velocity.lerp(Vector2.ZERO, 0.1)
	else:
		if no_controller_msg:
			print("No controller assigned to Cell: " + str(self.name))
			no_controller_msg = false
	
	move_and_slide()


func _on_activation_area_entered(area: Area2D) -> void:
	if (area.get_parent() is Cell):
		objects_in_activation_area.append(area.get_parent() as Cell)
	elif (area is Food):
		objects_in_activation_area.append(area as Food)
	
	if area.name != self.get_parent().name:
		is_overlapped = true

func _on_activation_area_exited(area: Area2D) -> void:
	if (area.get_parent() is Cell):
		objects_in_activation_area.erase(area.get_parent() as Cell)
	elif (area is Food):
		objects_in_activation_area.erase(area as Food)

	is_overlapped = objects_in_activation_area.size() > 1

func overlap_monitoring() -> void:
	if is_overlapped:
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)
	else:
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)

func set_controller(the_controller : Controller) -> void:
	controller = the_controller
	add_child(controller)
	no_controller_msg = false
