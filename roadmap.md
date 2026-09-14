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
- [x] Structure : `index.html`, `assets/css/style.css`, `assets/js/app.js`.
- [x] Layout à deux zones principales :
  - **Sidebar / liste** : catégories repliables + liste des shaders (titre, recherche texte en direct). Filtre par catégorie couvert implicitement par le regroupement (une catégorie sans résultat de recherche est masquée).
  - **Zone principale** : viewport de rendu (canvas 800×450) au-dessus, éditeur de code en dessous.
- [x] Responsive minimal : sur petit écran (≤720px), la sidebar devient un panneau réductible via un bouton "☰ Shaders", le viewport garde son ratio 800×450 via `aspect-ratio` en CSS (résolution interne du canvas conservée à 800×450 pour la fidélité du rendu).
- Le rendu WebGL réel (étape 3) et l'éditeur CodeMirror (étape 4) ne sont pas encore branchés : le code source s'affiche pour l'instant en texte brut dans un `<pre>`, et le viewport affiche un message d'attente.

### 3. Viewport de rendu WebGL (800×450)
- [x] Canvas fixé à `width=800 height=450` (résolution interne), avec `iResolution` réglé en conséquence.
- [x] Petit runtime WebGL "Shadertoy-like" (`assets/js/shadertoy-runtime.js`) :
  - compile le fragment shader (pass `image` unique) en l'enveloppant dans un template qui fournit `mainImage`, les uniforms standards (`iResolution`, `iTime`, `iTimeDelta`, `iFrame`, `iMouse`, `iDate`), un quad plein écran (triangle unique), et la boucle `requestAnimationFrame`.
  - affiche une erreur de compilation lisible dans l'UI (log GLSL complet, vertex ou fragment) plutôt qu'un écran noir silencieux. Testé en conditions réelles (Playwright + Chromium) : le shader `063` (array literal GLSL ES 3.00) échoue proprement avec le détail des erreurs de compilation affiché ; le shader `307` (raymarching tunnel) compile et s'affiche correctement dans le viewport.
- [x] Contrôles de base : Play/Pause, Reset (bornés à l'activation du chargement d'un shader). *(non fait : affichage FPS de debug, non bloquant)*.
- [x] Interaction souris simplifiée pour `iMouse` (mousedown/mousemove/mouseup convertis en coordonnées canvas).
- [ ] Gestion des shaders qui utilisent des textures externes (`iChannel` image/cubemap) : à ce stade ces shaders (19/378) compilent probablement mais avec un rendu non fidèle (aucune texture liée à `iChannel0..3`) ; le fallback explicite (message "aperçu non disponible") reste à faire (cf. Étape 6).

### 4. Éditeur de code avec copie
- [x] Éditeur en lecture seule avec coloration syntaxique GLSL : CodeMirror 5 (mode `clike`, proche de la syntaxe C/GLSL) chargé via cdnjs, thème `dracula`. CodeMirror 6 nécessite un bundler (imports ES modules), écarté au profit de CodeMirror 5 qui s'intègre en simples balises `<script>`/`<link>`, cohérent avec la contrainte "site 100% statique sans backend".
- [x] Bouton "Copier le code" unique par shader (copie dans le presse-papier via `navigator.clipboard`), tous les shaders restants n'ayant qu'un seul pass `Image`.
- [x] Feedback visuel sur la copie (ex. "Copié !" temporaire).
- [x] **Bouton "Voir sur Shadertoy" abandonné.** Investigation menée : l'id Shadertoy d'origine (ex. `3XKfzt`) est bien récupérable via `git log --follow` sur l'historique de renommage pour la plupart des fichiers, mais **`--follow` se trompe de piste sur 42 des 378 fichiers** (~11%) à cause des renommages en chaîne successifs (contenu très similaire entre certains shaders qui perturbe la détection de similarité de git). Un lien erroné vers le mauvais shader Shadertoy étant pire qu'une fonctionnalité absente, cette piste est abandonnée définitivement.
- Testé en conditions réelles (Playwright + Chromium) : l'éditeur affiche le code avec coloration syntaxique et numéros de ligne, le bouton copier place bien le code source dans le presse-papier (vérifié avec permissions `clipboard-read`/`clipboard-write` accordées).

### 5. Navigation et état
- [x] Routing simple côté client via `#hash`, format `#/<NNN>` (ex. `#/307`), le numéro étant déjà unique sur l'ensemble du dépôt (pas besoin de préfixer par la catégorie). Implémenté avec `history.pushState` (pas de rechargement de page) et écoute de `popstate`/`hashchange` pour le bouton précédent/suivant du navigateur. Un hash invalide ou pointant vers un shader inexistant est ignoré sans erreur.
- [x] Chargement du shader sélectionné : fetch de `data/shaders/<NNN>.json`, compilation, mise à jour de l'éditeur *(fait dès l'étape 3/4)*.
- [x] Recherche (titre) dans la sidebar, mise à jour en direct *(fait dès l'étape 2)*. Pas de filtre par catégorie séparé : le regroupement par catégorie sert déjà de filtre visuel, une catégorie sans résultat de recherche est masquée.
- Testé en conditions réelles (Playwright + Chromium) : lien direct `#/307` charge le bon shader au chargement de page, la sélection d'un autre shader met à jour le hash, le bouton "précédent" du navigateur revient à l'état antérieur, un hash invalide (`#/999`) n'entraîne aucune erreur.
- [ ] Miniatures (optionnel, étape ultérieure) : capture d'une frame du rendu en `<canvas>.toDataURL()` pour prévisualisation dans la liste (peut être pré-générée par le script de build avec un rendu headless, ou généré à la volée côté client au premier affichage puis mis en cache `localStorage`).

### 6. Robustesse face aux shaders non supportés
- [x] Détection des dépendances non gérées au moment du build (`scripts/build-index.js`) : recherche de `iChannel0..3` (textures externes non fournies dans le dépôt) et de `samplerCube`/`textureCube` (cubemaps). 19/378 shaders détectés comme `unsupported: true`, avec `unsupportedReason` explicite dans `data/shaders/<NNN>.json` et propagé dans l'index léger `data/shaders.json`. Aucun shader `Sound`/VR restant dans le dépôt (déjà retirés avec les multi-passes à l'étape 1).
- [x] Dans l'UI, badge "aperçu non disponible" affiché à côté du titre dans la sidebar pour chaque shader marqué `unsupported`, et le viewport affiche directement la raison (ex. "Texture(s) externe(s) non fournie(s) dans le dépôt (iChannel0, iChannel1).") sans même tenter la compilation WebGL. Le code reste entièrement consultable et copiable en dessous.
- Testé en conditions réelles (Playwright + Chromium) : le shader `003` (utilisation de `iChannel0`/`iChannel1`) affiche le badge dans la sidebar et le message clair dans le viewport, avec le code toujours visible dans l'éditeur.

### 7. Déploiement GitHub Pages
- [x] Ajouter un workflow GitHub Actions (`.github/workflows/deploy.yml`) qui :
  - se déclenche sur chaque push vers `main` (+ déclenchement manuel `workflow_dispatch`),
  - exécute `scripts/build-index.js` pour régénérer `data/`,
  - publie le contenu statique via le déploiement Pages natif (`actions/configure-pages`, `actions/upload-pages-artifact`, `actions/deploy-pages`), préféré à la branche `gh-pages` car plus simple à opérer (pas de branche annexe à maintenir) et recommandé par GitHub.
  - **Action manuelle requise côté utilisateur, non automatisable** : dans les paramètres du dépôt GitHub (`Settings > Pages > Build and deployment > Source`), sélectionner "GitHub Actions" pour que ce workflow puisse effectivement publier.
- [x] Vérifier que tous les chemins sont correctement utilisables en URL : dossiers déjà normalisés (minuscules, sans espaces/accents/caractères spéciaux) depuis les étapes précédentes, aucun chemin problématique restant dans le dépôt. Le site ne navigue de toute façon jamais directement vers un fichier `.glsl` par URL (uniquement via `fetch()` de JSON), ce qui élimine ce risque par construction.
- [x] Testé le site en local (`npx serve .`) avant publication : page d'accueil, `data/shaders.json` et un `data/shaders/<NNN>.json` répondent tous en 200.

### 8. Finitions
- [x] README.md créé avec lien vers le site publié, instructions d'ajout d'un nouveau shader, pile technique, et capture d'écran du logiciel (`docs/screenshot.png`), conformément aux conventions strictes du dépôt.
- [x] Thème visuel dark mode *(fait dès l'étape 2 : palette sombre CSS + thème `dracula` pour CodeMirror depuis l'étape 4)*.
- [x] Vérification manuelle d'un échantillon de shaders par catégorie (2-3 par dossier, en plus des shaders déjà testés aux étapes précédentes) via Playwright + Chromium : 11 des 15 shaders testés rendent correctement dans le viewport, 4 échouent à la compilation GLSL (incompatibilités WebGL1/GLSL ES 3.00) avec l'erreur affichée proprement — comportement attendu et déjà géré par le runtime. Chaque catégorie compte au moins un shader validé fonctionnel.

**Étape 8 complète : les 8 étapes de la roadmap sont désormais toutes réalisées** (miniatures de l'étape 5 restant en option non bloquante, cf. Risques).

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
