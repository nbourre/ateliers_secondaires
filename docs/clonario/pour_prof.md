# Notes pour le prof : Atelier 3, Clonario

Notes de conversion du pptx `Douance - Atelier - 03 - Clonario (Agario Clone).pptx` vers `index.md`.

## Restes de l'atelier 2 dans le pptx

- [ ] **Diapos 17 à 28** : les captures et vidéos sont celles de l'atelier 2 (projet plateforme, `joueur.tscn`, AnimatedSprite2D, le chevalier). Elles ont été retirées, donc les étapes 5, 6 et 7 sont en texte seulement. À faire : refaire quelques captures avec Clonario :
    - exploration de la scène `Monde` et du système de fichiers
    - ouverture de `scenes/cellule.tscn`
    - nœuds de la cellule (`Circle`, `Activation`, `CollisionShape2D`, `NameLabel`)
    - ajout de la cellule dans le monde et premier test
- [ ] **Diapo 33** : reprend « Programmer le joueur / Créer un script » de l'atelier 2. Sautée, car elle ne s'applique pas à Clonario.

## Écarts entre le pptx et le projet

- [ ] **ControleurJoueur** (diapo 29) : la diapo dit de le chercher dans le dossier `scenes` et de le glisser sur la cellule, mais il n'y a pas de `.tscn` pour lui. C'est une classe (`class_name ControleurJoueur`) dans `scripts/controleurs/controleur_joueur.gd`. La page dit d'ajouter un nœud enfant `ControleurJoueur`, comme pour `ControleurCellule`.
- [ ] **Barres d'énergie** (diapo 52) : la scène s'appelle `bar_progression.tscn` dans le projet, pas `barre_progression.tscn`. La page utilise le vrai nom.
- [ ] **Générateur de cellules** (diapo 40) : la diapo dit de renommer `CellSpawner` en `GenerateurCellule`, mais le nœud racine de `gen_cellule.tscn` s'appelle déjà `GenerateurCellule`. La page dit « assure-toi qu'il se nomme exactement… ». Même chose pour `GenerateurBouffe`.
- [ ] **Nom de la scène de la cellule** : le nœud racine de `cellule.tscn` s'appelle `Cell`, alors que les diapos parlent de « Cellule ». La page évite de nommer le nœud racine. À uniformiser dans le projet si tu veux.
- [ ] **Nom du zip** : la page utilise `Clonario.zip` (le nom dans `godot/`). Le pptx dit « clonario.zip ». Valider sur tinyurl.com/ateliers-jeux.
- Ligne 332 : vérifiée, c'est bien le début de `func etat_fuite` dans `controleur_cellule.gd`. La fonction se termine vers la ligne 347, juste avant `# endregion États IA`.
- Il traîne un fichier `scenes/world.tscn389359861.tmp` dans le zip, à nettoyer.

## Ce qui a été retiré du pptx

- Diapos 2 à 5 (qui suis-je, programmeur-analyste, tâches générales) et les vidéos d'inspiration de la diapo 6.
- Diapo 55 : le GIF de remerciement.
- L'icône « Chromebook + web » répétée sur plusieurs diapos.

## Ce qui a été ajouté

- Un encadré sur les contrôles du joueur, tiré de `project.godot` : souris pour se déplacer, clic gauche (ou `F`) pour la chasse, clic droit (ou `G`) pour la fuite, avec la consommation d'énergie.
- Un encadré « Un contrôleur, c'est quoi? » : la même scène de cellule devient un joueur ou un ennemi selon son contrôleur.
- La description des 5 états sous le diagramme de la machine à états, plus une note sur les machines à états finis.
- Une note sur le pseudo-code à côté des instructions de la fuite.
- Le code complet de `fallback/code_fuite.txt` dans un bloc de code.
- Un encadré repliable qui explique pourquoi `(get_parent().position - menace.position).normalized()` éloigne la cellule de la menace.
- Le raccourci `Ctrl + L` pour aller à une ligne dans l'éditeur de script.
- Des annotations « Que se passe-t-il? » avec la réponse cachée (bouffe mangée, cellules qui ne fuient pas).
