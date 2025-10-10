extends KinematicBody2D

var move_speed = 500
var motion = Vector2()

var bullet_speed = 1000
var bullet = preload("res://Bullet.tscn")

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	motion.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	motion.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	motion = motion.normalized()
	motion = move_and_slide(motion * move_speed)

