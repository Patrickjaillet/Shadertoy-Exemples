# Journal des modifications

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet suit le [Versionnage Sémantique](https://semver.org/lang/fr/) (SemVer).

## [Non publié]

### Ajouté

- Favicon SVG inline pour éviter le 404 sur `favicon.ico`.
- Miniatures de prévisualisation dans la sidebar : générées à la volée côté client au premier affichage d'un shader, mises en cache dans `localStorage`, affichées à côté du titre pour chaque shader déjà visité.
- Export vidéo : bouton « Enregistrer » (durée et images/seconde paramétrables par l'utilisateur) qui capture le rendu image par image de façon déterministe (`ShaderToyRuntime.renderFrameAt`, indépendant de `requestAnimationFrame`), puis assemble les images en un fichier `.mp4` (H.264) via ffmpeg.wasm, téléchargeable directement depuis le navigateur. Les binaires ffmpeg.wasm (~31 Mo) sont servis en local (`assets/vendor/ffmpeg/`) plutôt que depuis un CDN : le Worker interne de la bibliothèque utilise une résolution de chemin relative (`importScripts`) qui échoue de façon fiable avec des URLs cross-origin/blob générées à la volée.

### Modifié

- Retrait de tous les commentaires (`//` et `/* */`) des 378 fichiers `.glsl` du dépôt, conformément à la convention du projet « aucun texte ou commentaire dans les fichiers de code ». Le marqueur technique `// ==== Image (image) ====` a également disparu ; `scripts/build-index.js` a été adapté pour ne plus en dépendre (chaque fichier est désormais lu intégralement comme source du shader). Conséquence : les 18 fichiers qui portaient un titre lisible via un commentaire `// NAME : ...` affichent désormais le titre générique `Catégorie NNN` comme tous les autres.

### Corrigé

- Fins de ligne incohérentes (mélange CRLF/LF) dans les 378 fichiers `.glsl`, introduites par le script de retrait des commentaires. Normalisées en LF pur.

- Runtime de rendu migré de WebGL1 vers WebGL2 (GLSL ES 3.00) : plusieurs shaders (`006`, `100`, `250`, `308`, et d'autres) échouaient à la compilation avec des messages comme `'for' : Invalid init declaration` ou `'tanh' : no matching overloaded function found`, ces fonctionnalités GLSL n'existant qu'en GLSL ES 3.00. Shadertoy tournant lui-même en WebGL2, l'alignement corrige le rendu de tous les shaders concernés sans régression sur ceux qui fonctionnaient déjà.
- Défilement à la molette de la souris impossible dans l'éditeur de code : `viewportMargin: Infinity` désactivait le scroller interne de CodeMirror sans fournir d'alternative fonctionnelle. Retiré cette option et fixé la hauteur de `.CodeMirror` à 420px, laissant CodeMirror gérer son propre défilement.

## [0.1.0] - 2026-09-14

Premier jalon fonctionnel du site de visualisation des shaders.

### Ajouté

- Normalisation des 378 fichiers shaders du dépôt : renommage en `NNN-simple.glsl` (numérotation globale continue), dossiers de catégorie en minuscules sans espaces (`divers`, `raymarching`, `retro-synthwave`, `retro-gaming`, `space-cosmos`, `tunnel`, `water`).
- Suppression des shaders multi-passes (Buffer A/B/C/D, Common, Sound) : seuls les shaders mono-pass (`Image` seul) sont conservés.
- Script de build (`scripts/build-index.js`) générant `data/shaders.json` (index léger) et `data/shaders/<NNN>.json` (un fichier par shader, avec titre extrait des commentaires du code, catégorie, source).
- Site statique (`index.html`, `assets/`) avec sidebar de navigation par catégorie et recherche en direct.
- Viewport de rendu WebGL 800×450 (`assets/js/shadertoy-runtime.js`) : uniforms standards Shadertoy (`iResolution`, `iTime`, `iTimeDelta`, `iFrame`, `iMouse`, `iDate`), contrôles Play/Pause/Reset, interaction souris, affichage lisible des erreurs de compilation GLSL.
- Éditeur de code en lecture seule avec coloration syntaxique GLSL (CodeMirror 5, thème `dracula`) et bouton de copie du code source.
- Routing côté client par hash (`#/<NNN>`) pour le lien direct partageable vers un shader précis.
- Détection au build des shaders non affichables (dépendance à des textures externes `iChannel0-3` absentes du dépôt, 19/378 shaders concernés) : badge dans la sidebar et message explicite dans le viewport, code toujours consultable.
- Workflow GitHub Actions (`.github/workflows/deploy.yml`) de déploiement automatique sur GitHub Pages à chaque push sur `main`.
- Modale « À propos » (copyright, e-mail, site web) accessible depuis la sidebar.
- `README.md` avec capture d'écran du site et instructions de contribution.
- `roadmap.md` documentant les étapes de développement, la pile technique et les conventions strictes du projet.
