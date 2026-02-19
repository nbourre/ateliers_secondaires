extends GPUParticles2D

func _ready() -> void:
	one_shot = true
	connect("finished", Callable(self, "_on_finished"))
	restart()

func _on_finished() -> void:
	queue_free()