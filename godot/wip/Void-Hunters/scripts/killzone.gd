extends Area2D

@export var dommage := 10

func _on_body_entered(body: Node2D) -> void:
	if body is Dommageable:
		body.appliquer_dommage(dommage)
