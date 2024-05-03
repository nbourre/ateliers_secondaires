extends RigidBody2D
class_name Bullet

var realName = ""

func _on_timer_timeout():
	queue_free() # Replace with function body.

# TODO : Désactiver s'il touche un mur
