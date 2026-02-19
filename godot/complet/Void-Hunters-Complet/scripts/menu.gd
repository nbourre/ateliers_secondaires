extends Node

signal demarrer_partie()

@onready var btn_demarrer := $BoutonDemarrer
@onready var lbl_message := $Message
@onready var chrono_message := $MessageTimer

func _on_btn_demarrer_appuye():
	btn_demarrer.hide()
	demarrer_partie.emit()

func _on_chrono_message_fin():
	lbl_message.hide()

func afficher_msg(msg: String) -> void:
	lbl_message.text = msg
	lbl_message.show()
	chrono_message.start()

func afficher_fin_partie() -> void:
	afficher_msg("Game Over!")
	await chrono_message.timeout
	lbl_message.text = "Les chasseurs du vide!"
	lbl_message.show()

	await get_tree().create_timer(1.0).timeout
	btn_demarrer.show()