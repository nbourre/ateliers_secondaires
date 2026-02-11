extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_STEER_SPEED = 200.0

var target : Node2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if target != null:
		
		var direction := (target.position - position).normalized()

		look_at(target.position)
		velocity = direction * SPEED
		move_and_slide()


func set_target(new_target: Node2D) -> void:
	target = new_target

func steer_at (position : Vector2) -> void:
	pass