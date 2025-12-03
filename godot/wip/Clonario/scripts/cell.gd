class_name Cell
extends CharacterBody2D

@export var controller : Controller
@export var spawn_free_radius := 250.0

# Energy System - How long can the cell run fast?
@export_group("Energy")
@export var max_chase_energy := 5.0  # Seconds of chasing before tired
@export var max_flee_energy := 3.0   # Seconds of fleeing before tired
@export var chase_recharge_speed := 1.0  # How fast chase energy comes back
@export var flee_recharge_speed := 2.0   # Flee recharges 2x faster!

var chase_energy := max_chase_energy  # Current chase energy
var flee_energy := max_flee_energy     # Current flee energy

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
		# Ask the controller what it wants to do
		var behavior = controller.get_behavior()  # "chase", "flee", or "idle"
		var can_chase = chase_energy > 0
		var can_flee = flee_energy > 0
		
		direction = controller.get_movement_with_energy(can_chase, can_flee)
		
		# Energy management based on what the cell is doing
		if behavior == "chase":
			if can_chase:
				# Using chase energy!
				chase_energy = max(0, chase_energy - delta)
			else:
				# Out of chase energy, recharge it
				chase_energy = min(max_chase_energy, chase_energy + chase_recharge_speed * delta)
			# Always recharge flee energy when not fleeing
			flee_energy = min(max_flee_energy, flee_energy + flee_recharge_speed * delta)
			
		elif behavior == "flee":
			if can_flee:
				# Using flee energy!
				flee_energy = max(0, flee_energy - delta)
			else:
				# Out of flee energy, recharge it (faster!)
				flee_energy = min(max_flee_energy, flee_energy + flee_recharge_speed * delta)
			# Always recharge chase energy when not chasing
			chase_energy = min(max_chase_energy, chase_energy + chase_recharge_speed * delta)
			
		else:  # idle or moving normally
			# Resting - recharge both energies!
			chase_energy = min(max_chase_energy, chase_energy + chase_recharge_speed * delta)
			flee_energy = min(max_flee_energy, flee_energy + flee_recharge_speed * delta)
		
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