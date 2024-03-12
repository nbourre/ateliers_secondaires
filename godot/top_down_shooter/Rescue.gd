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

	look_at(get_global_mouse_position())

	if (Input.is_action_just_pressed("lmb")):
		fire()

func fire():
	var bullet_instance = bullet.instance()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)

func kill():
	var _tmp = get_tree().reload_current_scene()
	

func _on_Area2D_body_entered(body:Node):
	if "Enemy" in body.name:
		kill()

