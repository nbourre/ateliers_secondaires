class_name Cell
extends CharacterBody2D

@export var controller : Controller
@export var spawn_free_radius := 250.0

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
			velocity = velocity.lerp(direction, 0.1)
		else:
			velocity = velocity.lerp(Vector2.ZERO, 0.1)
	else:
		if no_controller_msg:
			print("No controller assigned to Cell: " + str(self.name))
			no_controller_msg = false
	
	move_and_slide()

func _on_activation_area_entered(_area: Area2D) -> void:
	is_overlapped = activation.get_overlapping_areas().size() > 0

func _on_activation_area_exited(_area: Area2D) -> void:
	is_overlapped = activation.get_overlapping_areas().size() > 0

func overlap_monitoring() -> void:
	is_overlapped = activation.get_overlapping_areas().size() > 0
	if not is_overlapped :
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)
		return

	sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)

	for obj in activation.get_overlapping_areas():
		# For debugging purposes
		if obj is Area2D and obj.get_parent() is Cell:

			var other_cell : Cell = obj.get_parent() as Cell

			if other_cell.get_size() == size:
				# Only care about different sized cells
				continue

			var distance := global_position.distance_to(other_cell.global_position)

			# Fix : The distance is not good enough, we need to check the actual radii
			if (distance < get_size()/3):
				print("Distance: " + str(distance) + "\t Size : " + str(other_cell.get_size()))
			
				if other_cell.get_size() < size:
					print("Distance: " + str(distance) + "\t Size : " + str(other_cell.get_size()))
					other_cell.die()
					grow(other_cell.get_life() * 0.25)
					continue
				else:
					die()
					continue

func die() -> void:
	if controller != null:
		controller.die()	

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

func set_all_eatable_objects(objects : Array) -> void:
	var all_eatable_objects := []
	all_eatable_objects = objects
	controller.set_eatable_objects(all_eatable_objects)