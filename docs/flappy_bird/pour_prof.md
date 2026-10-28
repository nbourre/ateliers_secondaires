# Notes pour le prof : Atelier 4, Flappy Bird

Notes de conversion du pptx `Douance - Atelier - 04 - Flappy Bird (Clone).pptx` vers `index.md`.

## Bogues probables dans le projet

- [ ] **Les vieux tuyaux restent après un redémarrage** : dans `fallback/monde_c_tuyaux.txt`, la fonction `nouvelle_partie()` fait `tuyaux.clear()` mais ne supprime pas les nœuds. Les tuyaux de la partie précédente restent donc figés à l'écran (et toujours en collision). `monde_z_complet.txt` contient la ligne qui manque :
    ```gdscript
    get_tree().call_group("tuyaux", "queue_free")
    ```
    Le groupe `tuyaux` existe déjà dans `tuyau.tscn`. Il suffirait d'ajouter la ligne en commentaire dans `monde_c_tuyaux.txt` (avant `tuyaux.clear()`) et de la faire décommenter à l'étape 13.
- [ ] **Le pointage ne revient pas à 0** : il y a deux lignes `#$ScoreLabel.text = ...` dans `monde_c_tuyaux.txt` (lignes 36 et 95). La diapo 45 n'en mentionne qu'une (« vers la ligne 93 »). Sans la ligne 36, le texte garde l'ancien pointage après un redémarrage jusqu'au premier point. La page demande de décommenter les deux.

## Numéros de ligne (vérifiés dans `monde_c_tuyaux.txt`)

| Ligne | Diapo | Réel |
|---|---|---|
| `#tuyau.touche.connect(oiseau_touche)` | 91 | 92 |
| `func oiseau_touche` | 105 | 106 |
| `#verifier_plafond()` (appel) | 57 | 58 |
| `func verifier_plafond` | 100 | 101 |
| `#$ScoreLabel.text` | 93 | 36 et 95 |
| `#$FinPartie.hide()` / `#$FinPartie.show()` | 38 et 119 | 38 et 119 |

La page utilise les numéros réels. Ils supposent que l'élève a collé `monde_c_tuyaux.txt` sans rien modifier.

## Trous dans le pptx

- [ ] **Diapo 3** : « TODO : Mettre capture d'écran » (page de téléchargement). Pas d'image dans la page pour l'étape 1.
- [ ] **Diapo 5** : « TODO : Remplacer par capture d'écran » (importer le projet). Pas d'image dans la page pour l'étape 3.
- [ ] **Diapo 13** : une puce est incomplète (« Ajoute un nœud enfant « »). Retirée.
- [ ] **Diapo 13** : la diapo dit de sauvegarder (`Ctrl + S`) sans préciser le nom ni le dossier. La page dit d'enregistrer sous `joueur.tscn`. Valider si tu veux qu'il soit dans `scenes/`.
- [ ] **Nom du dossier** : j'ai nommé le dossier de la page `flappy_bird`, alors que le projet s'appelle `flappy_thing`.

## Ce qui a été retiré du pptx

- Diapo 1 : l'icône de manette.
- Diapo 3 : l'image d'ambiance (circuit).
- Diapo 19 : le dessin de l'oiseau avec les étiquettes (Départ, Gravité, V_max, Poussée). Le texte de la diapo est gardé en liste.
- Diapos 21 et 22 : les captures de code, remplacées par des blocs de code copiables.
- Diapos 30 et 31 : les images du tuyau et du métronome (décoratives).
- La diapo 28 était identique à la diapo 27 (même image du sol).

## Ce qui a été ajouté

- Le code complet des trois fichiers `joueur_*.txt` dans des blocs de code.
- Le bout de `_process` qui fait défiler le sol (étape 9).
- Des encadrés :
    - « C'est quoi une variable? » (variable et constante)
    - « Pourquoi la poussée est négative? » (l'axe y vers le bas dans Godot)
    - explication de `_physics_process`
    - explication de `_input` dans `monde_a_base.txt`
    - le Z Index
    - le raccourci `Ctrl + L` pour aller à une ligne
- Un tableau des fichiers du dossier `assets`.
- Dans le supplément, des pistes concrètes pour la difficulté (`VIT_DEFILEMENT`, `PLAGE_TUYAU`).
- Dans les références, la vidéo YouTube citée en commentaire dans `monde_a_base.txt` comme source du code.

## Autre

- Le zip contient des images supplémentaires mentionnées à la diapo 49 (`Exeggutor_Alolan.webp`, `zubat_60x60.png`, `Exeggutor.tscn`). Ce sont des personnages Pokémon. Comme le dépôt est public, à toi de voir si tu veux les garder dans le zip.
