# This is the AI controller for non-player cells.
class_name CellController
extends Controller

enum State {
	IDLE,
	MOVE,
	CHASE,
	FLEE
}

var current_state: State = State.IDLE

var all_eatable_objects := []

var direction: Vector2 = Vector2.ZERO

var idle_time: float = 0.0

var move_first_time: bool = true
var move_time: float = 0.0
var move_speed: float = 400.0

var flee_speed: float = 600.0

var movement_vector: Vector2 = Vector2.ZERO

@export var chase_distance: float = 800.0
@export var flee_distance: float = 400.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_movement() -> Vector2:
	return movement_vector

func die() -> void:
	get_parent().queue_free()
	print("Cell has died.")

func set_eatable_objects(objects : Array) -> void:
	all_eatable_objects = objects

func state_manager(delta : float) -> void:
	match current_state:
		State.IDLE:
			# Logic for idle state
			pass
		State.MOVE:
			# Logic for move state
			pass
		State.CHASE:
			# Logic for chase state
			pass
		State.FLEE:
			# Logic for flee state
			pass

func idle_state(delta : float) -> void:
	idle_time += delta
	if idle_time > 3.0:
		current_state = State.MOVE
		idle_time = 0.0

func move_state(delta : float) -> void:
	move_time += delta
	if move_first_time:
		move_first_time = false
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	
	if move_time > 5.0:
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		move_time = 0.0
	
	movement_vector = direction * move_speed * delta

	var closest_object = find_closest_eatable_object()
	if closest_object != null:
		var distance_to_object = get_parent().position.distance_to(closest_object.position)
		var change_state := false
		if distance_to_object < chase_distance:
			current_state = State.CHASE
			change_state = true
		elif distance_to_object < flee_distance:
			current_state = State.FLEE
			change_state = true

		if change_state:
			move_first_time = true
			move_time = 0.0


func chase_state(delta : float) -> void:
	pass

func flee_state(delta : float) -> void:
	pass

func find_closest_eatable_object() -> Node2D:
	var closest_object: Node2D = null
	var closest_distance: float = INF
	
	for obj in all_eatable_objects:
		if obj is Node2D:
			var dist = get_parent().position.distance_to(obj.position)
			if dist < closest_distance:
				closest_distance = dist
				closest_object = obj
	
	return closest_object