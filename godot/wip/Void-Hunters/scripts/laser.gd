class_name Laser
extends RigidBody2D

var vitesse: float = 2000.0

var time_to_live: float = 2.0
var life_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * vitesse * delta

	life_timer += delta
	if life_timer >= time_to_live:
		queue_free()


func _on_killzone_body_entered(body: Node2D) -> void:
	print("Zone de destruction touchée par: %s" % body.name)

func set_vitesse(new_speed: float) -> void:
	apply_impulse(Vector2(new_speed, 0).rotated(rotation))