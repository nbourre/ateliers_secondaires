extends CharacterBody2D
class_name Player

@export var speed := 6000.0
@export var spawn_free_radius := 500.0

var direction := Vector2.ZERO

var dir_stop := 50.0

var cell : Cell

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell = $Cell
	cell.set_controller(PlayerController.new())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()

func get_no_spawn_radius() -> float:
	return spawn_free_radius
	
