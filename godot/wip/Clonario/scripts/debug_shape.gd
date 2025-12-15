class_name DebugShape
extends Node2D


enum ShapeType {
	CIRCLE,
	ARROW
}

var shape_type : ShapeType = ShapeType.ARROW
var size : float = 100.0
var angle : float = 0.0

# Point d’entrée du nœud.
func _ready() -> void:
	pass # À remplacer si on ajoute une logique.

# Mis à jour à chaque frame.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	match shape_type:
		ShapeType.ARROW:
			draw_arrow()
		ShapeType.CIRCLE:
			draw_a_circle()
		_:
			pass
	

func draw_arrow() -> void:
	draw_line(position, Vector2(position.x + size, 0), Color.GREEN, 1.0)
	draw_line(Vector2(position.x + size, 0), Vector2(position.x + size - 10, -10), Color.GREEN, 1.0)
	draw_line(Vector2(position.x + size, 0), Vector2(position.x + size - 10, 10), Color.GREEN, 1.0)
	rotate(angle)

func draw_a_circle() -> void:
	draw_circle(position, size, Color.GREEN)

func set_shape_type(value : ShapeType) -> void:
	shape_type = value