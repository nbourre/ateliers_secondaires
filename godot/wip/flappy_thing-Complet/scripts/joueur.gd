class_name Joueur
extends CharacterBody2D

const GRAVITE : int = 1000
const VIT_MAX : int = 600
const VIT_POUSSEE : int = -500
const POS_DEPART := Vector2(100, 400)

var en_vol : bool = false
var en_chute : bool = false

func _ready() -> void:
	reset()

func reset() -> void:
	en_vol = false
	en_chute = false
	position = POS_DEPART
	set_rotation(0)

func _physics_process(delta: float) -> void:
	if en_vol or en_chute:
		velocity.y += GRAVITE * delta

		# Vitesse maximale
		if velocity.y > VIT_MAX:
			velocity.y = VIT_MAX
		
		if en_vol:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
		elif en_chute:
			set_rotation(deg_to_rad(90))
			$AnimatedSprite2D.stop()
		
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()

func pousser() -> void:
	velocity.y = VIT_POUSSEE