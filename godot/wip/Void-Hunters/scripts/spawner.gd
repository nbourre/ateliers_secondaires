class_name Spawner
extends Path2D

@export var spawn_offset := Vector2.ZERO
@export var autospawn : bool = false
@export var spawn_delay : float = 2.0


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
	spawn_location.progress_ratio = randf()
	latest_position = spawn_location.position + offset

	new_spawn_ready.emit(latest_position)
	return latest_position
