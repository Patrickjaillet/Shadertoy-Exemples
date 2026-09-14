# Roadmap — Site de visualisation des Shadertoy du dépôt

## Objectif

Créer une page web statique, hébergée sur GitHub Pages, qui permet de :
- parcourir les shaders du dépôt (classés par dossier/catégorie),
- afficher chaque shader dans un **viewport de rendu 800×450**,
- afficher le code source dans un **éditeur en lecture seule avec bouton "Copier"**.

Le site est 100% statique (HTML/CSS/JS, pas de backend), pour pouvoir être servi tel quel par GitHub Pages.

## Constats sur le dépôt (état actuel)

- 378 fichiers `.glsl` répartis dans 7 dossiers thématiques : `divers`, `raymarching`, `retro-synthwave`, `retro-gaming`, `space-cosmos`, `tunnel`, `water`. Plus aucun fichier à la racine (les 2 fichiers historiques `001`/`002` ont été déplacés dans `divers`).
- **[FAIT]** Dossiers renommés en minuscules, sans espaces ni `&` (ex. `Retro & Synthwave` → `retro-synthwave`), pour rester compatibles sans encodage avec des URL et des chemins de build simples.
- **[FAIT]** Nommage normalisé en `NNN-simple.glsl` avec numérotation globale continue de `001` à `378` (renumérotée après la suppression des fichiers `multi`, qui avait laissé des trous dans la séquence). L'ancien nommage Shadertoy (`<id>_<Titre>.txt`) a été abandonné ; l'historique de renommage reste consultable via `git log --follow` sur chaque fichier.
- **[FAIT]** Les 72 shaders multi-passes (`NNN-multi.glsl` : présence de `Buffer A/B/C/D`, `Common` et/ou `Sound`) ont été supprimés du dépôt. Seuls les shaders mono-pass (`Image` seul) sont conservés, ce qui simplifie le runtime de rendu prévu (plus besoin de gérer le ping-pong de buffers ni la concaténation de `Common`).
- Les fichiers restants contiennent un unique bloc `// ==== Image (image) ====`.
- Le titre original et l'id Shadertoy ne sont plus portés par le nom de fichier : ils devront être retrouvés dans le contenu du fichier (si présent en commentaire) ou dans l'historique git (nom de fichier avant renommage), sinon considérés comme perdus pour l'affichage.
- Pas de métadonnées séparées (pas de JSON par shader) : tout est dans le fichier texte lui-même.

## Étapes

### 1. Normalisation des données (build-time, statique)
- [x] Renommer tous les fichiers shaders en `NNN-simple.glsl` / `NNN-multi.glsl` (numérotation globale, via `git mv` pour préserver l'historique).
- [x] Supprimer les 72 shaders multi-passes (`NNN-multi.glsl`) : le dépôt ne contient plus que des shaders mono-pass (`NNN-simple.glsl`).
- [x] Écrire un script (Node.js) `scripts/build-index.js` qui parcourt les dossiers, parse chaque fichier :
  - extrait le numéro (`NNN`) depuis le nom de fichier (le suffixe `-simple` devient implicite, tous les fichiers restants étant mono-pass),
  - extrait la catégorie (nom du dossier ; tous les fichiers sont désormais dans un dossier de catégorie, plus aucun à la racine),
  - retrouve un titre lisible : en priorité le titre porté par un commentaire `// NAME : ...` s'il existe (18/378 fichiers), sinon fallback sur `Catégorie NNN` (ex. `Tunnel 010`),
  - extrait le contenu du bloc unique `// ==== Image (image) ====`.
  - *(non fait : détection des uniforms/textures utilisées — reporté, non bloquant pour la suite)*.
- [x] Générer un fichier `data/shaders.json` : liste de `{ num, title, category, file }` (378 entrées).
- [x] Copier/normaliser les sources brutes dans `data/shaders/<NNN>.json` (un fichier par shader, avec `source` en plus des champs d'index) pour un chargement à la demande côté client (évite de charger 378 shaders d'un coup).

### 2. Squelette du site statique
- [ ] Structure : `index.html`, `assets/css/style.css`, `assets/js/app.js`.
- [ ] Layout à deux zones principales :
  - **Sidebar / liste** : catégories repliables + liste des shaders (titre, recherche texte, filtre par catégorie).
  - **Zone principale** : viewport de rendu (canvas 800×450) au-dessus, éditeur de code en dessous (ou côte à côte selon largeur d'écran).
- [ ] Responsive minimal : sur petit écran, la sidebar devient un menu réductible et le viewport garde son ratio (scalé en `max-width`, mais résolution interne du canvas conservée à 800×450 pour la fidélité du rendu).

### 3. Viewport de rendu WebGL (800×450)
- [ ] Canvas fixé à `width=800 height=450` (résolution interne), avec `iResolution` réglé en conséquence.
- [ ] Petit runtime WebGL "Shadertoy-like" (`assets/js/shadertoy-runtime.js`) :
  - compile le fragment shader (pass `image` unique) en l'enveloppant dans un template qui fournit `mainImage`, les uniforms standards (`iResolution`, `iTime`, `iTimeDelta`, `iFrame`, `iMouse`, `iDate`), un quad plein écran, et la boucle `requestAnimationFrame`.
  - affiche une erreur de compilation lisible dans l'UI (log GLSL) plutôt qu'un écran noir silencieux.
- [ ] Contrôles de base : Play/Pause, Reset time, affichage FPS (debug), et si pertinent, interaction souris simplifiée pour `iMouse`.
- [ ] Gestion des shaders qui utilisent des textures externes (`iChannel` image/cubemap) : soit non supportés au départ (fallback message clair), soit ajout d'assets par défaut plus tard (cf. Étape 6).

### 4. Éditeur de code avec copie
- [ ] Intégrer un éditeur en lecture seule avec coloration syntaxique GLSL (ex. CodeMirror 6, léger, chargé via CDN pour rester statique).
- [ ] Bouton "Copier le code" unique par shader (copie dans le presse-papier via `navigator.clipboard`), tous les shaders restants n'ayant qu'un seul pass `Image`.
- [ ] Feedback visuel sur la copie (ex. "Copié !" temporaire).
- [ ] Bouton "Voir sur Shadertoy" : l'id Shadertoy d'origine n'étant plus dans le nom de fichier, ce lien nécessite de retrouver l'id via l'historique git (nom de fichier avant renommage) ou un commentaire dans le code ; sinon, fonctionnalité abandonnée.

### 5. Navigation et état
- [ ] Routing simple côté client via `#hash` (ex. `#/tunnel/010`) pour permettre le lien direct vers un shader précis.
- [ ] Chargement du shader sélectionné : fetch de `data/shaders/<NNN>.json`, compilation, mise à jour de l'éditeur.
- [ ] Recherche (titre) et filtre par catégorie dans la sidebar, mis à jour en direct.
- [ ] Miniatures (optionnel, étape ultérieure) : capture d'une frame du rendu en `<canvas>.toDataURL()` pour prévisualisation dans la liste (peut être pré-générée par le script de build avec un rendu headless, ou généré à la volée côté client au premier affichage puis mis en cache `localStorage`).

### 6. Robustesse face aux shaders non supportés
- [ ] Détection des dépendances non gérées (textures, cubemaps, son, VR) au moment du build, marquage `unsupported: true` avec raison dans `shaders.json`.
- [ ] Dans l'UI, afficher un badge "aperçu non disponible" + le code reste consultable/copiable même si le rendu échoue.

### 7. Déploiement GitHub Pages
- [ ] Ajouter un workflow GitHub Actions (`.github/workflows/deploy.yml`) qui :
  - exécute `scripts/build-index.js` pour régénérer `data/`,
  - publie le contenu statique sur la branche `gh-pages` (ou déploiement Pages natif via `actions/deploy-pages`).
- [ ] Vérifier que tous les chemins (dossiers avec espaces/accents comme `Retro & Synthwave`) sont correctement encodés en URL.
- [ ] Tester le site en local (`npx serve` ou équivalent) avant publication.

### 8. Finitions
- [ ] README mis à jour avec lien vers le site publié et instructions de contribution (comment ajouter un nouveau shader : juste déposer le fichier dans le bon dossier + relancer le build).
- [ ] Thème visuel simple (dark mode par défaut, cohérent avec l'esthétique "shader").
- [ ] Vérification manuelle d'un échantillon de shaders par catégorie pour valider le bon fonctionnement du runtime (au moins 2-3 par dossier).

## Pile technique proposée

- HTML/CSS/JS vanilla + WebGL2 (ou WebGL1 en fallback) pour le runtime de rendu.
- CodeMirror 6 (CDN) pour l'éditeur en lecture seule avec coloration GLSL.
- Node.js uniquement pour le script de build (génération de `data/shaders.json`), aucune dépendance runtime côté client au-delà des CDN.
- GitHub Actions + GitHub Pages pour l'hébergement et le déploiement automatique.

## Risques / points d'attention

- Les shaders multi-passes ont été retirés du dépôt : le runtime n'a plus qu'à supporter le pass `Image` seul (pas de ping-pong de buffers à gérer).
- Certains shaders référencent des textures/cubemaps Shadertoy (`iChannel0` = image externe) non présentes dans le dépôt : le rendu ne sera pas fidèle sans ces assets. À documenter clairement plutôt que de bloquer le projet dessus.
- Noms de dossiers et de fichiers désormais tous normalisés (minuscules, sans espaces ni caractères spéciaux) : le risque d'encodage URL est levé.
- Le titre/nom original de chaque shader (perdu du nom de fichier après renommage) doit être retrouvé côté contenu ou historique git avant la génération de `data/shaders.json`, sous peine d'afficher uniquement des numéros dans l'UI.

# Licence et Copyright

**Shadertoy Exemples**
Copyright © 2026 Patrick JAILLET — Tous droits réservés
E-mail : sandefjord.development@proton.me
Site web : https://patrickjaillet.github.io/Shadertoy-Exemples

---

# Conventions de Développement Strictes

- [ ] Tous les fichiers `.md` du dépôt en Français.
- [ ] Logiciel en Anglais `.json` (i18n).
- [ ] Aucun texte ou commentaire dans les fichiers de code.
- [ ] Chaque fonctionnalité ajoutée doit être reflétée dans ce fichier ROADMAP.md.
- [ ] Sérialisation automatique de la version du logiciel selon la norme stricte SemVer.
- [ ] Ne pas mettre de nom de phase dans les fichiers.
- [ ] Chaque modification doit être automatiquement reflétée dans le fichier CHANGELOG.md.
- [ ] Le fichier README.md doit être créé et mis à jour à chaque modification, incluant une capture d'écran du logiciel.
- [ ] Ne jamais intégrer Claude AI dans GitHub, les fichiers, ou la liste des contributeurs.
- [ ] Intégrer copyright / e-mail / site web dans un onglet « À propos ».
- [ ] Aller droit au but, exhaustivité et rigueur technique professionnelle.
