extends Node2D

func _ready() -> void:

	var particles := $CPUParticles2D

	particles.one_shot = true
	particles.finished.connect(_on_finished)
	particles.restart()

func _on_finished() -> void:
	queue_free()