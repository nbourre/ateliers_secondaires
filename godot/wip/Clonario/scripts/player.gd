extends CharacterBody2D
class_name Player

@export var speed := 6000.0
@export var spawn_free_radius := 500.0

var direction := Vector2.ZERO

var dir_stop := 50.0

# radius around player where food will not spawn



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction := get_global_mouse_position() - global_position


	if direction.length() < dir_stop:
		direction = Vector2.ZERO	

	direction = direction.normalized()


	
	velocity = velocity.lerp(direction * speed * delta, 0.1)
	move_and_slide()

func get_no_spawn_radius() -> float:
	return spawn_free_radius
	
