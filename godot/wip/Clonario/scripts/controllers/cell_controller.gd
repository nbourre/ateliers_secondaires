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
var move_speed: float = 4000.0

var chase_first_time: bool = true
var chase_time: float = 0.0
var chase_speed: float = 6000.0

var flee_speed: float = 8000.0

var movement_vector: Vector2 = Vector2.ZERO

var closest_object: Node2D = null

@export var chase_distance: float = 800.0
@export var flee_distance: float = 400.0
@export var debug_mode: bool = true

var debug_shapes : Array[DebugShape] = []

# Debug colors
var chase_color := Color(0, 1, 0, 0.2)  # Green
var flee_color := Color(1, 0, 0, 0.3)   # Red

var my_cell : Cell



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = State.IDLE
	set_process(true)
	my_cell = get_parent() as Cell

	if debug_mode:
		add_debug_shapes()

func add_debug_shapes() -> void:
	var dir_arrow := DebugShape.new()
	my_cell.add_child(dir_arrow)
	dir_arrow.set_shape_type (DebugShape.ShapeType.ARROW)
	dir_arrow.set_position(my_cell.position)
	dir_arrow.size = flee_distance

	debug_shapes.append(dir_arrow)
#	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state_manager(delta)
	
	_draw()

func _draw() -> void:
	if not debug_mode:
		return
	
	for shape in debug_shapes:
		shape.rotation = direction.angle()
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
			idle_state(delta)
		State.MOVE:
			move_state(delta)
		State.CHASE:
			chase_state(delta)
		State.FLEE:
			flee_state(delta)
	
	# Update debug visualization
	if debug_mode:
		my_cell.queue_redraw()

func idle_state(delta : float) -> void:
	idle_time += delta
	if idle_time > 3.0:
		current_state = State.MOVE
		idle_time = 0.0

func set_debug_mode(enabled : bool) -> void:
	debug_mode = enabled
	if not debug_mode:
		my_cell.update()  # Clear any existing drawings

func move_state(delta : float) -> void:
	move_time += delta
	if move_first_time:
		move_first_time = false
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	
	if move_time > 5.0:
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		move_time = 0.0
	
	movement_vector = direction * move_speed * delta

	# Check for prey (smaller cells or food)
	var prey = find_closest_prey()
	if prey != null:
		var distance_to_prey = get_parent().position.distance_to(prey.position)
		if distance_to_prey < chase_distance:
			closest_object = prey
			current_state = State.CHASE
			move_first_time = true
			move_time = 0.0
			return
	
	# Check for threats (larger cells)
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		if distance_to_threat < flee_distance:
			closest_object = threat
			current_state = State.FLEE
			move_first_time = true
			move_time = 0.0


func chase_state(delta : float) -> void:
	chase_time += delta
	if chase_first_time:
		chase_first_time = false
	
	# Check if a threat is nearby while chasing
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		if distance_to_threat < flee_distance:
			closest_object = threat
			current_state = State.FLEE
			chase_first_time = true
			chase_time = 0.0
			return
	
	# Update closest prey
	var prey = find_closest_prey()
	if prey != null:
		closest_object = prey
		var distance_to_prey = get_parent().position.distance_to(prey.position)
		
		# If prey is too far, go back to move state
		if distance_to_prey > chase_distance * 1.5:
			current_state = State.MOVE
			chase_first_time = true
			chase_time = 0.0
			return
		
		# Move towards prey
		direction = (prey.position - get_parent().position).normalized()
		movement_vector = direction * chase_speed * delta
	else:
		# No more prey, go back to move state
		current_state = State.MOVE
		chase_first_time = true
		chase_time = 0.0

func flee_state(delta : float) -> void:
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		
		# If threat is far enough, go back to move state
		if distance_to_threat > flee_distance * 1.5:
			current_state = State.MOVE
			return
		
		# Move away from threat
		direction = (get_parent().position - threat.position).normalized()
		movement_vector = direction * flee_speed * delta
	else:
		# No more threats, go back to move state
		current_state = State.MOVE

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

func find_closest_prey() -> Node2D:
	var closest_prey: Node2D = null
	var closest_distance: float = INF
	
	if my_cell == null:
		return null
	
	for obj in all_eatable_objects:
		if obj == null or not is_instance_valid(obj):
			continue
		
		var is_prey := false
		
		# Check if it's food
		if obj is Food:
			is_prey = true
		# Check if it's a smaller cell
		elif obj is Cell:
			var other_cell = obj as Cell
			if other_cell.get_size() < my_cell.get_size():
				is_prey = true
		
		if is_prey:
			var dist = my_cell.position.distance_to(obj.position)
			if dist < closest_distance:
				closest_distance = dist
				closest_prey = obj
	
	return closest_prey

func find_closest_threat() -> Node2D:
	var closest_threat: Node2D = null
	var closest_distance: float = INF
	
	if my_cell == null:
		return null
	
	for obj in all_eatable_objects:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# Only cells can be threats
		if obj is Cell:
			var other_cell = obj as Cell
			if other_cell.get_size() > my_cell.get_size():
				var dist = my_cell.position.distance_to(obj.position)
				if dist < closest_distance:
					closest_distance = dist
					closest_threat = obj
	
	return closest_threat