extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_STEER_SPEED = 180.0 # TODO : Vitesse maximale de rotation en degrés par seconde
const SHOOT_DISTANCE = 500.0

var target : Node2D
var distance := Vector2.ZERO

var print_acc_time := 0.0
var print_last_time := 0.0



func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if target != null:
		
		distance = target.position - position


		steer_at(target.position, delta)

		if distance.length() > SHOOT_DISTANCE:
			var forward := Vector2.RIGHT.rotated(rotation)
			velocity = forward * SPEED
		else:
			velocity = velocity.lerp(Vector2.ZERO, 0.1) # Slow down when close to target
			shoot()

		move_and_slide()

		task_print_distance(delta)


func set_target(new_target: Node2D) -> void:
	target = new_target

func steer_at (position : Vector2, delta : float) -> void:
	if position == global_position:
		return

	var desired_angle := (position - global_position).angle()
	var max_step := deg_to_rad(MAX_STEER_SPEED) * delta
	rotation = rotate_toward(rotation, desired_angle, max_step)

func shoot() -> void:
	# TODO: decide on projectile scene and spawn logic.
	# var projectile := projectile_scene.instantiate()
	# projectile.global_position = global_position
	# projectile.rotation = rotation
	# get_tree().current_scene.add_child(projectile)
	pass

func task_print_distance (delta : float) -> void:
	const rate := 1.0

	print_acc_time += delta

	if print_acc_time > rate:
		print_acc_time = 0.0
		print("Distance to target : ", distance.length())
		
