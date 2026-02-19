class_name Spawner
extends Path2D

enum SpawnType {PATH, RANDOM, CENTER}


@export var spawn_offset := Vector2.ZERO
@export var autospawn : bool = false
@export var spawn_delay : float = 2.0

@export var spawn_type : SpawnType = SpawnType.PATH

var delay_accumulator : float = 0.0

signal new_spawn_ready(Vector2)

var latest_position : Vector2

@onready var spawn_location := $SpawnLocation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if not autospawn:
		# Add spawning logic here
		return

	delay_accumulator += delta

	if delay_accumulator >= spawn_delay:
		delay_accumulator = 0.0
		# Add spawning logic here

		get_new_spawn_location(spawn_offset)


func get_new_spawn_location(offset : Vector2) -> Vector2:
	# get a new spawn location depending on the type

	match spawn_type:
		SpawnType.PATH:
			spawn_location.progress_ratio = randf()
			latest_position = position + spawn_location.position + offset
		SpawnType.RANDOM:
			# Random position limited in a rectangle
			var random_x := randf_range(-1000.0, 1000.0)
			var random_y := randf_range(-1000.0, 1000.0)
			latest_position = position + Vector2(random_x, random_y) + offset
		SpawnType.CENTER:
			var pos_around_center := randf() * 2 * PI
			var radius := 750.0

			latest_position = position + Vector2(
				cos(pos_around_center) * radius,
				sin(pos_around_center) * radius
			)
	

	new_spawn_ready.emit(latest_position)
	return latest_position
