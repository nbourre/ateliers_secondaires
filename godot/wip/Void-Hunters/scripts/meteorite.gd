class_name Meteorite
extends RigidBody2D

var sprite_names: Array = []
@onready var sprite := $Sprite2D

# Load explosion scene
@onready var explosion_scene: PackedScene = preload("res://scenes/explosion.tscn")

var health: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_sprite_names()
	set_random_sprite()

func load_sprite_names():
	var folder := "res://assets/sprites/meteors/"
	var dir := DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".png"):
					var filename := folder + file_name
					sprite_names.append(filename)
			file_name = dir.get_next()
		dir.list_dir_end()

func set_random_sprite() -> void:
	var random_index := randi() % sprite_names.size()
	var texture := load(sprite_names[random_index]) as Texture2D
	sprite.texture = texture

func appliquer_dommage(dommage: int, impulsion: Vector2) -> void:
	# Logique pour appliquer des dommages à la météorite
	if impulsion != Vector2.ZERO:
		# Appliquer une impulsion à la météorite avec
		#un biais aleatoire dans la direction de l'impulsion
		var random_biais := impulsion.rotated(randf_range(-PI/4, PI/4))
		impulsion += random_biais
		apply_impulse(impulsion)

	health -= dommage
	print("Météorite a subi %d points de dommage" % dommage)

	if health <= 0:
		# Logique pour détruire la météorite
		make_explosion()
		queue_free()
		


func make_explosion() -> void:
	var explosion_instance := explosion_scene.instantiate() as GPUParticles2D
	explosion_instance.position = position
	get_parent().add_child(explosion_instance)