# Étapes générals pour créer un top-down shooter

# Base du joueur
1. Créer le monde 2d (World)
2. Glisser l'icône de base pour un point de repère pour voir le déplacement du joueur
3. Créer une scène pour le joueur
   1. CharacterBody2D
   2. CollisionPolygon2D
   3. Polygon2D
4. Renommer le noeud CharacterBody2D en Player
5. Dessiner le joueur dans le Polygon2D
6. Copier les data du Polygon2D dans le CollisionPolygon2D
7. Ajouter le script par défaut pour le joueur
8. Ajouter le joueur dans le monde
9. Tester pour montrer que le joueur se déplace, mais avec de la gravité
   1.  Par défaut, le script est pour un jeu de plateforme
10. Ajouter les touches WASD pour le déplacement au projet
11. Supprimer le contenu du script
12. Ajouter le nom de la class `Player` pour la bonne pratique
13. Ajouter le script process avec un pass
14. Ajouter un membre `var direction := Vector2()`

```gd
func _process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	direction = direction.normalized()	
```

15. Expliquer le concept de la normalisation avec un carré
16. Ajouter les variables qui suivent

```gd
@export var speed = 1000
@export var acceleration = 0.1
@export var friction = 0.05
```

17. Expliquer le mot clé `export`
18. Ajouter le code pour le déplacement

```gd
	if (direction.length() > 0):
		velocity = velocity.lerp(direction * speed, acceleration)
	else :
		velocity = velocity.lerp(Vector2.ZERO, friction)

    move_and_slide()
```

19. Tester le déplacement du joueur
20. Ajouter la ligne `look_at(get_global_mouse_position())` pour que le joueur regarde la souris
21. Tester le déplacement du joueur
22. Ajouter la caméra

# Ajouter les Projectiles
1. Créer une scène pour le Bullet
   1. Rigidbody2D renommé en Bullet
   2. CollisionShape2D
   3. ColorRect
2. Ajouter un script pour le Bullet
   1. Nom de la class `Bullet`
3. Ajouter le membre "real_name" à "Bullet"
4. Tester la dimension en ajoutant un Bullet dans la scène
5. Ajuster la dimension du Bullet
6. Dans le script du joueur
7. Charger le Bullet dans le script
   1. `var bullet := preload("res://Bullet.tscn")` 
8. Ajouter une variable bullet_speed
9. Ajouer la fonction `fire()`

```gd
func fire() :
	var instance = bullet.instantiate() as Bullet
	instance.transform = muzzle.get_global_transform()
	instance.linear_velocity = direction * velocity
	instance.apply_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", instance)
```

# Créer un ennemi
1. Structure de l'ennemi
   1. CharacterBody2D
   2. Polygon2D
   3. CollisionPolygon2D
   4. Area2D
      1. CollisionPolygon2D
2. Ajuster la dimension de l'ennemi (losange de 20x20)
3. Ajouter un script pour l'ennemi
   1. Nom de la class `Enemy`

```gd
extends CharacterBody2D
class_name Enemy

var player : Player

var speed := 5

func _ready() -> void:
	player = get_node("/root/World/Player")

func _process(delta: float) -> void:
	var direction = player.position - position
	direction = direction.normalized() * speed
	
	look_at(player.position)
	
	var _collision := move_and_collide(direction)
```

4. Ajouter l'ennemi dans le monde
5. Tester le déplacement de l'ennemi
6. Connecter l'événement `body_entered` de l'ennemi
7. Modifier le script de l'ennemi pour l'éliminer lorsqu'il est touché par un Bullet

```gd
func _on_area_2d_body_entered(body: Node2D) -> void:
	var area_name := body.name.to_lower()

	if ("bullet" in area_name or "rigidbody2d" in area_name):
		body.queue_free()
		queue_free()
```

8. Tester le jeu
9. Modifier le script pour ajouter de l'énergie à l'ennemi

```gd
var hp := 10

func _on_area_2d_body_entered(body: Node2D) -> void:
	var area_name := body.name.to_lower()

	if ("bullet" in area_name or "rigidbody2d" in area_name):
		hp -= 1
		body.queue_free()
		if (hp <= 0):
			queue_free()
```

# Mettre à jour le joueur
On veut que le joueur puisse mourir lorsqu'il est touché par un ennemi
1. Ajouter un `Area2D` au joueur
   1. CollisionPolygon2D
2. Connecter l'événement `area_entered` du joueur au script du joueur
3. Ajouter le signal `player_died` au joueur
4. Voici le code pour `_on_area_2d_area_entered`

```gd
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Enemy:
		var _tmp = get_tree().call_deferred("reload_current_scene")
		player_died.emit()
```

5. Tester le jeu

# Créer les murs
1. Créer un scène avec `Node2D`
2. Renommer le noeud en `Level`
3. Ajouter un `TileMapLayer`
4. Ajouter un `Tile Set`
5. Créer une image 32x32. Un simple carré peut faire l'affaire
6. Configurer le `Tile Set` à 32x32
7. Ajouter un `Physics Layers` dans le `Tile Set`
8. Dans le volet `Tile Set`, ajouter l'image
9. Sélectionner la tuile
10. Sélectionner `Physics Layer 0` pour la tuile
11. Faire un carré
12. Tracer les murs avec le menu `TileMap`
13. Ajouter le level dans le monde
14. Tester le jeu
15. Ajouter des ennemis supplémentaires

Voilà c'est les bases d'un top-down shooter. Je ferai une seconde vidéo pour les extras comme le HUD, l'éclarairage ou le spawn des ennemis.