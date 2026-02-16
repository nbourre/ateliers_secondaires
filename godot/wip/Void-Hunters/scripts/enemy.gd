extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_STEER_SPEED = 200.0

var target : Node2D
var distance := Vector2.ZERO

var print_acc_time := 0.0
var print_last_time := 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if target != null:
		
		distance = target.position - position

		# Une distance de 500 semble bien pour débuter à tirer


		var direction := distance.normalized()

		look_at(target.position)
		velocity = direction * SPEED
		move_and_slide()

		task_print_distance(delta)


func set_target(new_target: Node2D) -> void:
	target = new_target

func steer_at (position : Vector2) -> void:
	pass

func task_print_distance (delta : float) -> void:
	const rate := 1.0

	print_acc_time += delta

	if print_acc_time > rate:
		print_acc_time = 0.0
		print("Distance to target : ", distance.length())
		