extends Node

var score : int = 0

var pointage: Label

func _ready() -> void:
	if (has_node("Pointage")):
		pointage = $Pointage

func ajouter_point():
	if pointage != null:
		pointage.text = "Tu as récolté " + str(score) + " pièces."
	score += 1
	print (score)
