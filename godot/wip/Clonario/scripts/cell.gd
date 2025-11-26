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
var size : float
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
	set_life(life)


func set_life(new_life : float) -> void:
	life = new_life
	
	radius = sqrt(life / PI)
	scale.x = radius * radius_ratio
	scale.y = scale.x
	
	set_size(sprite.texture.get_size().x * scale.x)

func grow(value : float) -> void:
	set_life(life + value)

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
	is_overlapped = activation.get_overlapping_areas().size() > 0
	
	# if area.name != self.get_parent().name:
	# 	is_overlapped = true

func _on_activation_area_exited(area: Area2D) -> void:
	is_overlapped = activation.get_overlapping_areas().size() > 0

func overlap_monitoring() -> void:
	if not is_overlapped :
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)
		return

	sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)

	for obj in activation.get_overlapping_areas():
		# For debugging purposes
		if obj is Area2D and obj.get_parent() is Cell:
			print(name + " is overlapping with: " + str(obj.get_parent().name))

func set_controller(the_controller : Controller) -> void:
	controller = the_controller
	add_child(controller)
	no_controller_msg = false

func get_sprite() -> Sprite2D:
	return sprite

func get_life() -> float:
	return life

func get_radius() -> float:
	return radius

func get_size() -> float:
	return size

func set_size(new_size : float) -> void:
	size = new_size

func set_label(new_name : String) -> void:
	name = new_name
	$NameLabel.text = new_name
