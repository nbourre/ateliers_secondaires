class_name Joueur
extends CharacterBody2D

# Classe représentant le vaisseau du joueur en vue de dessus.
# Il avance avec la touche "propulsion"
# Il tourne en regardant la souris
# Il peut également tirer des projectiles avec la touche "tir"

signal sante_changee
signal est_mort

@export var max_sante := 100.0
@export var sante : float = 100.0

var vitesse: float = 1500.0
var acceleration: float = 200.0

@onready var propulseur := $Propulseur
@onready var freins := $Freins

@onready var laser_scene: PackedScene = preload("res://scenes/laser.tscn")
@onready var marker_2d := $Marker2D

@onready var collision_scene: PackedScene = preload("res://scenes/collision_vaisseau.tscn")

var tir_active := false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO

	# Gestion de la propulsion
	if Input.is_action_pressed("propulsion"):
		direction = Vector2.UP.rotated(rotation + PI / 2)
		velocity = velocity.move_toward(direction * vitesse, acceleration * delta)
		propulseur.visible = true
	else:
		propulseur.visible = false

	# Gestion du frein
	if Input.is_action_pressed("frein"):
		direction = Vector2.UP.rotated(rotation + PI / 2)
		velocity = velocity.move_toward(-direction * vitesse * 0.5, acceleration * delta)
		freins.visible = true
	else:
		freins.visible = false

	# Orientation vers la souris
	var souris_position: Vector2 = get_global_mouse_position()
	look_at(souris_position)

	# Tir de projectiles
	if Input.is_action_just_pressed("tir") and tir_active:
		tirer_projectile()

	move_and_slide()
	
func tirer_projectile() -> void:
	var projectile_instance:= laser_scene.instantiate() as Laser
	projectile_instance.position = marker_2d.global_position
	projectile_instance.rotation = global_rotation + PI / 2
	#projectile_instance.velocity = Vector2.UP.rotated(projectile_instance.rotation) * projectile_instance.vitesse
	projectile_instance.name += "_laser"
	get_parent().add_child(projectile_instance)

func appliquer_dommage(dommage: float) -> void:
	sante -= dommage
	sante_changee.emit()
	exploser()
	
	if sante <= 0:
		est_mort.emit()
		
func exploser() -> void:
	var explosion := collision_scene.instantiate() as ExplosionVaisseau
	explosion.position = position
	get_parent().add_child(explosion)
	explosion.activer()
