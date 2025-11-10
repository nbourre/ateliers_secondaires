extends Area2D

var gestionnaire_jeu : Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if get_tree().get_root().has_node("Monde/GestionnaireJeu"):
		gestionnaire_jeu = get_tree().get_root().get_node("Monde/GestionnaireJeu")


func _on_body_entered(_body: Node2D) -> void:
	if gestionnaire_jeu != null:
		gestionnaire_jeu.ajouter_point()
	animation_player.play("ramassage")
