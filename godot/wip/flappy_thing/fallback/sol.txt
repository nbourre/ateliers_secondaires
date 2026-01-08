extends Area2D

signal sol_touche

func _on_body_entered(body: Node2D) -> void:
	sol_touche.emit()
