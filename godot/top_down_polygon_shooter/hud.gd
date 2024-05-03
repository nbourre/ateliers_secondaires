extends CanvasLayer
class_name HUD

var killCount = 0

func add_kill():
	killCount += 1
	$HBoxContainer/killCount.text = str(killCount)
	
func reset():
	killCount = 0
	$HBoxContainer/killCount.text = 0
