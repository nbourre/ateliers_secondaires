extends CanvasLayer

signal redemarrer

func _on_redemarrer_btn_pressed() -> void:
	redemarrer.emit()
