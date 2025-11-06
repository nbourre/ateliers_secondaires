extends Node

var score : int = 0

#@onready var pointage: Label = $Pointage

func ajouter_point():
	#pointage.text = "Tu as récolté " + str(score) + " pièces."
	score += 1
	print (score)
