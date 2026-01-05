extends Node2D

# Source : https://www.youtube.com/watch?v=9f9t9eiCDAA

@export var scene_tuyau : PackedScene

var en_execution : bool
var fin_partie : bool
var defilement : float
var score : int

const VIT_DEFILEMENT : int = 4
var dimension_monde : Vector2i
var hauteur_sol : int

var tuyaux : Array
const DECALAGE_TUYAU : int = 100
const PLAGE_TUYAU : int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dimension_monde = get_window().size
	hauteur_sol = $Sol.get_node("Sprite2D").texture.get_height()
	nouvelle_partie()

func nouvelle_partie() -> void:
	en_execution = false
	fin_partie = false
	defilement = 0.0
	score = 0
	$CanvasLayer/ScoreLabel.text = "SCORE : " + str(score)

	$FinPartie.hide()

	get_tree().call_group("tuyaux", "queue_free")
	
	tuyaux.clear()
	generer_tuyau()
	$Joueur.reset()

func _input(event: InputEvent) -> void:
	if fin_partie == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if en_execution == false:
					demarrer_partie()
				else:
					if $Joueur.en_vol:
						$Joueur.pousser()
						verifier_plafond()
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			get_tree().quit()

func demarrer_partie() -> void:
	en_execution = true
	$Joueur.en_vol = true
	$Joueur.pousser()
	$TuyauChrono.start()

func arreter_partie() -> void:
	en_execution = false
	fin_partie = true
	$Joueur.en_vol = false
	$TuyauChrono.stop()
	$FinPartie.show()

func verifier_plafond() -> void:
	if $Joueur.position.y <= 0:
		$Joueur.en_chute = true
		arreter_partie()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if en_execution:
		defilement += VIT_DEFILEMENT
		
		if defilement >= dimension_monde.x:
			defilement = 0.0

		$Sol.position.x = -defilement

		for tuyau in tuyaux:
			tuyau.position.x -= VIT_DEFILEMENT
			


func _on_tuyau_chrono_timeout() -> void:
	generer_tuyau()

func generer_tuyau() -> void:
	var tuyau = scene_tuyau.instantiate()
	tuyau.position.x = dimension_monde.x + DECALAGE_TUYAU
	tuyau.position.y = (dimension_monde.y - hauteur_sol) / 2 + randi_range(-PLAGE_TUYAU, PLAGE_TUYAU)
	
	tuyau.touche.connect(oiseau_touche)
	tuyau.ajouter_point.connect(func() -> void:
		score += 1
		$CanvasLayer/ScoreLabel.text = "SCORE : " + str(score)
	)

	add_child(tuyau)
	tuyaux.append(tuyau)

func oiseau_touche() -> void:
	$Joueur.en_chute = true
	arreter_partie()

func _on_sol_sol_touche() -> void:
	$Joueur.en_chute = false
	arreter_partie()


func _on_fin_partie_redemarrer() -> void:
	nouvelle_partie()
