class_name Cell
extends Area2D


var life := 10.0;

var start_scale : float
var radius : float
var radius_ratio : float

var sprite : Sprite2D

var is_overlapped : bool = false

@export var controller : Controller
var direction := Vector2.ZERO

func _ready() -> void:
	sprite = $Circle
	start_scale = scale.x
	radius = sqrt(life / PI)
	radius_ratio = start_scale / radius

func grow(value : float) -> void:
	life += value;
	radius = sqrt(life / PI)
	scale.x = radius * radius_ratio
	scale.y = scale.x

	print("Life : " + str(life))

func _physics_process(_delta: float) -> void:
	overlap_monitoring()

	if controller != null:
		controller._process(_delta)
		direction = controller.get_movement()
	

func _on_body_entered(body: Node2D) -> void:
	if body.name != self.get_parent().name:
		is_overlapped = true
		

func _on_body_exited(_body: Node2D) -> void:
	
	is_overlapped = false

func overlap_monitoring() -> void:
	if is_overlapped:
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)
	else:
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)

func set_controller(the_controller : Controller) -> void:
	controller = the_controller