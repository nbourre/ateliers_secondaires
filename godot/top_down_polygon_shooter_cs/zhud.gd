extends CanvasLayer
class_name HUD

var best_score = 0

var killCount = 0

func add_kill():
	killCount += 1
	set_best_score(killCount)		
	$VBoxContainer/HBoxKillCount/killCount.text = str(killCount)
	
func reset():
	killCount = 0
	$VBoxContainer/HBoxKillCount/killCount.text = 0

func get_best_score():
	return best_score
	
func set_best_score(score):
	if (score > best_score):
		best_score = score
	
	$VBoxContainer/HBoxBestScore.visible = true
	$VBoxContainer/HBoxBestScore/killCount.text = str(best_score)
