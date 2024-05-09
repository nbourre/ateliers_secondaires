extends CharacterBody2D
class_name Player

signal player_died

@export var speed = 1000
@export var acceleration = 0.1
@export var friction = 0.05

var direction = Vector2()

# TODO : Ajouter timer au jeu
var bullet_speed = 1000
var bullet = preload("res://Bullet.tscn")

var has_joystick : bool

func _ready():
	has_joystick = Input.get_connected_joypads().size() > 0

func _physics_process(_delta):
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	direction = direction.normalized()
	
	#if (has_joystick) :
		#rotate((Input.get_action_strength("spinRight") - Input.get_action_strength("spinLeft")) * PI / 10)
	#else:
		#look_at(get_global_mouse_position())
	look_at(get_global_mouse_position())
	
	if (Input.is_action_just_pressed("fire")):
		fire()
	
	if (direction.length() > 0):
		velocity = velocity.lerp(direction * speed, acceleration)
	else :
		velocity = velocity.lerp(Vector2.ZERO, friction)
			
	move_and_slide()


func fire():
	var bullet_instance = bullet.instantiate() as Bullet
	bullet_instance.position = get_global_position() + (Vector2.from_angle(rotation) * 25)
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	bullet_instance.realName = "Bullet"
	get_tree().get_root().call_deferred("add_child", bullet_instance)
 
func _on_area_2d_area_entered(area):

	#if "Enemy" in area.get_parent().name :
	if area.get_parent() is Enemy :
		var _tmp = get_tree().call_deferred("reload_current_scene")
		player_died.emit()
