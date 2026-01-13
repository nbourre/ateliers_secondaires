extends Area2D


signal touche
signal ajouter_point


func _on_body_entered(body: Node2D) -> void:
	touche.emit()


func _on_zone_point_body_entered(body: Node2D) -> void:
	ajouter_point.emit()
