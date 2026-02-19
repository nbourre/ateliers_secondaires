extends Node2D

func _ready() -> void:

	# Charge les particules d'explosion
	var particles := $CPUParticles2D

	# Valider que les particules sont présentes
	if particles == null:
		return

	# Configure les particules pour qu'elles soient jouées une seule fois
	particles.one_shot = true

	# Connecte le signal "finished" à la fonction de rappel `_on_finished`
	# `finished` est émis lorsque les particules ont terminé de jouer
	particles.finished.connect(_on_finished)

	# Démarre les particules d'explosion
	particles.restart()

func _on_finished() -> void:
	queue_free()