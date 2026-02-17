extends Node

signal demarrer_partie()

func afficher_msg(msg: String) -> void:
	var label = $Message
	label.text = msg
	label.show()
	$MessageTimer.start()

func afficher_fin_partie() -> void:
	afficher_msg("Game Over!")
	await $MessageTimer.timeout

	$Message.text = "Les chasseurs du vide!"
	$Message.show()

	await get_tree().create_timer(1.0).timeout
	$BoutonDemarrer.show()